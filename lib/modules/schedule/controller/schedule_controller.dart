import 'dart:async';
import 'dart:convert';

import 'package:cuidapet_api/application/logs/i_log.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:cuidapet_api/modules/schedule/service/i_schedule_service.dart';
import 'package:cuidapet_api/modules/schedule/view_models/schedule_save_input_model.dart';

part 'schedule_controller.g.dart';

@Injectable()
class ScheduleController {
  final IScheduleService service;
  final ILog log;
  ScheduleController({required this.service, required this.log});

  @Route.post('/')
  Future<Response> scheduleServices(Request request) async {
    try {
      final userId = int.parse(request.headers['user']!);
      final inputModel = ScheduleSaveInputModel(
          userId: userId, dataRequest: await request.readAsString());

      await service.scheduleService(inputModel);

      return Response.ok(jsonEncode({}));
    } catch (e, s) {
      log.error('erro ao registrar agendamento de servicos', e, s);
      return Response.internalServerError(
          body: {'message': "erro ao registrar agendamento de serviços"});
    }
  }

  @Route.put('/<scheduleId|[0-9]+>/status/<status>')
  Future<Response> changedStatus(
    Request request,
    String scheduleId,
    String status,
  ) async {
    print('valores controler-47 = $scheduleId, $status');

    try {
      await service.changedStatus(status, int.parse(scheduleId));
      return Response.ok(jsonEncode({}));
    } catch (e, s) {
      log.error('erro ao atualizar status do agendamento ', e, s);
      return Response.internalServerError(
          body: {"message": "Erro ao atualizar status de agendamento"});
    }
  }

  @Route.get('/')
  Future<Response> findAllScheduleByUser(Request request) async {

    final userId = int.parse(request.headers['user']!);
    try {
      final result = await service.findAllSchedulesByUser(userId);

      final response = result.map((r) => {
         'id': r.id,
         'schedule_date': r.scheduleDate.toIso8601String(),
         'status': r.status,
         'pet_name': r.petName,
         'supplier': {
          'id': r.supplier.id,
          'name': r.supplier.name,
          'logo': r.supplier.logo,
         },
         'services': r.services.map((s) => {
          'id': s.service.id,
          'name': s.service.name,
          'price': s.service.price
         }).toList(),

      } 
       ).toList();



      return Response.ok(jsonEncode(response));
    } catch (e, s) {
      log.error('erro ao buscar agendametos do usuario $userId ', e, s);
      return Response.internalServerError(body: {'message': 'erro ao buscar agendamentos de um usuario'});
    }
  }

  @Route.get('/supplier')
  Future<Response> findAllScheduleBySupplier(Request request) async {

    final userId = int.parse(request.headers['user']!);
    try {
      final result = await service.findAllSchedulesByUserSupplier(userId);

      final response = result.map((r) => {
         'id': r.id,
         'schedule_date': r.scheduleDate.toIso8601String(),
         'status': r.status,
         'pet_name': r.petName,
         'supplier': {
          'id': r.supplier.id,
          'name': r.supplier.name,
          'logo': r.supplier.logo,
         },
         'services': r.services.map((s) => {
          'id': s.service.id,
          'name': s.service.name,
          'price': s.service.price
         }).toList(),

      } 
       ).toList();
      return Response.ok(jsonEncode(response));
    } catch (e, s) {
      log.error('erro ao buscar agendametos do forncecedor $userId ', e, s);
      return Response.internalServerError(body: {'message': 'erro ao buscar agendamentos de um fornecedor'});
    }
  }

  Router get router => _$ScheduleControllerRouter(this);
}
