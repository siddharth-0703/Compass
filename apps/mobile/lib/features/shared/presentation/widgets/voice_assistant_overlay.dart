import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

enum VoiceAssistantState {
  idle,
  listening,
  processing,
  confirming,
  executing,
  speaking,
  error
}

class VoiceActionPayload {
  final String action;
  final String? path;
  final String? searchQuery;
  final String speechResponse;
  final double confidence;

  VoiceActionPayload({
    required this.action,
    this.path,
    this.searchQuery,
    required this.speechResponse,
    required this.confidence,
  });

  factory VoiceActionPayload.fromJson(Map<String, dynamic> json) {
    return VoiceActionPayload(
      action: json['action'] as String,
      path: json['path'] as String?,
      searchQuery: json['searchQuery'] as String?,
      speechResponse:
          json['speechResponse'] as String? ?? 'Opening requested section.',
      confidence: (json['confidence'] as num? ?? 1.0).toDouble(),
    );
  }
}

class VoiceAssistantOverlay extends ConsumerStatefulWidget {
  const VoiceAssistantOverlay({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VoiceAssistantOverlay(),
    );
  }

  @override
  ConsumerState<VoiceAssistantOverlay> createState() =>
      _VoiceAssistantOverlayState();
}

class _VoiceAssistantOverlayState extends ConsumerState<VoiceAssistantOverlay> {
  VoiceAssistantState _assistantState = VoiceAssistantState.idle;
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _speechAvailable = false;
  String _wordsSpoken = "";
  VoiceActionPayload? _pendingAction;
  String _statusText = "Tap the mic to talk";

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
  }

  void _initSpeech() async {
    _speech = stt.SpeechToText();
    try {
      _speechAvailable = await _speech.initialize(
        onError: (val) =>
            _handleError("Speech recognition error: ${val.errorMsg}"),
        onStatus: (val) {
          if (val == 'done' &&
              _assistantState == VoiceAssistantState.listening) {
            _processCapturedSpeech();
          }
        },
      );
      if (mounted) setState(() {});
    } catch (e) {
      _handleError("Could not initialize microphone.");
    }
  }

  void _initTts() {
    _tts = FlutterTts();
    _tts.setLanguage("en-US");
    _tts.setSpeechRate(0.5);
    _tts.setVolume(1.0);
  }

  Future<void> _speak(String text) async {
    setState(() {
      _assistantState = VoiceAssistantState.speaking;
      _statusText = text;
    });
    await _tts.speak(text);
  }

  void _startListening() async {
    if (!_speechAvailable) {
      _handleError("Microphone not available.");
      return;
    }

    setState(() {
      _assistantState = VoiceAssistantState.listening;
      _wordsSpoken = "";
      _statusText = "Listening...";
    });

    await _speech.listen(
      onResult: (val) {
        setState(() {
          _wordsSpoken = val.recognizedWords;
        });
      },
    );
  }

  void _stopListening() async {
    await _speech.stop();
    _processCapturedSpeech();
  }

  void _processCapturedSpeech() async {
    if (_wordsSpoken.trim().isEmpty) {
      setState(() {
        _assistantState = VoiceAssistantState.idle;
        _statusText = "Tap mic to talk";
      });
      return;
    }

    setState(() {
      _assistantState = VoiceAssistantState.processing;
      _statusText = "Processing query...";
    });

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _processOffline(_wordsSpoken);
      return;
    }

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.post('/ai/voice-command', data: {
        'query': _wordsSpoken,
        'currentLanguage': 'en',
      },);

      final success = response.data['success'] as bool;
      if (success) {
        final payload = VoiceActionPayload.fromJson(response.data['data']);
        _handleVoiceAction(payload);
      } else {
        _handleError("Failed to parse command.");
      }
    } catch (e) {
      _processOffline(_wordsSpoken);
    }
  }

  void _processOffline(String text) {
    final lower = text.toLowerCase();

    // Deterministic keyword matching
    String? path;
    String speech = "Opening requested section.";

    if (lower.contains("scheme") ||
        lower.contains("yojana") ||
        lower.contains("योजना") ||
        lower.contains("शेतकरी")) {
      path = "/schemes";
      speech = "Opening government schemes offline.";
    } else if (lower.contains("course") ||
        lower.contains("learning") ||
        lower.contains("video") ||
        lower.contains("शिकायची")) {
      path = "/learning";
      speech = "Opening learning hub offline.";
    } else if (lower.contains("mentor") ||
        lower.contains("mentorship") ||
        lower.contains("मार्गदर्शक")) {
      path = "/mentorship";
      speech = "Opening mentorship marketplace offline.";
    } else if (lower.contains("home") ||
        lower.contains("dashboard") ||
        lower.contains("मुख्य")) {
      path = "/dashboard";
      speech = "Going to dashboard.";
    }

    if (path != null) {
      _handleVoiceAction(VoiceActionPayload(
        action: 'NAVIGATE',
        path: path,
        speechResponse: speech,
        confidence:
            0.90, // Match contains keywords gives high offline confidence
      ),);
    } else {
      _handleVoiceAction(VoiceActionPayload(
        action: 'UNKNOWN',
        speechResponse:
            "You are offline. Try saying: open schemes or open courses.",
        confidence: 0.30,
      ),);
    }
  }

  void _handleVoiceAction(VoiceActionPayload payload) async {
    // Confidence checks rules
    if (payload.confidence >= 0.80) {
      _executeAction(payload);
    } else if (payload.confidence >= 0.50) {
      setState(() {
        _assistantState = VoiceAssistantState.confirming;
        _pendingAction = payload;
        _statusText = "Did you mean: ${payload.speechResponse}?";
      });
      await _speak("Did you mean: ${payload.speechResponse}?");
      setState(() {
        _assistantState = VoiceAssistantState.confirming; // Keep state
      });
    } else {
      final responseText = payload.action == 'UNKNOWN'
          ? payload.speechResponse
          : "I'm not sure what you mean. You can say: show government schemes.";
      await _speak(responseText);
      setState(() {
        _assistantState = VoiceAssistantState.idle;
      });
    }
  }

  void _executeAction(VoiceActionPayload payload) async {
    setState(() {
      _assistantState = VoiceAssistantState.executing;
      _statusText = payload.speechResponse;
    });

    await _speak(payload.speechResponse);

    if (payload.path != null && mounted) {
      final routePath = payload.path!;

      // Parse search queries
      if (payload.action == 'SEARCH' && payload.searchQuery != null) {
        context.push(
            '$routePath?search=${Uri.encodeComponent(payload.searchQuery!)}',);
      } else {
        context.push(routePath);
      }
      Navigator.of(context).pop(); // Close overlay bottom sheet
    } else {
      setState(() {
        _assistantState = VoiceAssistantState.idle;
      });
    }
  }

  void _handleError(String message) async {
    setState(() {
      _assistantState = VoiceAssistantState.error;
      _statusText = message;
    });
    await _speak(message);
    setState(() {
      _assistantState = VoiceAssistantState.idle;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E2C),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _statusText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_wordsSpoken.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '"$_wordsSpoken"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 32),
            _buildMicButton(),
            const SizedBox(height: 24),
            if (_assistantState == VoiceAssistantState.confirming &&
                _pendingAction != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      setState(() {
                        _assistantState = VoiceAssistantState.idle;
                        _pendingAction = null;
                        _statusText = "Tap mic to talk";
                      });
                    },
                    child: const Text('No'),
                  ),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => _executeAction(_pendingAction!),
                    child: const Text('Yes'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    final isListening = _assistantState == VoiceAssistantState.listening;
    final isProcessing = _assistantState == VoiceAssistantState.processing;

    return GestureDetector(
      onTap: isListening ? _stopListening : _startListening,
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: isListening
              ? Colors.red
              : (isProcessing ? Colors.orange : Colors.blue),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isListening ? Colors.red : Colors.blue).withValues(alpha: 0.5),
              blurRadius: 16,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: isProcessing
              ? const CircularProgressIndicator(color: Colors.white)
              : Icon(
                  isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 36,
                ),
        ),
      ),
    );
  }
}
