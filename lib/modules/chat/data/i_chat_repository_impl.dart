import 'package:cuidapet_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_api/entities/chat.dart';
import 'package:cuidapet_api/entities/device_token.dart';
import 'package:cuidapet_api/entities/supplier.dart';
import 'package:injectable/injectable.dart';

import 'package:cuidapet_api/application/database/i_database_connection.dart';
import 'package:cuidapet_api/application/logs/i_log.dart';
import 'package:mysql1/mysql1.dart';

import './i_chat_repository.dart';

@LazySingleton(as: IChatRepository)
class ChatRepository implements IChatRepository {
  IDatabaseConnection connection;
  ILog log;

  ChatRepository({
    required this.connection,
    required this.log,
  });

  @override
  Future<int> startChat(scheduleId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final result = await conn.query('''
        INSERT INTO chats(agendamento_id, status, data_criacao) VALUES (?, ?, ?)
        ''', [scheduleId, 'A', DateTime.now().toIso8601String()]);

      return result.insertId!;
    } on MySqlException catch (e, s) {
      log.error('Erro ao iniciar chat ', e, s);
      throw DatabaseException();
    } finally {
      conn?.close();
    }
  }

  @override
  Future<Chat?> findChatById(int chatId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final query = '''
      SELECT 
        c.id,
        c.data_criacao,
        c.status,
        a.usuario_id,
        a.nome as agendamento_nome,
        a.nome_pet as agendamento_nome_pet,
        a.fornecedor_id,
        f.nome as fornec_nome,
        f.logo,
        u.android_token as user_android_token,
        u.ios_token as user_ios_token,
        uf.android_token as fornec_android_token,
        uf.ios_token as fornec_ios_token
      FROM chats as c
      INNER JOIN agendamento a on a.id = c.agendamento_id,
      INNER JOIN fornecedor f on f.id = a.fornecedor_id
      -- dados do usuario cliente do petshop
      INNER JOIN usuario u on u.id = a.usuario_id
      -- dados do usuario fornecedor (O petshop no caso)
      INNER JOIN usuario uf on uf.fornecedor_id = f.id
      WHERE c.id = ?
      ''';

      final result = await conn.query(query, [chatId]);

      if (result.isNotEmpty) {
        final sql = result.first;
        return Chat(
            id: sql['id'],
            user: sql['user_id'],
            name: sql['agendamento_nome'],
            petName: sql['agendamento_nome_pet'],
            status: sql['status'],
            supplier: Supplier(
              id: sql['fornecedor_id'],
              name: sql['fornec_name'],
            ),
            userDeviceToken: DeviceToken(
              android: (sql['user_android_token'] as Blob?)?.toString(),
              ios: (sql['user_ios_token'] as Blob?)?.toString(),
            ),
            supplierDeviceToken: DeviceToken(
              android: (sql['fornec_android_token'] as Blob?)?.toString(),
              ios: (sql['fornec_ios_token'] as Blob?)?.toString(),
            ));
      } else {
        return null;
      }
    } on MySqlException catch (e, s) {
      log.error('erro ao buscar dados do chat. ', e, s);
      throw DatabaseException();
    } finally {
      conn?.close();
    }
  }

  @override
  Future<List<Chat>> getChatsByUser(int user) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      final query = '''
        SELECT
          c.id, c.data_criacao, c.status,
          a.nome, a.nome_pet, a.fornecedor_id, a.usuario_id,
          f.nome AS fornec_nome, f.logo
        FROM chats AS c
        INNER JOIN agendamento a on a.id = c.agendamento_id
        INNER JOIN fornecedor f on f.id = a.fornecedor_id
        WHERE 
          a.usuario_id = ?
        AND 
          c.status = 'A'
        ORDER BY
          c.data_criacao    
        ''';

      final result = await conn.query(query, [user]);

      return result.map((c) => Chat(
            id: c['id'],
            user: c['usuario_id'],
            supplier: Supplier(
              id: c['fornecedor_id'],
              name: c['fornec_name'],
              logo: (c['logo'] as Blob?)?.toString()
            ),
            name: c['nome'],
            petName: c['nome_pet'],
            status: c['status'],
          )).toList();
    } on MySqlException catch (e, s) {
      log.error('erro ao buscar chats do usuario', e, s);
      throw DatabaseException();
    } finally {
      conn?.close();
    }
  }
  
  @override
  Future<List<Chat>> getChatsBySupplier(int supplier) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      final query = '''
        SELECT
          c.id, c.data_criacao, c.status,
          a.nome, a.nome_pet, a.fornecedor_id, a.usuario_id,
          f.nome AS fornec_nome, f.logo
        FROM chats AS c
        INNER JOIN agendamento a on a.id = c.agendamento_id
        INNER JOIN fornecedor f on f.id = a.fornecedor_id
        WHERE 
          a.fornecedor_id = ?
        AND 
          c.status = 'A'
        ORDER BY
          c.data_criacao    
        ''';

      final result = await conn.query(query, [supplier]);

      return result.map((c) => Chat(
            id: c['id'],
            user: c['usuario_id'],
            supplier: Supplier(
              id: c['fornecedor_id'],
              name: c['fornec_name'],
              logo: (c['logo'] as Blob?)?.toString()
            ),
            name: c['nome'],
            petName: c['nome_pet'],
            status: c['status'],
          )).toList();
    } on MySqlException catch (e, s) {
      log.error('erro ao buscar chats do fornecedor', e, s);
      throw DatabaseException();
    } finally {
      conn?.close();
    }
  }
}
