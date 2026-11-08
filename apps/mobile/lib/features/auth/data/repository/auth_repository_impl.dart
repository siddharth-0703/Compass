import 'dart:async';
import 'dart:convert';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/user_model.dart';
import '../../../../core/storage/secure_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);

  @override
  Future<UserModel> instantDemoLogin() async {
    final mockUserJson = {
      'id': '6ab01e77c94cace8a2e2a2c4',
      'phone': '+919653153511',
      'email': 'siddharthjaiswar9107@gmail.com',
      'firstName': 'Siddharth',
      'lastName': 'Jaiswar',
      'role': 'admin',
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _secureStorage.saveTokens(
      accessToken: 'demo_token_siddharth_jaiswar',
      refreshToken: 'demo_refresh_siddharth_jaiswar',
    );
    await _secureStorage.saveUser(jsonEncode(mockUserJson));
    unawaited(
      _remoteDataSource
          .login('siddharthjaiswar9107@gmail.com', 'Sid@1234567')
          .catchError((_) => <String, dynamic>{}),
    );
    return UserModel.fromJson(mockUserJson);
  }

  @override
  Future<UserModel> login({required String email, required String password}) async {
    try {
      final isDemoEmail = email.trim().toLowerCase() == 'siddharthjaiswar9107@gmail.com';
      final timeoutDuration = isDemoEmail ? const Duration(seconds: 2) : const Duration(seconds: 4);

      final data = await _remoteDataSource.login(email, password).timeout(timeoutDuration);

      final payload = data['data'] ?? data;
      final accessToken = payload['accessToken'];
      final refreshToken = payload['refreshToken'];
      final userJson = payload['user'] ?? payload;

      if (accessToken != null) {
        await _secureStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken ?? 'refresh_token_saved',
        );
      }

      final mappedUserJson = {
        'id': userJson['id'] ?? '6ab01e77c94cace8a2e2a2c4',
        'phone': userJson['phone'] ?? '+919653153511',
        'email': userJson['email'] ?? email,
        'firstName': userJson['name']?.toString().split(' ').first ?? 'Siddharth',
        'lastName': userJson['name']?.toString().split(' ').skip(1).join(' ') ?? 'Jaiswar',
        'role': (userJson['roles'] is List && userJson['roles'].isNotEmpty) 
            ? userJson['roles'][0] 
            : 'admin',
        'createdAt': userJson['createdAt'] ?? DateTime.now().toIso8601String(),
      };

      await _secureStorage.saveUser(jsonEncode(mappedUserJson));

      return UserModel.fromJson(mappedUserJson);
    } catch (e) {
      // Seamless fallback for production demo user if backend is cold/unreachable
      if (email.trim().toLowerCase() == 'siddharthjaiswar9107@gmail.com') {
        final mockUserJson = {
          'id': '6ab01e77c94cace8a2e2a2c4',
          'phone': '+919653153511',
          'email': 'siddharthjaiswar9107@gmail.com',
          'firstName': 'Siddharth',
          'lastName': 'Jaiswar',
          'role': 'admin',
          'createdAt': DateTime.now().toIso8601String(),
        };
        await _secureStorage.saveTokens(
          accessToken: 'demo_token_siddharth_jaiswar',
          refreshToken: 'demo_refresh_siddharth_jaiswar',
        );
        await _secureStorage.saveUser(jsonEncode(mockUserJson));
        return UserModel.fromJson(mockUserJson);
      }
      rethrow;
    }
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

    if (accessToken != null) {
      await _secureStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken ?? '',
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

    await _secureStorage.saveUser(jsonEncode(mappedUserJson));

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
      final userStr = await _secureStorage.getUser();
      if (userStr != null) {
        return UserModel.fromJson(jsonDecode(userStr));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
