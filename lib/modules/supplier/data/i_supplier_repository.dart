import 'package:cuidapet_api/dtos/supplier_near_by_me_dto.dart';
import 'package:cuidapet_api/entities/services_supplier.dart';
import 'package:cuidapet_api/entities/supplier.dart';


abstract interface class ISupplierRepository {
  Future<List<SupplierNearByMeDto>> findNearByPosition (double lat, double long, int distance);
  Future<Supplier?> findById(int id);
  Future<List<ServicesSupplier>> findBySupplierId(int supplierId);
  Future<bool> checkUserEmailExist (String email);
  Future<int> saveSupplier (Supplier supplier);
  Future<Supplier> update (Supplier supplier);


}