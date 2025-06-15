// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Order {
  final String id;
  final String email;
  final String fullName;
  final String state;
  final String city;
  final String locality;
  final String productName;
  final int productPrice;
  final int quantity;
  final String category;
  final String image;
  final String vendorId;
  final String buyerId;
  final bool processing;
  final bool delivered;
  final bool cancelled;


  Order({
  required this.id,
  required this.email,
  required this.fullName,
  required this.state,
  required this.city,
  required this.locality,
  required this.productName,
  required this.productPrice,
  required this.quantity,
  required this.category,
  required this.image,
  required this.vendorId,
  required this.buyerId,
  required this.processing,
  required this.delivered,
  required this.cancelled, 
});


  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'fullName': fullName,
      'state': state,
      'city': city,
      'locality': locality,
      'productName': productName,
      'productPrice': productPrice,
      'quantity': quantity,
      'category': category,
      'image': image,
      'vendorId': vendorId,
      'buyerId': buyerId,
      'processing': processing,
      'delivered': delivered,
      'cancelled': cancelled,

    };
  }

  factory Order.fromJson(Map<String, dynamic> map) {
    return Order(
      id: map['_id'] as String,
      email: map['email'] as String,
      fullName: map['fullName'] as String,
      state: map['state'] as String,
      city: map['city'] as String,
      locality: map['locality'] as String,
      productName: map['productName'] as String,
      productPrice: map['productPrice'] as int,
      quantity: map['quantity'] as int,
      category: map['category'] as String,
      image: map['image'] as String,
      vendorId: map['vendorId'] as String,
      buyerId: map['buyerId'] as String,
      processing: map['processing'] as bool,
      delivered: map['delivered'] as bool,
      cancelled: map['cancelled'] ?? false, // ✅ يستخدم false إذا لم يكن موجود

    );
  }

  String toJson() => json.encode(toMap());

  // factory Order.fromJson(String source) =>
  //     Order.fromMap(json.decode(source) as Map<String, dynamic>);
}
