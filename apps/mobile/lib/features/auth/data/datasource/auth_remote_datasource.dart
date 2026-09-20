import '../models/user_model.dart';
import '../../../../core/api/api_client.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  Future<Map<String, dynamic>> loginWithPhone(String phone, String otp) async {
    final response = await _apiClient.dio.post(
      '/auth/login',
      data: {
        'phone': phone,
        'otp': otp,
      },
    );
    return response.data; // Expected to contain tokens and user
  }

  Future<void> logout() async {
    await _apiClient.dio.post('/auth/logout');
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.dio.get('/auth/me');
    return UserModel.fromJson(response.data['data']);
  }
}
