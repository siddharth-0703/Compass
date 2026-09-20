import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> loginWithPhone(String phone, String otp);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}
