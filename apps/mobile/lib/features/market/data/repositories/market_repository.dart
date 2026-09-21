import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/storage/hive_storage.dart';
import '../models/market_price_model.dart';

class MarketRepository {
  final ApiClient _apiClient;

  MarketRepository(this._apiClient);

  Future<List<MarketPriceModel>> getPrices({String? state, String? commodity}) async {
    final queryParams = <String, String>{};
    if (state != null) queryParams['state'] = state;
    if (commodity != null) queryParams['commodity'] = commodity;
    
    // Default to Maharashtra if nothing provided (per current app defaults)
    if (queryParams.isEmpty) {
      queryParams['state'] = 'Maharashtra';
    }

    final cacheKey = 'market_prices_${queryParams.toString()}';

    try {
      final response = await _apiClient.dio.get('/mandi/prices', queryParameters: queryParams);
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final models = data.map((json) => MarketPriceModel.fromJson(json)).toList();
        
        // Cache the successful response
        await HiveStorage.settingsBox.put(cacheKey, data);
        await HiveStorage.settingsBox.put('${cacheKey}_timestamp', DateTime.now().toIso8601String());
        
        return models;
      }
      final errorData = response.data['error'];
      final message = errorData is String ? errorData : (errorData?['message'] ?? 'Failed to load market prices');
      throw Exception(message);
    } on DioException catch (e) {
      // Throw early instead of caching error, let the calling code handle it
      final errorData = e.response?.data?['error'];
      final message = errorData is String ? errorData : (errorData?['message'] ?? 'Network error occurred');
      throw Exception(message);
    } catch (e) {
      // Fallback to cache for other non-network errors
      final cached = HiveStorage.settingsBox.get(cacheKey);
      if (cached != null) {
        final data = cached as List<dynamic>;
        return data.map((json) => MarketPriceModel.fromJson(Map<String, dynamic>.from(json))).toList();
      }
      rethrow;
    }
  }

  String? getLastUpdated(String? state, String? commodity) {
    final queryParams = <String, String>{};
    if (state != null) queryParams['state'] = state;
    if (commodity != null) queryParams['commodity'] = commodity;
    if (queryParams.isEmpty) queryParams['state'] = 'Maharashtra';
    
    final cacheKey = 'market_prices_${queryParams.toString()}_timestamp';
    return HiveStorage.settingsBox.get(cacheKey) as String?;
  }
}
