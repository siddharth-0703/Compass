import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/user_model.dart';
import '../../../../core/storage/secure_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);

  @override
  Future<UserModel> login({required String email, required String password}) async {
    final data = await _remoteDataSource.login(email, password);

    // The BFF sets HttpOnly cookies for web, but for mobile it should return tokens
    // Assuming backend returns { accessToken, refreshToken, user: {...} }
    final payload = data['data'] ?? data;
    final accessToken = payload['accessToken'];
    final refreshToken = payload['refreshToken'];
    final userJson = payload['user'] ?? payload;

    if (accessToken != null && refreshToken != null) {
      await _secureStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }

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

  @override
  Future<UserModel> signup({
    required String firstName,
    required String lastName,
    String? email,
    required String phone,
    required String password,
  }) async {
    final data = await _remoteDataSource.signup(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      password: password,
    );

    final payload = data['data'] ?? data;
    final accessToken = payload['accessToken'];
    final refreshToken = payload['refreshToken'];
    final userJson = payload['user'] ?? payload;

    if (accessToken != null && refreshToken != null) {
      await _secureStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }

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

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Ignore network errors on logout, we still want to clear local state
    }
    await _secureStorage.clearTokens();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final token = await _secureStorage.getAccessToken();
    if (token == null) return null;

    try {
      return await _remoteDataSource.getCurrentUser();
    } catch (e) {
      return null;
    }
  }
}
