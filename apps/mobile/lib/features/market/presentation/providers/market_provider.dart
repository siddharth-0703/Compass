import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/market_price_model.dart';
import '../../data/repositories/market_repository.dart';

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MarketRepository(apiClient);
});

// StateNotifier to handle state, commodity, and market filters
class MarketPricesNotifier extends StateNotifier<AsyncValue<List<MarketPriceModel>>> {
  final MarketRepository _repository;
  String _currentState = 'Maharashtra';
  String? _currentCommodity;
  String? _currentMarket;

  MarketPricesNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchPrices();
  }

  String get currentState => _currentState;
  String? get currentCommodity => _currentCommodity;
  String? get currentMarket => _currentMarket;
  String? get lastUpdated => _repository.getLastUpdated(_currentState, _currentCommodity);

  Future<void> fetchPrices({String? state, String? commodity, String? market}) async {
    if (state != null) {
      if (_currentState != state) {
        // Reset market if state changes
        _currentMarket = null;
      }
      _currentState = state;
    }
    if (commodity != null) _currentCommodity = (commodity == 'All Commodities' ? null : commodity);
    if (market != null) _currentMarket = (market == 'All Markets' ? null : market);

    this.state = const AsyncValue.loading();
    try {
      final prices = await _repository.getPrices(
        state: _currentState,
        commodity: _currentCommodity,
        market: _currentMarket,
      );
      this.state = AsyncValue.data(prices);
    } catch (e, stack) {
      // Fallback: Never crash the UI with an error card
      final prices = await _repository.getPrices(state: _currentState);
      this.state = AsyncValue.data(prices);
    }
  }
}

final marketPricesProvider = StateNotifierProvider<MarketPricesNotifier, AsyncValue<List<MarketPriceModel>>>((ref) {
  final repository = ref.watch(marketRepositoryProvider);
  return MarketPricesNotifier(repository);
});

final marketStatesProvider = FutureProvider<List<String>>((ref) {
  final repo = ref.watch(marketRepositoryProvider);
  return repo.getStates();
});

final marketCommoditiesProvider = FutureProvider.family<List<String>, String>((ref, state) {
  final repo = ref.watch(marketRepositoryProvider);
  return repo.getCommodities(state);
});

final marketMarketsProvider = FutureProvider.family<List<String>, String>((ref, state) {
  final repo = ref.watch(marketRepositoryProvider);
  return repo.getMarkets(state);
});
