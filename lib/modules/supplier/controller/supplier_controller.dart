import 'dart:async';
import 'dart:convert';
import 'package:cuidapet_api/application/logs/i_log.dart';
import 'package:cuidapet_api/entities/supplier.dart';
import 'package:cuidapet_api/modules/supplier/view_models/create_supplier_user_view_model.dart';
import 'package:cuidapet_api/modules/supplier/view_models/supplier_update_input_model.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:cuidapet_api/modules/supplier/service/i_supplier_service.dart';
part 'supplier_controller.g.dart';

@Injectable()
class SupplierController {

  ISupplierService service;
  ILog log;
  SupplierController({
    required this.service,
    required this.log
  });
  

   @Route.get('/')
   Future<Response> findNearByMe(Request request) async { 

    try{

      final lat = double.tryParse(request.url.queryParameters['lat'] ?? '');
      final long = double.tryParse(request.url.queryParameters['long'] ?? '');

      if(lat == null || long == null) {
        return Response.badRequest(
          body: jsonEncode({"message": "latitude e longitude não podem ser nulos"}));
      }

      final suppliers = await service.findNearByMe(lat, long);

      final result = suppliers.map((f) => {
        "id": f.id,
        "name": f.name,
        "logo": f.logo,
        "distance": f.distance,
        "category": f.categoryId
      }).toList();



      return Response.ok(jsonEncode(result));

    } catch (e, s) {

      log.error("erro ao buscar fornecedores mais proximos", e, s);
      return Response.internalServerError(body: {       
        "message": "erro ao buscar fornecedores mais próximos"
      });
    }
   }

   @Route.get('/<id|[0-9]+>')
   Future<Response> findById(Request request, String id) async{

      try{

        final supplier = await service.findById(int.parse(id));

        if (supplier == null ){
           return Response.ok(jsonEncode({}));
        }
        return Response.ok(_supplierMapper(supplier));

      }catch(e,s){
        log.error('erro ao buscar fornecedor ', e, s);
        return Response.internalServerError(body: {"message": "Erro ao buscar fonecedor"});
      }
   }

   @Route.get('/<supplierId|[0-9]+>/services')
   Future<Response> findServiceBySupplierId (Request request, String supplierId) async{

      try {

        final servicesSupplier = await service.findBySupplierServiceId(int.parse(supplierId));            

        
        return Response.ok(jsonEncode(
          servicesSupplier.map(
          (e) => {
              'id': e.id,
              'supplierId': e.supplierId,
              'name': e.name,
              'price': e.price
             }).toList()
         ));

      } catch (e, s) {        
        log.error('erro ao buscar serviços do fornecedor', e, s);
        return Response.internalServerError(body: jsonEncode({
          'message': 'erro ao buscar serviço do fornecedor.'
        }));
      }
   }

   @Route.get('/user')
   Future<Response> checkEmailExists(Request request) async{

      try{
        final email = request.url.queryParameters['email'];

        if (email == null) {
          return Response(400, body: jsonEncode({'message': "email obrigatório"}));
        }

        final isEmailExist = await service.checkUserEmailExist(email);

        return isEmailExist? Response.ok(''): Response(204);
        
      } catch (e,s) {
        log.error('erro ao confirmar se usuario existe', e, s);
        return Response.internalServerError(body: 'erro ao confirmar se usuario existe');
      }      
      
   }

   @Route.post('/user')
   Future<Response> createNewUser(Request request) async{
      try{

        final model = CreateSupplierUserViewModel( await request.readAsString());

        await service.createUserSupplier(model);

        return Response.ok(jsonEncode({}));
      } catch (e, s){
        log.error('erro ao criar novo fornecedor', e,s);
        return Response.internalServerError(body: {"message":'erro ao criar novo fornecedor'});
      }
   }

   @Route.put('/')
   Future<Response> updateSupplier(Request request) async{
      try{       
        
        final supplier = int.tryParse(request.headers['supplier'] ?? '');        

        if (supplier == null) {
          return Response(400, body:{'message': 'codigo do usuario fornecedor não pode ser nulo'});
        }

        final model = SupplierUpdateInputModel(supplierId: supplier, dataRequest: await request.readAsString());

        final supplierResponse = await service.update(model);

        return Response.ok(_supplierMapper(supplierResponse));

      } catch (e,s) {
        log.error('erro ao atualizar dados do fornecedor', e, s);
        return Response.internalServerError(body: {'message': 'Erro ao atualizar dados do fornecedor'});
      }
   }
      

  

   Router get router => _$SupplierControllerRouter(this);

  String _supplierMapper(Supplier supplier) {
    return jsonEncode(
      {
        'id': supplier.id,
        'name': supplier.name,
        'logo': supplier.logo,
        'address': supplier.address,
        'phone': supplier.phone,
        'lat': supplier.lat,
        'long': supplier.long,
        'Category':{
          'id': supplier.category?.id,
          'name': supplier.category?.name,
          'type': supplier.category?.type
        }
      });

  }
}
