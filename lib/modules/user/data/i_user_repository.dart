

import 'package:cuidapet_api/entities/user.dart';
import 'package:cuidapet_api/modules/user/view_models/platform.dart';

abstract interface class IUserRepository {

  Future<User> createUser(User user);
  Future<User> loginWithEmailPassword (String email, String password, bool supplierId);
  Future<User> loginWithSocialMidia (String email, String socialKey, String socialType);
  Future<void> updateUserDeviceTokenAndRefreshToken(User user);
  Future<void> updateRefreshToken(User user);
  Future<User> findById(int id);
  Future<void> updateAvatar(int id, String urlAvatar);
  Future<void> updateDeviceToken(int id, String token, Platform platform);
}