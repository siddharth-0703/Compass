import '../models/user_model.dart';
import '../../../../core/api/api_client.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiClient.dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    return response.data; // Expected to contain tokens and user
  }

  Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    String? email,
    required String phone,
    required String password,
  }) async {
    final response = await _apiClient.dio.post(
      '/auth/register',
      data: {
        'name': '$firstName $lastName'.trim(),
        if (email != null && email.isNotEmpty) 'email': email,
        'phone': phone,
        'password': password,
      },
    );
    return response.data;
  }

  Future<void> logout() async {
    await _apiClient.dio.post('/auth/logout');
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.dio.get('/auth/me');
    final userJson = response.data['data'] ?? response.data;
    final mappedUserJson = {
      'id': userJson['id'] ?? '',
      'phone': userJson['phone'] ?? '',
      'email': userJson['email'],
      'firstName': userJson['name']?.toString().split(' ').first,
      'lastName': userJson['name']?.toString().split(' ').skip(1).join(' '),
      'role': (userJson['roles'] is List && userJson['roles'].isNotEmpty) 
          ? userJson['roles'][0] 
          : 'entrepreneur',
      'createdAt': userJson['createdAt'] ?? DateTime.now().toIso8601String(),
    };
    return UserModel.fromJson(mappedUserJson);
  }
}
