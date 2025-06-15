import 'dart:convert';
import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_vendor_store/global_variables.dart';
import 'package:mac_vendor_store/models/vendor.dart';
import 'package:http/http.dart' as http;
import 'package:mac_vendor_store/provider/vendor_provider.dart';
import 'package:mac_vendor_store/services/manage_http_response.dart';
import 'package:mac_vendor_store/views/screens/authentication/login_screen.dart';
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
        state: 'Amman',
        city: '',
        locallity: '',
        role: '',
        password: password,
        token: '',
      );
      http.Response response = await http.post(
        Uri.parse("$uri/api/v2/vendor/signup"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: vendor.toJson(),
      );
      print(vendor.toJson());

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
      required WidgetRef ref,
      required context}) async {
    try {
      print('SIGNING IN WITH EMAIL: "$email"');

      http.Response response =
          await http.post(Uri.parse("$uri/api/v2/vendor/signin"),
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
          final vendorJson = jsonEncode(jsonDecode(response.body));
          ref.read(vendorProvider.notifier).setVendor(vendorJson);
          await prefs.setString('vendor', vendorJson);

          if (ref.read(vendorProvider)!.token.isNotEmpty) {
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) {
              return MainVendorScreen();
            }), (route) => false);
            showSnackBar(context, 'Vendor Account Signed In Successfully');
          }
        },
        onError: (error) {
          showSnackBar(context, error);
        },
      );
    } catch (e) {
      showSnackBar(context, '$e');
    }
  }

  // Update user's state,city and locality
  Future<void> updateVendorData(
      {required context,
      required String id,
      required File? storeImage,
      required String storeDescription,
      required WidgetRef ref}) async {
    try {
      final cloudinary = CloudinaryPublic("doooplg4p", 'uoqwwgyk');
      CloudinaryResponse imageResponses = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          storeImage!.path,
          identifier: 'pickedImage',
          folder: 'storeImage',
        ),
      );
      String image = imageResponses.secureUrl;
      final http.Response response = await http.put(
        Uri.parse(
          '$uri/api/vendor/$id',
        ),
        body: jsonEncode(<String, String>{
          'storeImage': image,
          'storeDescription': storeDescription,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          final updatedUser = jsonDecode(response.body);
          final userJson = jsonEncode(updatedUser);
          ref.read(vendorProvider.notifier).setVendor(userJson);
          showSnackBar(context, 'Date Updated successfully');
        },
        onError: (error) {
          showSnackBar(context, error);
        },
      );
    } catch (e) {
      print("Error:$e");
    }
  }

  //SignOut
  Future<void> signOutUser({required context, required WidgetRef ref}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user');
      providerContainer.read(vendorProvider.notifier).signOut();
      //navigation the user back to the login screen
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) {
        return const LoginScreen();
      }), (route) => false);
      showSnackBar(context, 'signout successfully');
    } catch (e) {
      showSnackBar(context, 'error signing out');
    }
  }

  getUserData(context, WidgetRef ref) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString('auth_token');
      if (token == null) {
        preferences.setString('auth_token', '');
      }
      var tokenResponse = await http.post(Uri.parse('$uri/vendor-tokenIsValid'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token!
          });
      var response = jsonDecode(tokenResponse.body);
      if (response == true) {
        http.Response vendorResponse = await http
            .get(Uri.parse('$uri/get-vendor'), headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        });
        ref.read(vendorProvider.notifier).setVendor(vendorResponse.body);
      }
    } catch (e) {
      print("Error:$e");
      showSnackBar(context, 'An error occurred while fetching user data');
    }
  }
}
