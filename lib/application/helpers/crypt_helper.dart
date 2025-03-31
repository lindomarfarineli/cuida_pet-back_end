
import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptHelper {

  CryptHelper._();
  static String generateSha256hash(String password){

    final bytes = utf8.encode(password);

    return sha256.convert(bytes).toString();

   
}

}