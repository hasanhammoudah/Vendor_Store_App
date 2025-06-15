import 'dart:convert';

class Product {
  final String id;
  final String productName;
  final int productPrice;
  final int quantity;
  final String description;
  final String category;
  final String vendorId;
  final String fullName;
  final String subCategory;
  final List<String> images;
  final double? averageRating;
  final int? totalRating;
  final bool hasDiscount;
  final int discountedPrice;
  final bool isNewProduct;
  final String? newLabelExpiresAt;
  final String? returnPolicy;
  final List<String> tags;
  final DateTime? nextAvailableAt;
  final bool hasNextAvailableLabel;
  final bool isPublished;
  final Map<String, dynamic>? extraAttributes;
  final String? brand;
  final String? warrantyPeriod;
  final String? shippingInfo;
  final String? originCountry;
  final bool recommend;

  Product({
    required this.id,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.description,
    required this.category,
    required this.vendorId,
    required this.fullName,
    required this.subCategory,
    required this.images,
    this.averageRating,
    this.totalRating,
    required this.hasDiscount,
    required this.discountedPrice,
    required this.isNewProduct,
    this.newLabelExpiresAt,
    this.returnPolicy,
    required this.tags,
    this.nextAvailableAt,
    required this.hasNextAvailableLabel,
    required this.isPublished,
    this.extraAttributes,
    this.brand,
    this.warrantyPeriod,
    this.shippingInfo,
    this.originCountry,
    required this.recommend,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'productName': productName,
      'productPrice': productPrice,
      'quantity': quantity,
      'description': description,
      'category': category,
      'vendorId': vendorId,
      'fullName': fullName,
      'subCategory': subCategory,
      'images': images,
      'averageRating': averageRating,
      'totalRating': totalRating,
      'hasDiscount': hasDiscount,
      'discountedPrice': discountedPrice,
      'isNewProduct': isNewProduct,
      'newLabelExpiresAt': newLabelExpiresAt,
      'returnPolicy': returnPolicy,
      'tags': tags,
      'nextAvailableAt': nextAvailableAt?.toIso8601String(),
      'hasNextAvailableLabel': hasNextAvailableLabel,
      'isPublished': isPublished,
      'extraAttributes': extraAttributes,
      'brand': brand,
      'warrantyPeriod': warrantyPeriod,
      'shippingInfo': shippingInfo,
      'originCountry': originCountry,
      'recommend': recommend,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['_id'] as String,
      productName: map['productName'] as String,
      productPrice: map['productPrice'] is int
          ? map['productPrice']
          : (map['productPrice'] as double).toInt(),
      quantity: map['quantity'] is int
          ? map['quantity']
          : (map['quantity'] as double).toInt(),
      description: map['description'] as String,
      category: map['category'] as String,
      vendorId: map['vendorId'] as String,
      fullName: map['fullName'] as String,
      subCategory: map['subCategory'] as String,
      images: List<String>.from((map['images'] as List<dynamic>)),
      averageRating: map['averageRating'] == null
          ? null
          : (map['averageRating'] is int
              ? (map['averageRating'] as int).toDouble()
              : map['averageRating'] as double),
      totalRating: map['totalRating'] == null
          ? null
          : (map['totalRating'] is int
              ? map['totalRating']
              : (map['totalRating'] as double).toInt()),
      hasDiscount: map['hasDiscount'] as bool,
      discountedPrice: map['discountedPrice'] is int
          ? map['discountedPrice']
          : (map['discountedPrice'] as double).toInt(),
      isNewProduct: map['isNewProduct'] as bool? ?? false,
      newLabelExpiresAt: map['newLabelExpiresAt'] as String?,
      returnPolicy: map['returnPolicy'] as String?,
      tags: List<String>.from((map['tags'] ?? [])),
      nextAvailableAt: map['nextAvailableAt'] != null
          ? DateTime.parse(map['nextAvailableAt'])
          : null,
      hasNextAvailableLabel: map['hasNextAvailableLabel'] as bool? ?? false,
      isPublished: map['isPublished'] as bool? ?? true,
      extraAttributes: map['extraAttributes'] != null
          ? Map<String, dynamic>.from(map['extraAttributes'])
          : null,
      brand: map['brand'] as String?,
      warrantyPeriod: map['warrantyPeriod'] as String?,
      shippingInfo: map['shippingInfo'] as String?,
      originCountry: map['originCountry'] as String?,
      recommend: map['recommend'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source) as Map<String, dynamic>);
}
