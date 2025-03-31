

import 'package:cuidapet_api/application/config/database_connection_config.dart';
import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

import './i_database_connection.dart';

@LazySingleton(as: IDatabaseConnection)
class IDatabaseConnectionImpl implements IDatabaseConnection {


  final DatabaseConnectionConfig _config;
  IDatabaseConnectionImpl(this._config);

  @override
  Future<MySqlConnection> openConnection() {

    
    return MySqlConnection.connect(ConnectionSettings(
      host: _config.host,
      port: _config.port,
      user: _config.user,
      db: _config.database,
      password: _config.password
    ));
  }

}