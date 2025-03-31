import 'package:cuidapet_api/application/exceptions/database_exception.dart';
import 'package:injectable/injectable.dart';

import 'package:cuidapet_api/application/database/i_database_connection.dart';
import 'package:cuidapet_api/application/logs/i_log.dart';
import 'package:cuidapet_api/entities/category.dart';
import 'package:mysql1/mysql1.dart';

import './i_categories_repository.dart';

@LazySingleton(as: ICategoriesRepository)
class CategoriesRepository implements ICategoriesRepository {

  IDatabaseConnection connection;
  ILog log;

  CategoriesRepository({
    required this.connection,
    required this.log,
  });

  @override
  Future<List<Category>> findAll() async {

    MySqlConnection? conn;

    try{

      conn = await connection.openConnection();

      final result = await conn.query('select * from categorias_fornecedor');

      if(result.isNotEmpty){
        return result.map((e) => Category(
          id: e['id'],
          name: e['nome_categoria'],
          type: e['tipo_categoria']

        )).toList();
      }

      return [];

    }on MySqlException catch (e,s) {

      log.error('erro ao buscar categorias do fornecedor.', e, s);
      throw DatabaseException;

    } finally{

      conn?.close();

    }
    
  }

}
