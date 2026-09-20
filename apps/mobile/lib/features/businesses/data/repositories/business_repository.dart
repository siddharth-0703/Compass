import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../models/business_model.dart';

class BusinessRepository {
  final ApiClient _apiClient;

  BusinessRepository(this._apiClient);

  Future<List<BusinessModel>> getMyBusinesses() async {
    try {
      final response = await _apiClient.dio.get('/business');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => BusinessModel.fromJson(json)).toList();
      }
      throw Exception(response.data['error']?['message'] ?? 'Failed to load businesses');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error']?['message'] ?? 'Network error occurred');
    }
  }
}
