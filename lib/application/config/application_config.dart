import "package:cuidapet_api/application/config/database_connection_config.dart";
import "package:cuidapet_api/application/config/service_locator_config.dart";
import "package:cuidapet_api/application/logs/i_log.dart";
import "package:cuidapet_api/application/logs/i_log_impl.dart";
import "package:cuidapet_api/application/routers/router_configure.dart";
import "package:dotenv/dotenv.dart";
import "package:get_it/get_it.dart";
import "package:shelf_router/shelf_router.dart";



class ApplicationConfig { 
  Future <void>  loadConfigApplication(Router router) async { 
    await _loadEnv(); 
    _loadDatabaseConfig();
    _configLogger();
    _loadDependences();
    _loadRoutersConfigure(router);
    //var env = DotEnv(includePlatformEnvironment: true)..load();
    //print(env['url_banco_dados']);
  } 
  
  Future _loadEnv() async => DotEnv(includePlatformEnvironment: true)..load();
  
  void _loadDatabaseConfig() {
    var env = DotEnv(includePlatformEnvironment: true)..load();
    final databaseConfig = DatabaseConnectionConfig(
      host: env['DATABASE_HOST'] ?? env['databaseHost']!,
      port: int.tryParse(env['DATABASE_PORT'] ?? env['databasePort']!) ?? 0 ,
      user: env['DATABASE_USER'] ?? env['databaseUser']!,
      password: env['DATABASE_PASSWORD'] ?? env['databasePassword']!,
      database: env['DATABASE_NAME'] ?? env['databaseName']!
    );
    GetIt.I.registerSingleton(databaseConfig);
  }
  void _configLogger() => GetIt.I.registerLazySingleton<ILog>(() => ILogImpl());
  
  void _loadDependences() => configureDependencies();
  
  void _loadRoutersConfigure(Router router) => RouterConfigure(router: router).configure();
}

