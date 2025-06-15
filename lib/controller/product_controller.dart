import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:mac_vendor_store/global_variables.dart';
import 'package:mac_vendor_store/models/product.dart';
import 'package:mac_vendor_store/services/manage_http_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductController {
  Future<void> uploadProduct({
    required String productName,
    required String description,
    required int productPrice,
    required int quantity,
    required String category,
    required String vendorId,
    required String fullName,
    required String subCategory,
    required List<File>? pickedImages,
    bool hasDiscount = false,
    int discountedPrice = 0,
    String? brand,
    String? warrantyPeriod,
    String? shippingInfo,
    String? originCountry,
    DateTime? nextAvailableAt,
    Map<String, dynamic>? extraAttributes,
    bool isNewProduct = false,
    bool hasNextAvailableLabel = false,
    bool isPublished = true,
    String? newLabelExpiresAt,
    String? returnPolicy,
    List<String> tags = const [],
    bool recommend = false,
    required context,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (pickedImages != null) {
      final cloudinary = CloudinaryPublic("doooplg4p", 'uoqwwgyk');
      List<String> images = [];

      for (var image in pickedImages) {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            image.path,
            folder: 'productImages',
          ),
        );
        images.add(response.secureUrl);
      }

      if (hasDiscount && discountedPrice >= productPrice) {
        showSnackBar(
            context, 'Discounted price must be less than original price');
        return;
      }

      if (category.isNotEmpty && subCategory.isNotEmpty) {
        final Product product = Product(
            id: '',
            productName: productName,
            productPrice: productPrice,
            quantity: quantity,
            description: description,
            category: category,
            vendorId: vendorId,
            fullName: fullName,
            subCategory: subCategory,
            images: images,
            hasDiscount: hasDiscount,
            discountedPrice: discountedPrice,
            brand: brand,
            warrantyPeriod: warrantyPeriod,
            shippingInfo: shippingInfo,
            originCountry: originCountry,
            nextAvailableAt: nextAvailableAt,
            extraAttributes: extraAttributes,
            isNewProduct: isNewProduct,
            newLabelExpiresAt: newLabelExpiresAt,
            returnPolicy: returnPolicy,
            tags: tags,
            hasNextAvailableLabel: hasNextAvailableLabel,
            isPublished: isPublished,
            recommend: recommend);

        final response = await http.post(
          Uri.parse("$uri/api/add-product"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token!,
          },
          body: product.toJson(),
        );

        manageHttpResponse(
          response: response,
          context: context,
          onSuccess: () {
            showSnackBar(context, 'Product uploaded successfully');
          },
          onError: (e) {
            showSnackBar(context, 'Failed to upload product $e');
          },
        );
      } else {
        showSnackBar(context, 'Please select category and subcategory');
      }
    } else {
      showSnackBar(context, 'Please select image');
    }
  }

  Future<List<Product>> loadVendorsProducts(String vendorId) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString("auth_token");

      http.Response response = await http.get(
        Uri.parse('$uri/api/products/vendor/$vendorId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token!,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Product> vendorsProducts =
            data.map((product) => Product.fromMap(product)).toList();
        return vendorsProducts;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load vendors products');
      }
    } catch (e) {
      throw Exception('Error loading vendors products: $e');
    }
  }

  Future<List<String>> uploadImagesToCloudinary(
    List<File>? pickedImages,
    Product product,
  ) async {
    final cloudinary = CloudinaryPublic("doooplg4p", 'uoqwwgyk');
    List<String> uploadedImages = [];

    for (var image in pickedImages!) {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          folder: product.productName,
        ),
      );
      uploadedImages.add(response.secureUrl);
    }

    return uploadedImages;
  }

  Future<void> updateProduct({
    required Product product,
    required List<File>? pickedImages,
    required BuildContext context,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (pickedImages != null) {
      await uploadImagesToCloudinary(pickedImages, product);
    }

    final updateDateData = product.toMap();

    http.Response response = await http.put(
      Uri.parse("$uri/api/edit-product/${product.id}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token!,
      },
      body: jsonEncode(updateDateData),
    );

    manageHttpResponse(
      response: response,
      context: context,
      onSuccess: () {
        showSnackBar(context, 'Product updated successfully');
      },
      onError: (e) {
        showSnackBar(context, 'Failed to update product $e');
      },
    );
  }

  Future<void> deleteProduct({
    required String productId,
    required BuildContext context,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.delete(
        Uri.parse('$uri/api/delete-product/$productId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token!,
        },
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Product deleted successfully');
        },
        onError: (e) {
          showSnackBar(context, 'Failed to delete product: $e');
        },
      );
    } catch (e) {
      showSnackBar(context, 'Something went wrong: $e');
    }
  }
}
