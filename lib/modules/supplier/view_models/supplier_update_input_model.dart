
import 'package:cuidapet_api/application/helpers/request_mapping.dart';

class SupplierUpdateInputModel extends RequestMapping{

  int supplierId;
  late String name;
  late String logo;
  late String address;
  late String phone;
  late double lat;
  late double long;
  late int categoryId;


  SupplierUpdateInputModel({required this.supplierId, required String dataRequest}): super(dataRequest);

  

  @override
  void map() {
    
    name = data['name'];
    logo = data['logo'];
    address = data['address'];
    phone = data['phone'];
    lat = data['lat'];
    long = data['long'];
    categoryId = data['category'];
  }
  
}