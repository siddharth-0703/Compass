import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/models/market_price_model.dart';
import '../../data/repositories/market_repository.dart';

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  final secureStorage = SecureStorage();
  final apiClient = ApiClient(secureStorage);
  return MarketRepository(apiClient);
});

// A simple StateNotifier to handle state and commodity filters
class MarketPricesNotifier extends StateNotifier<AsyncValue<List<MarketPriceModel>>> {
  final MarketRepository _repository;
  String _currentState = 'Maharashtra';
  String? _currentCommodity;

  MarketPricesNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchPrices();
  }

  String get currentState => _currentState;
  String? get currentCommodity => _currentCommodity;
  String? get lastUpdated => _repository.getLastUpdated(_currentState, _currentCommodity);

  Future<void> fetchPrices({String? state, String? commodity}) async {
    if (state != null) _currentState = state;
    if (commodity != null) _currentCommodity = commodity;

    this.state = const AsyncValue.loading();
    try {
      final prices = await _repository.getPrices(state: _currentState, commodity: _currentCommodity);
      this.state = AsyncValue.data(prices);
    } catch (e, stack) {
      this.state = AsyncValue.error(e, stack);
    }
  }
}

final marketPricesProvider = StateNotifierProvider<MarketPricesNotifier, AsyncValue<List<MarketPriceModel>>>((ref) {
  final repository = ref.watch(marketRepositoryProvider);
  return MarketPricesNotifier(repository);
});
