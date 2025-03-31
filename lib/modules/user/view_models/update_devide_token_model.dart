import 'package:cuidapet_api/application/helpers/request_mapping.dart';
import 'package:cuidapet_api/modules/user/view_models/platform.dart';

class UpdateDevideTokenModel extends RequestMapping {

  int userId;
  late String token;
  late Platform platform;

  UpdateDevideTokenModel({required this.userId, required String dataRequest}): super(dataRequest);

  @override
  void map() {
   token = data['token'];
   platform = data['platform'].toLowerCase() == 'ios' ? Platform.ios:Platform.android;   
  }
  
  
}