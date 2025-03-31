import 'package:cuidapet_api/dtos/supplier_near_by_me_dto.dart';
import 'package:cuidapet_api/entities/services_supplier.dart';
import 'package:cuidapet_api/entities/supplier.dart';
import 'package:cuidapet_api/modules/supplier/view_models/create_supplier_user_view_model.dart';
import 'package:cuidapet_api/modules/supplier/view_models/supplier_update_input_model.dart';

abstract interface class ISupplierService {

  Future<List<SupplierNearByMeDto>> findNearByMe(double lat, double long);
  Future<Supplier?> findById(int id);
  Future<List<ServicesSupplier>> findBySupplierServiceId(int supplierId);
  Future<bool> checkUserEmailExist(String email);
  Future<void> createUserSupplier (CreateSupplierUserViewModel model);
  Future<Supplier> update(SupplierUpdateInputModel model);

}