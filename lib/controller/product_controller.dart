import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:mac_vendor_store/global_variables.dart';
import 'package:mac_vendor_store/models/product.dart';
import 'package:mac_vendor_store/services/manage_http_response.dart';

class ProductController {
  Future<void> uploadProduct(
      {required String productName,
      required String description,
      required int productPrice,
      required int quantity,
      required String category,
      required String vendorId,
      required String fullName,
      required String subCategory,
      required List<File>? pickedImages,
      required context}) async {
    if (pickedImages != null) {
      final cloudinary = CloudinaryPublic("doooplg4p", 'uoqwwgyk');
      List<String> images = [];
      for (var i = 0; i < pickedImages.length; i++) {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            pickedImages[i].path,
            folder: 'productImages',
          ),
        );
        images.add(response.secureUrl);
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
          );
          final response = await http.post(
            Uri.parse("$uri/api/add-product"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
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
              });
        } else {
          showSnackBar(context, 'Please select category and subcategory');
        }
      }
    } else {
      showSnackBar(context, 'Please select image');
    }
  }
}
