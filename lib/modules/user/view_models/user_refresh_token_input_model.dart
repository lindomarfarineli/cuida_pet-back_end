
import 'package:cuidapet_api/application/helpers/request_mapping.dart';

class UserRefreshTokenInputModel extends RequestMapping {

  int user;
  int? suplier;
  String accessToken;
  
  late String refreshToken;

  UserRefreshTokenInputModel({
    required String dataRequest,
    required this.user,
    required this.accessToken, 
    this.suplier 
  }) : super(dataRequest);

  @override
  void map() {
    refreshToken = data['refresh_token'];
  }
  
}