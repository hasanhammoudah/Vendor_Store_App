import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_vendor_store/models/vendor.dart';

class VendorProvider extends StateNotifier<Vendor?> {
  VendorProvider()
      : super(Vendor(
          id: '',
          fullName: '',
          email: '',
          state: '',
          city: '',
          locallity: '',
          role: '',
          password: '',
        ));

  Vendor? get vendor => state;
  //Method to set the vendor
  void setVendor(String vendorJson) {
    state = Vendor.fromJson(vendorJson);
  }

  // method to clear the vendor
  void signOut() {
    state = null;
  }
}

// make the data accusable within the app
final vendorProvider = StateNotifierProvider<VendorProvider, Vendor?>((ref) {
  return VendorProvider();
});
