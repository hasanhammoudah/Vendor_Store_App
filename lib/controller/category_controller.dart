import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mac_vendor_store/global_variables.dart';
import 'package:mac_vendor_store/models/category.dart';


class CategoryController {
  // load the uploaded category
  Future<List<Category>> loadCategory() async {
    try {
      http.Response response =
          await http.get(Uri.parse("$uri/api/category"), headers: {
        "Content-Type": "application/json; charset=UTF-8",
      });
      print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Category> categories =
            data.map((category) => Category.fromJson(category)).toList();
        return categories;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error loading categories: $e');
    }
  }
}
