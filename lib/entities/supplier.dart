
import 'package:cuidapet_api/entities/category.dart';

class Supplier {
  final int? id;
  final String? name;
  final String? logo;
  final String? address;
  final String? phone;
  final double? lat;
  final double? long;
  final Category? category;

  Supplier({
    this.id,
    this.name,
    this.logo,
    this.address,
    this.phone,
    this.lat,
    this.long,
    this.category,
  });


  Supplier copyWith({
    id,
    name,
    logo,
    address,
    phone,
    lat,
    long,
    category,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      category: category ?? this.category,
    );
  }
}
