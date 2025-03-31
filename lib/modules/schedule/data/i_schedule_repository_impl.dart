import 'package:cuidapet_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_api/entities/schedule_supplier_service.dart';
import 'package:cuidapet_api/entities/services_supplier.dart';
import 'package:cuidapet_api/entities/supplier.dart';

import 'package:injectable/injectable.dart';

import 'package:cuidapet_api/application/database/i_database_connection.dart';
import 'package:cuidapet_api/application/logs/i_log.dart';
import 'package:cuidapet_api/entities/schedule.dart';
import 'package:mysql1/mysql1.dart';

import './i_schedule_repository.dart';

@LazySingleton(as: IScheduleRepository)
class ScheduleRepository implements IScheduleRepository {
  IDatabaseConnection connection;
  ILog log;

  ScheduleRepository({
    required this.connection,
    required this.log,
  });

  @override
  Future<void> save(Schedule schedule) async {
    MySqlConnection? conn;
    try {
      conn = await connection.openConnection();

      await conn.transaction((_) async {
        final result = await conn!.query('''
        insert into
          agendamento(data_agendamento, usuario_id, fornecedor_id, status, nome, nome_pet)
          values (?,?,?,?,?,?)
      ''', [
          schedule.scheduleDate.toIso8601String(),
          schedule.userId,
          schedule.supplier.id,
          schedule.status,
          schedule.name,
          schedule.petName
        ]);

        final scheduleId = result.insertId;

        if (scheduleId != null) {
          await conn.queryMulti('''
          INSERT INTO agendamento_servicos value(?,?)
      ''', schedule.services.map((s) => [scheduleId, s.service.id]));
        }
      });
    } on MySqlException catch (e, s) {
      log.error('erro ao salvar agendamento.', e, s);
      throw DatabaseException;
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<void> changedStatus(String status, int scheduleId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      await conn.query('''
        UPDATE agendamento SET status = ? WHERE id = ?
      ''', [status, scheduleId]);
    } on MySqlException catch (e, s) {
      log.error('erro ao atualizar status do agendamento', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<List<Schedule>> findAllScheduleByUser(int userId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      final result = await conn.query('''
        SELECT
          a.id,
          a.data_agendamento,
          a.status,
          a.nome,
          a.nome_pet,
          f.id as fornec_id,
          f.nome as fornec_nome,
          f.logo
        FROM
          agendamento as a 
        INNER JOIN fornecedor f on f.id = a.fornecedor_id 
        WHERE a.usuario_id = ?
        ORDER BY a.data_agendamento DESC 
      ''', [userId]);

      final sheduleResultFuture = result
          .map(
            (s) async => Schedule(
              id: s['id'],
              scheduleDate: s['data_agendamento'],
              status: s['status'],
              name: s['nome'],
              petName: s['nome_pet'],
              userId: userId,
              supplier: Supplier(
                id: s['fornec_id'],
                name: s['fornec_nome'],
                logo: (s['logo'] as Blob?).toString(),
              ),
              services: await findAllServiceBySchedule(s['id']) ,
            ),
          )
          .toList();

          return Future.wait(sheduleResultFuture);


    } on MySqlException catch (e, s) {
      log.error('erro ao buscar agendamentos do usuario $userId', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  Future<List<ScheduleSupplierService>> findAllServiceBySchedule(
      int scheduleId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      final result = await conn.query('''
        SELECT
          fs.id, fs.nome_servico, fs.valor_servico, fs.fornecedor_id
        FROM
          agendamento_servicos as ags
        INNER JOIN
          fornecedor_servicos fs on fs.id = ags.fornecedor_servicos_id
        WHERE 
          ags.agendamento_id = ?   
      ''', [scheduleId]);

      return result
          .map(
            (s) => ScheduleSupplierService(
              service: ServicesSupplier(
                id: s['id'],
                name: s['nome_servico'],
                price: s['valor_servico'],
                supplierId: s['fornecedor_id']
              ),
            ),
          )
          .toList();

    } on MySqlException catch (e, s) {
      log.error(
          'erro ao buscar agendamento de servicos do agendamento $scheduleId',
          e,
          s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }
  
  @override
  Future<List<Schedule>> findAllScheduleByUserSupplier(int userId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      final result = await conn.query('''
        SELECT
          a.id,
          a.data_agendamento,
          a.status,
          a.nome,
          a.nome_pet,
          f.id as fornec_id,
          f.nome as fornec_nome,
          f.logo
        FROM
          agendamento as a 
        INNER JOIN fornecedor f on f.id = a.fornecedor_id
        INNER JOIN usuario u on u.fornecedor_id = f.id 
        WHERE u.id = ?
        ORDER BY a.data_agendamento DESC 
      ''', [userId]);

      final sheduleResultFuture = result
          .map(
            (s) async => Schedule(
              id: s['id'],
              scheduleDate: s['data_agendamento'],
              status: s['status'],
              name: s['nome'],
              petName: s['nome_pet'],
              userId: userId,
              supplier: Supplier(
                id: s['fornec_id'],
                name: s['fornec_nome'],
                logo: (s['logo'] as Blob?).toString(),
              ),
              services: await findAllServiceBySchedule(s['id']) ,
            ),
          )
          .toList();

          return Future.wait(sheduleResultFuture);


    } on MySqlException catch (e, s) {
      log.error('erro ao buscar agendamentos do usuario $userId', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }
}
