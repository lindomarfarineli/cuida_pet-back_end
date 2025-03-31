



import 'package:cuidapet_api/application/database/i_database_connection.dart';
import 'package:cuidapet_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_api/application/exceptions/device_not_foud_exception.dart';
import 'package:cuidapet_api/application/exceptions/user_exists_exception.dart';
import 'package:cuidapet_api/application/exceptions/user_not_foud_exists_exception.dart';
import 'package:cuidapet_api/application/helpers/crypt_helper.dart';
import 'package:cuidapet_api/application/logs/i_log.dart';
import 'package:cuidapet_api/entities/user.dart';
import 'package:cuidapet_api/modules/user/view_models/platform.dart';
import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';
import './i_user_repository.dart';

@LazySingleton(as: IUserRepository)
class UserRepository implements IUserRepository {

  final IDatabaseConnection connection;
  final ILog log;

  UserRepository({required this.connection, required this.log});

  

  @override
  Future<User> createUser(User user) async {
   
   MySqlConnection? conn;

   try {
    conn = await connection.openConnection();
    final query = '''
          insert usuario(email, tipo_cadastro, img_avatar, senha, fornecedor_id, social_id)
          values(?,?,?,?,?,?)
        ''';

     final result = await conn.query(query, [
      user.email,
      user.registerType,
      user.imageAvatar,
      CryptHelper.generateSha256hash(user.password ?? ''),
      user.suplierId,
      user.socialKey
     ]);

     final userId = result.insertId;
     return user.copyWith(id: userId, password: null);
        
   } on MySqlException catch (e, s) {

     if(e.message.contains('usuario.email_UNIQUE')){
      log.error('usuario ja cadastrado na base de dados', e, s);
      throw UserExistsException();
     }
     
     log.error('erro ao criar usuario', e, s);
     
     throw DatabaseException(message: 'erro ao criar usuario', exception: e);
   } finally {      
      await conn?.close();
   }
  }
  
  @override
  Future<User> loginWithEmailPassword(String email, String password, bool supplierId) async {
    MySqlConnection? conn;

    try{
      conn = await connection.openConnection();
      var query = '''
      select *
      from usuario
      where
      email = ? and
      senha = ?

     ''';

      
      if (supplierId) {
        query += ' and fornecedor_id is not null';
      } else {
        query += ' and fornecedor_id is null';
      }

      final result = await conn.query(query, [email, CryptHelper.generateSha256hash(password)]);

      if (result.isEmpty) {
        log.error('usuario ou senha invalidos!!!');
        throw UserNotFoudExistsException(message: 'usurário ou senha inválidos');
      } else {
        final dataMySql = result.first;
       
        return User(
        id: dataMySql['id'] as int,
        email: dataMySql['email'],
        registerType: dataMySql['tipo_cadastro'],
        iosToken: (dataMySql['ios_token'] as Blob?)?.toString(),
        androidToken: (dataMySql['refresh_token'] as Blob?)?.toString(),
        imageAvatar: (dataMySql['image_avatar'] as Blob?)?.toString(),
        suplierId: dataMySql['fornecedor_id'] as int?
        );
      }
    }on MySqlException catch (e, s) {
      log.error('erro ao realizar login', e, s);

      throw DatabaseException(message: e.message);

    } finally {
      await conn?.close();
    }
  }
  
  @override
  Future<User> loginWithSocialMidia(String email, String socialKey, String socialType) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      var result = await conn.query('select * from usuario where email = ?', [email]);

      if (result.isEmpty) {
        throw UserNotFoudExistsException(message: 'usuário não encontrado');
      } else {
        var dataMySql = result.first;
        

        if(dataMySql['social_id'] == null || dataMySql['social_id'] != socialKey) {
          
          await conn.query('''
            update usuario
            set social_id = ?, tipo_cadastro = ?
            where id = ?
          ''', [
            socialKey,
            socialType,
            dataMySql['id']
            ]);
        }
        
       
        return User(
        id: dataMySql['id'] as int,
        email: dataMySql['email'],
        registerType: dataMySql['tipo_cadastro'],
        iosToken: (dataMySql['ios_token'] as Blob?)?.toString(),
        androidToken: (dataMySql['refresh_token'] as Blob?)?.toString(),
        imageAvatar: (dataMySql['image_avatar'] as Blob?)?.toString(),
        suplierId: dataMySql['fornecedor_id'] as int?
        );
      }      
    } on MySqlException catch (e, s) {
      log.error('erro ao realizar login', e, s);
      throw DatabaseException(message: e.message);
    } finally {
      conn?.close();
    }

  }
  
  @override
  Future<void> updateUserDeviceTokenAndRefreshToken(User user) async {
    MySqlConnection? conn;

    try{
      conn = await connection.openConnection();

      final setParams = {};

      if (user.iosToken != null ) {         
        setParams.putIfAbsent( 'ios_token', () => user.iosToken );
      }else if (user.androidToken != null ) {        
       setParams.putIfAbsent('android_token', () => user.androidToken );
      } else {        
        log.error('device nao informado');
        throw DeviceNotFoudException(message: 'device não informado!');
      }
       
      final query = '''
        update usuario
        set
          ${setParams.keys.elementAt(0)} = ?,
          refresh_token = ?
        where 
          id = ? ;  
      ''';
     
      await conn.query(query, [
        setParams.values.elementAt(0),
        user.refreshToken,
        user.id
      ]);


    }on MySqlException catch (e, s){

      log.error('erro ao confirmar login', e, s);
      throw DatabaseException();
    } finally {
      conn?.close();
    }
  }
  
  @override
  Future<void> updateRefreshToken(User user) async {
    MySqlConnection? conn;

    try{
      conn = await connection.openConnection();
      await conn.query(
        'update usuario set refresh_token = ? where id = ?', [
          user.refreshToken,
          user.id
        ]
      );

    } on MySqlException catch (e, s){
      log.error('erro ao atualizar o refresh token', e, s);
      throw DatabaseException();
    }finally {
      await conn?.close();
    }


    
  }
  
  @override
  Future<User> findById(int id) async {

    MySqlConnection? conn;

    try{
      conn = await connection.openConnection();

      final result = await conn.query('''
        select
          id, email, tipo_cadastro, ios_token, android_token,
          refresh_token, img_avatar, fornecedor_id
          from usuario
          where id=?
          ''', [id]);


          if (result.isEmpty) {
            log.error('usuario nao encontrado com o id $id');
            throw UserNotFoudExistsException(message: 'usuário $id não encontrado');
          } else {

            final dataMySql = result.first;

            return User(
              id: dataMySql['id'] as int,
              email: dataMySql['email'],
              registerType: dataMySql['tipo_cadastro'],
              iosToken: (dataMySql['ios_token'] as Blob?)?.toString(),
              androidToken: (dataMySql['refresh_token'] as Blob?)?.toString(),
              imageAvatar: (dataMySql['img_avatar'] as Blob?)?.toString(),
              suplierId: dataMySql['fornecedor_id'] as int?
            );
          }

    }on MySqlException catch (e, s){
      log.error('erro ao buscar o usuario', e, s);
      throw DatabaseException();
    }finally {
      await conn?.close();
    }
   
  }
  
  @override
  Future<void> updateAvatar(int id, String urlAvatar) async {
    MySqlConnection? conn;

    try{
      conn = await connection.openConnection();

      await conn.query(
      'update usuario set img_avatar = ? where id = ?', [urlAvatar, id]);
    } on MySqlException catch (e, s){
      log.error('erro ao atualizar o avatar', e, s);
      throw DatabaseException();
    }finally{
      conn?.close();
    }
  }

  @override
  Future<void> updateDeviceToken(int id, String token, Platform platform) async {
   MySqlConnection? conn;

   try{
    conn = await connection.openConnection();   

    String set = '';
    
    if (platform == Platform.ios) {
      set = "ios_token = ?";
    } else {
      set = 'android_token = ?';
    }
  

    final query = 'update usuario set $set where id = ?';

    await conn.query(query,[token, id]);

   

   }on MySqlException catch (e,s)  {
    log.error('erro ao atualizar device token ', e, s);
    throw DatabaseException();

   }finally{

    conn?.close();

   }
  }
}