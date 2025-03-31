import 'package:injectable/injectable.dart';

import 'package:cuidapet_api/application/logs/i_log.dart';
import 'package:cuidapet_api/entities/schedule.dart';
import 'package:cuidapet_api/entities/schedule_supplier_service.dart';
import 'package:cuidapet_api/entities/services_supplier.dart';
import 'package:cuidapet_api/entities/supplier.dart';
import 'package:cuidapet_api/modules/schedule/data/i_schedule_repository.dart';
import 'package:cuidapet_api/modules/schedule/view_models/schedule_save_input_model.dart';

import './i_schedule_service.dart';

@LazySingleton(as: IScheduleService)
class ScheduleService implements IScheduleService {

  final IScheduleRepository repository;
  final ILog log;

  ScheduleService({
    required this.repository,
    required this.log,
  });



  @override
  Future<void> scheduleService(ScheduleSaveInputModel model) async {

    final schedule = Schedule(
      scheduleDate: model.scheduleDatetime,
      name: model.name,
      petName: model.petName,
      supplier: Supplier(id: model.supplierId),
      services: model.services.map((e) => ScheduleSupplierService(
        service: ServicesSupplier(id:e),
        )).toList(),
      status: 'P',
      userId: model.userId


      
    ); 

    await repository.save(schedule);
  }
  
  @override
  Future<void> changedStatus(String status, int scheduleId) => repository.changedStatus(status, scheduleId);
  
  @override
  Future<List<Schedule>> findAllSchedulesByUser(int userId) => repository.findAllScheduleByUser(userId);
  
  @override
  Future<List<Schedule>> findAllSchedulesByUserSupplier(int userId) => repository.findAllScheduleByUserSupplier(userId);
  

}
