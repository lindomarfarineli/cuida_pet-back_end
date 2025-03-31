import 'package:cuidapet_api/application/exceptions/service_exception.dart';
import 'package:cuidapet_api/application/exceptions/user_not_foud_exists_exception.dart';
import 'package:cuidapet_api/application/helpers/jwt_helper.dart';
import 'package:cuidapet_api/application/logs/i_log.dart';
import 'package:cuidapet_api/entities/user.dart';
import 'package:cuidapet_api/modules/user/data/i_user_repository.dart';
import 'package:cuidapet_api/modules/user/service/i_user_service.dart';
import 'package:cuidapet_api/modules/user/service/user_save_input_model.dart';
import 'package:cuidapet_api/modules/user/view_models/refresh_token_view_model.dart';
import 'package:cuidapet_api/modules/user/view_models/update_avatar_view_model.dart';
import 'package:cuidapet_api/modules/user/view_models/update_devide_token_model.dart';
import 'package:cuidapet_api/modules/user/view_models/user_refresh_token_input_model.dart';
import 'package:injectable/injectable.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

@LazySingleton(as: IUserService)
class IUserServiceImpl implements IUserService {
  IUserRepository userRepository;
  ILog log;

  IUserServiceImpl({required this.userRepository, required this.log});
  @override
  Future<User> createUser(UserSaveInputModel user) {
    final userEntity = User(
        email: user.email,
        password: user.password,
        registerType: 'APP',
        suplierId: user.supplierId);

    return userRepository.createUser(userEntity);
  }

  @override
  Future<User> loginWithEmailPassword(
      String email, String password, bool supplierId) {
    return userRepository.loginWithEmailPassword(email, password, supplierId);
  }

  @override
  Future<User> loginWithSocialMedia(
      String email, String avatar, String socialkey, String socialType, bool supplierUser) async {
    try {
      return await userRepository.loginWithSocialMidia(
          email, socialkey, socialType);
    } on UserNotFoudExistsException catch (e) {
      log.error('usuario nao encontrado, criando um usuario', e);
      final user = User(
          email: email,
          imageAvatar: avatar,
          registerType: socialType,
          socialKey: socialkey,
          password: DateTime.now().toString());

      return await userRepository.createUser(user);
    }
  }

  @override
  Future<String> confirmLogin(inputModel) async {
    final refreshToken = JwtHelper.refreshToke(inputModel.accessToken);
    final user = User(
        id: inputModel.userId,
        refreshToken: JwtHelper.refreshToke(inputModel.accessToken),
        iosToken: inputModel.iosDeviceToken,
        androidToken: inputModel.androidDeviceToken);

    await userRepository.updateUserDeviceTokenAndRefreshToken(user);

    return refreshToken;
  }

  @override
  Future<RefreshTokenViewModel> refreshToken(
      UserRefreshTokenInputModel model) async {
    _validateRefreshToken(model);
    final newAccessToken = JwtHelper.generateJWT(model.user, model.suplier);
    final newRefreshToken =
        JwtHelper.refreshToke(newAccessToken.replaceAll('Bearer', ''));

    final user = User(id: model.user, refreshToken: newRefreshToken);

    await userRepository.updateRefreshToken(user);

    return RefreshTokenViewModel(
        accessToken: newAccessToken, refreshToken: newRefreshToken);
  }

  void _validateRefreshToken(UserRefreshTokenInputModel model) {
    try {
      final refreshToken = model.refreshToken.split(' ');

      if (refreshToken.length != 2 || refreshToken.first != 'Bearer') {
        print('erro no if');
        log.error('refresh token invalido.');
        throw ServiceException('Refresh Token inválido!');
      }

      final refreshTokenClaim = JwtHelper.getClaims(refreshToken.last);

      refreshTokenClaim.validate(issuer: model.accessToken);
    } on ServiceException {
      rethrow;
    } on JwtException {
      log.error('refresh token invalido.');
      throw ServiceException('Refresh Token inválido!');
    } catch (e) {
      throw ServiceException('Erro ao validar refresh Token!');
    }
  }

  @override
  Future<User> findById(int id) => userRepository.findById(id);

  @override
  Future<User> updateAvatar(UpdateAvatarViewModel viewModel) async {
    await userRepository.updateAvatar(viewModel.userId, viewModel.urlAvatar);

    return await findById(viewModel.userId);
  }

  @override
  Future<void> updateDeviceToken(UpdateDevideTokenModel model) async {

    
    await userRepository.updateDeviceToken(
        model.userId, 
        model.token, 
        model.platform
        );
  }
      
      
}
