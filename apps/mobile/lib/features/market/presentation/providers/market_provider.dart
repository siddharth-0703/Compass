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

  void selectState(String state) {
    if (_currentState != state) {
      _currentState = state;
      _currentMarket = null;
    }
  }

  void selectCommodity(String? commodity) {
    _currentCommodity = (commodity == null || commodity.isEmpty || commodity == 'All Commodities') ? null : commodity;
  }

  void selectMarket(String? market) {
    _currentMarket = (market == null || market.isEmpty || market == 'All Markets') ? null : market;
  }

  Future<void> fetchPrices({
    String? state,
    bool updateCommodity = false,
    String? commodity,
    bool updateMarket = false,
    String? market,
  }) async {
    if (state != null) {
      if (_currentState != state) {
        _currentMarket = null;
      }
      _currentState = state;
    }
    if (updateCommodity) {
      _currentCommodity = (commodity == null || commodity.isEmpty || commodity == 'All Commodities') ? null : commodity;
    } else if (commodity != null) {
      _currentCommodity = (commodity == 'All Commodities' || commodity.isEmpty) ? null : commodity;
    }

    if (updateMarket) {
      _currentMarket = (market == null || market.isEmpty || market == 'All Markets') ? null : market;
    } else if (market != null) {
      _currentMarket = (market == 'All Markets' || market.isEmpty) ? null : market;
    }

    this.state = const AsyncValue.loading();
    try {
      final prices = await _repository.getPrices(
        state: _currentState,
        commodity: _currentCommodity,
        market: _currentMarket,
      );
      this.state = AsyncValue.data(prices);
    } catch (e) {
      // Fallback: Never crash the UI with an error card, preserve filters
      final prices = await _repository.getPrices(
        state: _currentState,
        commodity: _currentCommodity,
        market: _currentMarket,
      );
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
