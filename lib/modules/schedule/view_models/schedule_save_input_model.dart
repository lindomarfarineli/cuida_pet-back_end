
import 'package:cuidapet_api/application/helpers/request_mapping.dart';

class ScheduleSaveInputModel extends RequestMapping{

  int userId;
  late DateTime scheduleDatetime;
  late String name;
  late String petName;
  late int supplierId;
  late List<int> services;

  ScheduleSaveInputModel({required this.userId, required String dataRequest}): super(dataRequest);


  @override
  void map() {
    // 2025-03-04T22:00:00
    scheduleDatetime = DateTime.parse(data['schedule_data']);
    supplierId = (data['supplier_id']);
    services = List.castFrom<dynamic, int>(data['services']);
    name = data['name'];
    petName = data['pet_name'];
  }
  
}