
import 'package:cuidapet_api/application/helpers/request_mapping.dart';

class LoginViewModel extends RequestMapping {

  late String email;
  late String password;
  late bool socialLogin;
  late bool supplierUser;
  late String avatar;
  late String socialType;
  late String socialKey;
  

  LoginViewModel(super.dataRequest); 
 

  @override
  void map() {
    
    email = data['email'];
    password = data['password'] ?? '';
    socialLogin = data['social_login'];  
    supplierUser = data['supplier_user'];
    avatar =  data['avatar'] ?? '';
    socialType = data['social_type'];  
    socialKey = data['social_key'] ?? "";
    
  }
  
}