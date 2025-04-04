import 'dart:async';
import 'dart:convert';

import 'package:cuidapet_api/modules/chat/view_models/chat_notify_view_model.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:cuidapet_api/application/logs/i_log.dart';
import 'package:cuidapet_api/modules/chat/service/i_chat_service.dart';

part 'chat_controller.g.dart';

@Injectable()
class ChatController {
  IChatService service;
  ILog log;

  ChatController({
    required this.service,
    required this.log,
  });

  // /chats/schedule/1/start-chat
  @Route.post('/schedule/<scheduleId>/start-chat')
  Future<Response> startChatByScheduleId(
      Request request, String scheduleId) async {
    try {
      final chatId = await service.startChat(int.parse(scheduleId));
      return Response.ok(jsonEncode({'chat_id': chatId}));
    } catch (e, s) {
      log.error('Erro ao iniciar chat', e, s);
      return Response.internalServerError(
          body: {'message': 'erro ao criar chat'});
    }
  }

  @Route.post('/notify')
  Future<Response> notifyUser(Request request) async {
    try {
      final model = ChatNotifyViewModel(await request.readAsString());

      await service.notifyChat(model);
      return Response.ok(jsonEncode({}));
    } catch (e) {
      log.error('erro ao enviar noficao');
      return Response.internalServerError(
          body: jsonEncode({'message': 'erro ao enviar notificação'}));
    }
  }

  @Route.get('/user')
  Future<Response> findChatsByUser(Request request) async {
    try {
      final userId = int.parse(request.headers['user']!);

      final chats = await service.getChatsByUser(userId);

      final resultChats = chats
          .map((c) => {
                'id': c.id,
                'user': c.user,
                'name': c.name,
                'pet_name': c.petName,
                'supplier': {
                  'id': c.supplier.id,
                  'name': c.supplier.name,
                  'logo': c.supplier.logo
                }
              })
          .toList();

      return Response.ok(jsonEncode(resultChats));
    } catch (e, s) {
      log.error('erro ao buscar chats de usuario', e, s);
      return Response.internalServerError(
          body: {'message': 'erro ao buscar chats de usuarios'});
    }
  }

  @Route.get('/supplier')
  Future<Response> findChatsBySupplier(Request request) async {
    final supplier = int.tryParse(request.headers['supplier'] ?? '');

    if (supplier == null) {
      return Response(
        400,
        body: jsonEncode({'message': 'usuário logado não é um fornecedor!'}),
      );
    }
     try {
      

      final chats = await service.getChatsBySupplier(supplier);

      final resultChats = chats
          .map((c) => {
                'id': c.id,
                'user': c.user,
                'name': c.name,
                'pet_name': c.petName,
                'supplier': {
                  'id': c.supplier.id,
                  'name': c.supplier.name,
                  'logo': c.supplier.logo
                }
              })
          .toList();

      return Response.ok(jsonEncode(resultChats));
    } catch (e, s) {
      log.error('erro ao buscar chats de fornecedor', e, s);
      return Response.internalServerError(
          body: {'message': 'erro ao buscar chats de fornecedor.'});
    }
  }

  @Route.put('/<chatId>/end-chat')
  Future<Response> endChat (Request request, String chatId) async{

    try {
      await service.endChat(int.parse(chatId));
      return Response.ok(jsonEncode({}));
    } catch (e, s) {
      log.error('erro ao finalizar chat $chatId', e, s);
      return Response.internalServerError(body: {
        "message": "Erro ao finalizar chat"
      });

    }
  }

  Router get router => _$ChatControllerRouter(this);
}
