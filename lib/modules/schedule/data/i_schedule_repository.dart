import 'package:cuidapet_api/entities/schedule.dart';

abstract interface class IScheduleRepository {
  Future<void> save(Schedule schedule);
  Future<void> changedStatus (String status, int scheduleId);
  Future<List<Schedule>> findAllScheduleByUser (int userId);
  Future<List<Schedule>> findAllScheduleByUserSupplier (int userId);

}