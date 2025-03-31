import 'package:dotenv/dotenv.dart';

import 'package:jaguar_jwt/jaguar_jwt.dart';

var env = DotEnv(includePlatformEnvironment: true)..load();

class JwtHelper {

  JwtHelper._();

  static String generateJWT (int userId, int? supplierId ) {

    final claimSet = JwtClaim(
      issuer: 'cuidapet',
      subject: userId.toString(),
      expiry: DateTime.now().add(const Duration(days: 1)),
      //expiry: DateTime.now().add(const Duration(seconds: 20)),
      notBefore: DateTime.now(),
      issuedAt: DateTime.now(),
      otherClaims: <String, dynamic>{
        'supplierId': supplierId
      },
      maxAge: const Duration(days: 1)
    );

    return 'Bearer ${issueJwtHS256(claimSet, _jwtSecret)}';

  }

  static final String _jwtSecret = env['JWT_SECRET'] ?? env['jwt_secret']!;

  static JwtClaim getClaims(String token) {
    return verifyJwtHS256Signature(token, _jwtSecret);
  }  

  static String refreshToke(String accessToken){
    
    final claimSet = JwtClaim(
      issuer: accessToken,
      subject: 'refreshToken',
      expiry: DateTime.now().add(const Duration(days: 15)),
      notBefore: DateTime.now().add(Duration(hours: 18)),
      issuedAt: DateTime.now(),
      otherClaims: <String, dynamic>{},      
    );

    return 'Bearer ${issueJwtHS256(claimSet, _jwtSecret)}';
  }
}