import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_vendor_store/global_variables.dart';
import 'package:mac_vendor_store/models/vendor.dart';
import 'package:http/http.dart' as http;
import 'package:mac_vendor_store/provider/vendor_provider.dart';
import 'package:mac_vendor_store/services/manage_http_response.dart';
import 'package:mac_vendor_store/views/screens/main_vendor_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final providerContainer = ProviderContainer();

class VendorAuthController {
  Future<void> signUpVendor(
      {required fullName,
      required String email,
      required String password,
      context}) async {
    try {
      Vendor vendor = Vendor(
        id: '',
        fullName: fullName,
        email: email,
        state: '',
        city: '',
        locallity: '',
        role: '',
        password: password,
      );
      http.Response response = await http.post(
        Uri.parse("$uri/api/vendor/signup"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: vendor.toJson(),
      );
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Vendor Account Created Successfully');
        },
        onError: (error) {
          showSnackBar(context, error);
        },
      );
    } catch (e) {
      showSnackBar(context, '$e');
    }
  }

  Future<void> signInVendor(
      {required String email,
      required String password,
      required context}) async {
    try {
      http.Response response =
          await http.post(Uri.parse("$uri/api/vendor/signin"),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(
                <String, String>{
                  'email': email,
                  'password': password,
                },
              ));
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String token = jsonDecode(response.body)['token'];
          prefs.setString('auth_token', token);
          final vendorJson = jsonEncode(jsonDecode(response.body)['vendor']);
          providerContainer.read(vendorProvider.notifier).setVendor(vendorJson);
          await prefs.setString('vendor', vendorJson);
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) {
            return MainVendorScreen();
          }), (route) => false);
          showSnackBar(context, 'Vendor Account Signed In Successfully');
        },
        onError: (error) {
          showSnackBar(context, error);
        },
      );
    } catch (e) {
      showSnackBar(context, '$e');
    }
  }
}
