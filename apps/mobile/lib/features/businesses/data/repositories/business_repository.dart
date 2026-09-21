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
      final errorData = response.data['error'];
      final message = errorData is String ? errorData : (errorData?['message'] ?? 'Failed to load businesses');
      throw Exception(message);
    } on DioException catch (e) {
      final errorData = e.response?.data?['error'];
      final message = errorData is String ? errorData : (errorData?['message'] ?? 'Network error occurred');
      throw Exception(message);
    }
  }
}
