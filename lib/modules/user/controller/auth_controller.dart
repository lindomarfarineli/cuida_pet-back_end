import 'dart:async';
import 'dart:convert';
import 'package:cuidapet_api/application/exceptions/user_exists_exception.dart';
import 'package:cuidapet_api/application/exceptions/user_not_foud_exists_exception.dart';
import 'package:cuidapet_api/application/helpers/jwt_helper.dart';
import 'package:cuidapet_api/application/logs/i_log.dart';
import 'package:cuidapet_api/entities/user.dart';
import 'package:cuidapet_api/modules/user/service/i_user_service.dart';
import 'package:cuidapet_api/modules/user/service/user_save_input_model.dart';
import 'package:cuidapet_api/modules/user/view_models/login_view_model.dart';
import 'package:cuidapet_api/modules/user/view_models/user_confirm_input_model.dart';
import 'package:cuidapet_api/modules/user/view_models/user_refresh_token_input_model.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'auth_controller.g.dart';

@Injectable()
class AuthController {
  IUserService userService;
  ILog log;

  AuthController({required this.userService, required this.log});

  @Route.post('/register')
  Future<Response> saveUser(Request request) async {
    try {
      final userModel = UserSaveInputModel.requestMapping(await request.readAsString());
      await userService.createUser(userModel);
      return Response.ok(
          jsonEncode({'message': 'Cadastro realizado com sucesso!'}));
    } on UserExistsException {
      return Response(400,
          body: jsonEncode(
              {'message': 'usuário já cadastrado na base de dados'}));
    } catch (e) {
      log.error('erro ao cadastrar usuario', e);
      return Response.internalServerError();
    }
  }

  @Route.post('/')
  Future<Response> login(Request request) async {
    try {
      final loginViewModel = LoginViewModel(await request.readAsString());

      User user;

      if (!loginViewModel.socialLogin) {
        user = await userService.loginWithEmailPassword(loginViewModel.email,
            loginViewModel.password, loginViewModel.supplierUser);
      } else {
        //social login -> facebook, etc
        user = await userService.loginWithSocialMedia(
            loginViewModel.email,
            loginViewModel.avatar,
            loginViewModel.socialKey,
            loginViewModel.socialType,
            loginViewModel.supplierUser);
      }
      return Response.ok(jsonEncode(
          {'access_token': JwtHelper.generateJWT(user.id!, user.suplierId)}));
    } on UserNotFoudExistsException {
      return Response.forbidden(
          jsonEncode({'message': 'usuário ou senha inválidos!'}));
    } catch (e, s) {
      log.error('erro ao fazer login', e, s);
      return Response.internalServerError(
          body: json.encode({'message': 'erro ao realizar login'}));
    }
  }

  @Route('PATCH', '/confirm')
  Future<Response> confirmLogin(Request request) async {

    final user = int.parse(request.headers['user']!);
    final supplier = int.tryParse(request.headers['supplier'] ?? '');
    final token =
        JwtHelper.generateJWT(user, supplier).replaceAll('Bearer ', '');

    final inputModel = UserConfirmInputModel(
        userId: user, accessToken: token, data: await request.readAsString());

    String refreshToken = await userService.confirmLogin(inputModel);

    return Response.ok(jsonEncode(
        {'access_token': 'Bearer $token', 'refresh_token': refreshToken}));
  }

  @Route.put('/refresh')
  Future<Response> refreshToken(Request request) async {
    try {
      final user = int.parse(request.headers['user']!);
      final supplier = int.tryParse(request.headers['supplier'] ?? '');
      final accessToken = request.headers['access_token'];

      final model = UserRefreshTokenInputModel(
          dataRequest: await request.readAsString(),
          user: user,
          suplier: supplier,
          accessToken: accessToken!);

      final userRefreshToken = await userService.refreshToken(model);

      return Response.ok(jsonEncode({
        'access_token': userRefreshToken.accessToken,
        'refresh_token': userRefreshToken.refreshToken
      }));
    } on Exception catch (e) {
      log.error(e);
      return Response.internalServerError(
          body: jsonEncode({"message": "erro ao atualizar token"}));
    }
  }

  Router get router => _$AuthControllerRouter(this);
}
