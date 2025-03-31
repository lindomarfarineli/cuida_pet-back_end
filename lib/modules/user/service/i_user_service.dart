
import 'package:cuidapet_api/entities/user.dart';
import 'package:cuidapet_api/modules/user/service/user_save_input_model.dart';
import 'package:cuidapet_api/modules/user/view_models/refresh_token_view_model.dart';
import 'package:cuidapet_api/modules/user/view_models/update_avatar_view_model.dart';
import 'package:cuidapet_api/modules/user/view_models/update_devide_token_model.dart';
import 'package:cuidapet_api/modules/user/view_models/user_confirm_input_model.dart';
import 'package:cuidapet_api/modules/user/view_models/user_refresh_token_input_model.dart';

abstract interface class IUserService {
  Future <User> createUser (UserSaveInputModel user);
  Future <User> loginWithEmailPassword(String email, String password, bool supplierId);
  Future <User> loginWithSocialMedia(String email, String avatar, String socialkey, String socialType, bool supplierUser);
  Future <String> confirmLogin(UserConfirmInputModel inputModel);
  Future <RefreshTokenViewModel> refreshToken(UserRefreshTokenInputModel model);
  Future <User> findById(int id);
  Future <User> updateAvatar(UpdateAvatarViewModel updateAvatarViewModel);
  Future <void> updateDeviceToken(UpdateDevideTokenModel model);
  


  
}