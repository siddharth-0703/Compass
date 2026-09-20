import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/user_model.dart';
import '../../../../core/storage/secure_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);

  @override
  Future<UserModel> loginWithPhone(String phone, String otp) async {
    final data = await _remoteDataSource.loginWithPhone(phone, otp);

    // The BFF sets HttpOnly cookies for web, but for mobile it should return tokens
    // Assuming backend returns { accessToken, refreshToken, user: {...} }
    final accessToken = data['accessToken'];
    final refreshToken = data['refreshToken'];
    final userJson = data['user'] ?? data['data'];

    if (accessToken != null && refreshToken != null) {
      await _secureStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }

    return UserModel.fromJson(userJson);
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
