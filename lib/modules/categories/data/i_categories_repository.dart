import 'package:cuidapet_api/entities/category.dart';

abstract interface class ICategoriesRepository {

  Future<List<Category>> findAll();

}