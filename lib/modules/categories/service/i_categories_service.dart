import 'package:cuidapet_api/entities/category.dart';

abstract interface class ICategoriesService {
  Future <List<Category>> findAll();
}