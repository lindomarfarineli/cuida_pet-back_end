
import 'dart:convert';

import 'package:cuidapet_api/application/helpers/jwt_helper.dart';
import 'package:cuidapet_api/application/logs/i_log.dart';
import 'package:cuidapet_api/application/middlewares/middlewares.dart';
import 'package:cuidapet_api/application/middlewares/security/security_skip_url.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shelf/shelf.dart';



class SecurityMiddleware extends Middlewares {

  final ILog log;
  final skipUrl = <SecuritySkipUrl>[ 
    SecuritySkipUrl(url:'/auth/register', method: 'POST'), 
    SecuritySkipUrl(url:'/auth/', method: 'POST'),  
    SecuritySkipUrl(url:'/', method: 'GET'),
    SecuritySkipUrl(url:'/suppliers/user', method: 'GET'),
    SecuritySkipUrl(url:'/suppliers/user', method: 'POST'),
    
    
  ];

  SecurityMiddleware({required this.log});



  @override
  Future<Response> execute(Request request) async {

    try {

     if (skipUrl.contains(SecuritySkipUrl(url: '/${request.url.path}', method: request.method))) {         
        return innerHandler(request);
      } 
      
      final authHeader = request.headers['authorization'];

      if (authHeader == null || authHeader.isEmpty) {
        throw JwtException.invalidToken;
      }

      final authHeaderContent =  authHeader.split(' ');

      if (authHeaderContent[0] != 'Bearer') {
       throw JwtException.invalidToken;
      }

      final authorizationToken =  authHeaderContent[1];

      final claims = JwtHelper.getClaims(authorizationToken);

      if (request.url.path != 'auth/refresh'){        
        claims.validate();
      }

      final claimsMap = claims.toJson();

     
      final userId = claimsMap['sub'];
      final suplierId = claimsMap['supplierId'].toString();

      if (userId == null) {
        throw JwtException.invalidToken;
      }
      
      final securitHeaders = {
        'user': userId,
         'access_token': authorizationToken,
         'supplier': suplierId
        };

      return innerHandler(request.change(headers: securitHeaders));  
      

    } on JwtException catch (e, s) {

      log.error('erro ao validar token JWT', e, s);
      return Response.forbidden(jsonEncode({}));
    } catch (e, s){
      log.error('Internal server erron in validate', e, s);
      return Response.forbidden(jsonEncode({}));
    }
    
  } 
  
}