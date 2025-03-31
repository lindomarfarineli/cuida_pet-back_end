import 'package:cuidapet_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_api/entities/category.dart';
import 'package:cuidapet_api/entities/services_supplier.dart';
import 'package:cuidapet_api/entities/supplier.dart';
import 'package:cuidapet_api/modules/supplier/data/i_supplier_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:cuidapet_api/application/database/i_database_connection.dart';
import 'package:cuidapet_api/application/logs/i_log.dart';
import 'package:cuidapet_api/dtos/supplier_near_by_me_dto.dart';
import 'package:mysql1/mysql1.dart';



@LazySingleton(as: ISupplierRepository)
class SupplierRepository implements ISupplierRepository {

  IDatabaseConnection connection;
  ILog log;


  SupplierRepository({
    required this.connection,
    required this.log,
  });

  @override
  Future<List<SupplierNearByMeDto>> findNearByPosition(double lat, double long, int distance) async {
    MySqlConnection? conn;

    try{
      conn = await connection.openConnection();

      final query = '''
        SELECT f.id, f.nome, f.logo, f.categorias_fornecedor_id,
        (6371 * 
          acos(
            cos(radians($lat)) *
            cos(radians(ST_X(f.latlng))) *
            cos(radians($long) - radians(ST_Y(f.latlng))) +
            sin(radians($lat)) *
            sin(radians(ST_X(f.latlng)))
          )) AS distancia
        FROM fornecedor f
        HAVING distancia <= $distance
        ORDER BY distancia;   
       ''';

      final result = await conn.query(query);

      return result.map(
        (f) =>
         SupplierNearByMeDto(
          id: f['id'],
          name: f['nome'],
          logo: (f['logo'] as Blob?)?.toString(), 
          distance: f['distancia'], 
          categoryId: f['categorias_fornecedor_id'])).toList();


    } on MySqlConnection catch (e, s) {
      log.error('Erro ao buscar forncedores mais proximos ', e,s);
      throw DatabaseException();
    } finally {
      conn?.close();
    }
  }

  @override
  Future<Supplier?> findById(int id) async {
    MySqlConnection? conn;    

    try {
      conn = await connection.openConnection();
      final query = '''
        SELECT 
          f.id, f.nome, f.logo, f.endereco, f.telefone, ST_X(f.latlng) as lat, ST_Y(f.latlng) as lng, 
          f.categorias_fornecedor_id, c.nome_categoria, c.tipo_categoria
        FROM 
        fornecedor as f
          inner join categorias_fornecedor as c on (f.categorias_fornecedor_id = c.id)
        where
          f.id = ?  
      ''';

      final result = await conn.query(query, [id]);

      if(result.isNotEmpty){

        final msql = result.first;

        return Supplier(
          id: msql['id'],
          name: msql['nome'],
          logo: (msql['logo'] as Blob?)?.toString(),
          address: msql['endereco'],
          phone: msql['telefone'],
          lat: msql['lat'],
          long: msql['lng'],
          category: Category(
            id: msql['id'],
            name: msql['nome_categoria'],
            type: msql['tipo_categoria']          
          )
        );        
      } else {
        return null;
      }

    } on MySqlException catch (e, s) {
      log.error('erro ao buscar fonecedor', e, s);

      throw DatabaseException();
    } finally {
      conn?.close();
    }


  }

  @override
  Future<List<ServicesSupplier>> findBySupplierId(int supplierId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      final result = await conn.query('''
        SELECT id, fornecedor_id, nome_servico, valor_servico
        FROM fornecedor_servicos
        where fornecedor_id = ? 
        ''', [supplierId]);

      if (result.isNotEmpty) {
        

        return result.map((e) => ServicesSupplier(
          id: e['id'],
          supplierId: e['fornecedor_id'],
          name: e['nome_servico'],
          price: e['valor_servico'])
        ).toList();
      } else {
        return [];
      }

    } on MySqlException catch (e, s) {
      log.error('erro ao buscar serviço do fornecedor', e,s);
      throw MySqlException;
    } finally {
      conn?.close();
    }
  }
  
  @override
  Future<bool> checkUserEmailExist(String email) async {
    MySqlConnection? conn;

    try {
      
      conn = await connection.openConnection();

      final result = await conn.query('SELECT COUNT(*) FROM usuario WHERE email = ?', [email]);

      final data = result.first;

      return data[0] > 0;




    } on MySqlException catch(e,s) {
      log.error('erro ao confirmar se usuario existe', e, s);

      throw DatabaseException();
    } finally {

      conn?.close();
    }
   
  }
  
  @override
  Future<int> saveSupplier(Supplier supplier) async {
    MySqlConnection? conn;

    

    try{
      conn = await connection.openConnection();

      final result = await conn.query('''
      INSERT INTO fornecedor(nome, logo, endereco, telefone, latlng, categorias_fornecedor_id)
      values (?,?,?,?,ST_GeomfromText(?),?)
      ''', [
          supplier.name, 
          supplier.logo, 
          supplier.address, 
          supplier.phone,
          'POINT(${supplier.lat ?? 0} ${supplier.long ?? 0})',
          supplier.category?.id
      ]);

      if (result.insertId != null){
        return result.insertId!;
      } else {
        throw DatabaseException();
      } 
      
    } on MySqlException catch (e, s) {
      log.error('erro ao salver fornecedor', e, s);
      throw DatabaseException;
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<Supplier> update(Supplier supplier) async {
      MySqlConnection? conn;

      try{
        conn = await connection.openConnection();
       
        await conn.query(
          '''
            UPDATE fornecedor
            SET 
              nome = (?),
              logo = (?),
              endereco = (?),
              telefone = (?),
              latlng = ST_GeomFromText(?),
              categorias_fornecedor_id = ?
            where 
              id = ?  
          ''',[
            supplier.name,
            supplier.logo,
            supplier.address,
            supplier.phone,
            'POINT(${supplier.lat} ${supplier.long})',
            supplier.category?.id,
            supplier.id
          ]);

          int? supplierId = supplier.category?.id;
          
          Category? category;

          if (supplierId != null) {
            
            final resultCategory = await conn.query('''
              SELECT * FROM categorias_fornecedor WHERE id = ?
            ''', [supplierId] );

            final data = resultCategory.first;
            
            category = Category(
              id: data['id'],
              name: data['nome_categoria'],
              type: data['tipo_categoria']
            );

          }

          return supplier.copyWith(category: category);



      } on MySqlConnection catch (e,s) {
        log.error('erro ao atualizar fornecedor', e,s);
        throw DatabaseException();

      } finally{
        await conn?.close();
      }


  }

}
