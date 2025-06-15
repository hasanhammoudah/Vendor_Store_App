import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_vendor_store/models/product.dart';

class VendorProductProvider extends StateNotifier<List<Product>> {
  VendorProductProvider() : super([]);

  //set the list of products
  void setProducts(List<Product> products) {
    state = products;
  }
}

final vendorProductProvider = StateNotifierProvider<VendorProductProvider, List<Product>>(
  (ref) => VendorProductProvider(),
);
