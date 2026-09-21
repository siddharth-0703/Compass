import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> signup({
    required String firstName,
    required String lastName,
    String? email,
    required String phone,
    required String password,
  });
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}
