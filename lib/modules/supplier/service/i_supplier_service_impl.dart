import 'package:cuidapet_api/dtos/supplier_near_by_me_dto.dart';
import 'package:cuidapet_api/entities/category.dart';
import 'package:cuidapet_api/entities/services_supplier.dart';
import 'package:cuidapet_api/entities/supplier.dart';
import 'package:cuidapet_api/modules/supplier/data/i_supplier_repository.dart';
import 'package:cuidapet_api/modules/supplier/view_models/create_supplier_user_view_model.dart';
import 'package:cuidapet_api/modules/supplier/view_models/supplier_update_input_model.dart';
import 'package:cuidapet_api/modules/user/service/i_user_service.dart';
import 'package:cuidapet_api/modules/user/service/user_save_input_model.dart';
import 'package:injectable/injectable.dart';

import './i_supplier_service.dart';

@LazySingleton(as: ISupplierService)
class SupplierService implements ISupplierService {

  final ISupplierRepository repository;
  final IUserService userService;

  SupplierService(this.repository, this.userService);

  static const distance = 5;



  @override
  Future<List<SupplierNearByMeDto>> findNearByMe(double lat, double long) =>
   repository.findNearByPosition(lat, long, distance);

  @override
  Future<Supplier?> findById(int id) => repository.findById(id);

  @override
  Future<List<ServicesSupplier>> findBySupplierServiceId(int supplierId) => repository.findBySupplierId(supplierId);
  
  @override
  Future<bool> checkUserEmailExist(String email) => repository.checkUserEmailExist(email);
  
  @override
  Future<void> createUserSupplier(CreateSupplierUserViewModel model) async {
   final supplierEntity = Supplier(
    name: model.supplierName,
    category: Category(id: model.category)
   );

    final supplierId = await repository.saveSupplier(supplierEntity);

    final user = UserSaveInputModel(
      email: model.email,
      password: model.password,
      supplierId: supplierId
    );

    await userService.createUser(user);
  }

  @override
  Future<Supplier> update(SupplierUpdateInputModel model) async {
   
    return await repository.update(Supplier(
      id: model.supplierId,
      name: model.name,
      address: model.address,
      logo: model.logo,
      phone: model.phone,
      lat: model.lat,
      long: model.long,
      category: Category(id: model.categoryId)
    ));
  }  
}

