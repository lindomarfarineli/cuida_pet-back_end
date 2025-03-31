import 'dart:async';
import 'dart:convert';
import 'package:cuidapet_api/application/exceptions/user_not_foud_exists_exception.dart';
import 'package:cuidapet_api/application/logs/i_log.dart';
import 'package:cuidapet_api/modules/user/service/i_user_service.dart';
import 'package:cuidapet_api/modules/user/view_models/update_avatar_view_model.dart';
import 'package:cuidapet_api/modules/user/view_models/update_devide_token_model.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'user_controller.g.dart';

@Injectable()
class UserController {
  IUserService userService;
  ILog log;

  UserController({
    required this.userService,
    required this.log,
  });

  @Route.get('/')
  Future<Response> findByToken(Request request) async {
    try {
      final user = int.parse(request.headers['user']!);
      final userData = await userService.findById(user);

      return Response.ok(jsonEncode({
        "email": userData.email,
        "register_type": userData.registerType,
        "img_avatar": userData.imageAvatar
      }));
    } on UserNotFoudExistsException {
      return Response.notFound(204);
    } catch (e, s) {
      log.error('erro ao buscar usuario ', e, s);
      return Response.internalServerError(
          body: jsonEncode({"message": "erro ao buscar usuário!"}));
    }
  }

  @Route.put('/avatar')
  Future<Response> updateAvatar(Request request) async {
    try {
      final userId = int.parse(request.headers['user']!);

      final updateAvatarViewModel = UpdateAvatarViewModel(
          userId: userId, dataRequest: await request.readAsString());

      final user = await userService.updateAvatar(updateAvatarViewModel);

      return Response.ok(jsonEncode({
        'email': user.email,
        'register_type': user.registerType,
        'url_avatar': user.imageAvatar
      }));
    } catch (e, s) {
      log.error('erro ao atualizar avatar', e, s);
      return Response.internalServerError(
          body: {'message': 'erro ao atualizar avatar'});
    }
  }

  @Route.put('/device')
  Future<Response> updateDeviceToken(Request request) async {
    try {
      final userId = int.parse(request.headers['user']!);
      final updateDevideTokenModel = UpdateDevideTokenModel(
          userId: userId, 
          dataRequest: await request.readAsString()
        );

      await userService.updateDeviceToken(updateDevideTokenModel);  

      return Response.ok(jsonEncode({}));
    } catch (e, s) {
      log.error('erro ao atualizar device token', e, s);
      return Response.internalServerError(
        
          body: {'message': 'erro ao atualizar token'});
    }
  }

  Router get router => _$UserControllerRouter(this);
}
