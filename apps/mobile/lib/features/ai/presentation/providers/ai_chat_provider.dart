import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/services/gemini_service.dart';

class AiChatState {
  final List<ChatMessage> messages;
  final bool isGenerating;
  final String? error;

  const AiChatState({
    this.messages = const [],
    this.isGenerating = false,
    this.error,
  });

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isGenerating,
    String? error,
    bool clearError = false,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isGenerating: isGenerating ?? this.isGenerating,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

final aiChatProvider =
    StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  final service = ref.watch(geminiServiceProvider);
  return AiChatNotifier(service);
});

class AiChatNotifier extends StateNotifier<AiChatState> {
  final GeminiService _geminiService;
  final _uuid = const Uuid();

  AiChatNotifier(this._geminiService)
      : super(
          AiChatState(
            messages: [
              ChatMessage(
                id: 'welcome',
                text: 'Hello! I am Compass AI. How can I assist you today? You can ask me about government schemes, APMC mandi rates, organic farming techniques, or registering your business.',
                isUser: false,
                timestamp: DateTime.now(),
              ),
            ],
          ),
        );

  Future<void> sendMessage(String text, {bool isVoice = false}) async {
    final query = text.trim();
    if (query.isEmpty || state.isGenerating) return;

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: query,
      isUser: true,
      timestamp: DateTime.now(),
      isVoice: isVoice,
    );

    final updatedMessages = [...state.messages, userMsg];
    state = state.copyWith(
      messages: updatedMessages,
      isGenerating: true,
      clearError: true,
    );

    try {
      final answer = await _geminiService.askGemini(
        query,
        history: state.messages,
      );

      final aiMsg = ChatMessage(
        id: _uuid.v4(),
        text: answer,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isGenerating: false,
      );
    } catch (e) {
      final errorMsg = ChatMessage(
        id: _uuid.v4(),
        text: 'Sorry, I encountered an issue: $e. Please check your connection and try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isGenerating: false,
        error: e.toString(),
      );
    }
  }

  void clearChat() {
    state = AiChatState(
      messages: [
        ChatMessage(
          id: 'welcome',
          text: 'Conversation cleared. How can I help you next?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }
}

