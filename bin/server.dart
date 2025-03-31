import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:cuidapet_api/application/middlewares/cors/cors_middlewares.dart';
import 'package:cuidapet_api/application/middlewares/default_content_type/default_content_type.dart';
import 'package:cuidapet_api/application/middlewares/security/security_middleware.dart';
import 'package:cuidapet_api/application/config/application_config.dart';
 

void main(List<String> args) async {

  final router = Router();
  final appConfig =  ApplicationConfig();
  await appConfig.loadConfigApplication(router);
  final getIt = GetIt.I; 

  //Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  
  final handler = Pipeline()
  .addMiddleware(CorsMiddlewares().handler)
  .addMiddleware(DefaultContentType().handler)
  .addMiddleware(SecurityMiddleware(log: getIt.get()).handler)
  .addMiddleware(logRequests())
  .addHandler((router));

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '3500');    
  final server = await serve(handler, ip, port); 
  
  print('Server listening on port ${server.port}');
}
