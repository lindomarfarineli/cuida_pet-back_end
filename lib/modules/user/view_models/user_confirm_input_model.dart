
import 'package:cuidapet_api/application/helpers/request_mapping.dart';

class UserConfirmInputModel extends RequestMapping{
  
  int userId;
  String accessToken;

  String? iosDeviceToken;
  String? androidDeviceToken;

  UserConfirmInputModel({required this.userId, required this.accessToken, required String data}): super(data);
  
  @override
  void map() {
    iosDeviceToken = data['ios_token'];
    androidDeviceToken = data['android_token'];
  }

}