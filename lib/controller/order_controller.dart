import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mac_vendor_store/global_variables.dart';
import 'package:mac_vendor_store/models/orders.dart';
import 'package:mac_vendor_store/services/manage_http_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderController {
  // method to get orders by vendorId
  Future<List<Order>> getOrderByVendorId({required String vendorId}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      // Send an HTTP GET request to the server
      http.Response response = await http.get(
        Uri.parse('$uri/api/orders/by-vendor/$vendorId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token!,
        },
      );
      // Check if the response status code is 200 (OK)
      if (response.statusCode == 200) {
        print("Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        // Parse the response body and convert it to a list of Order objects
        List<Order> orders = (jsonDecode(response.body) as List)
            .map((order) => Order.fromJson(order))
            .toList();
        return orders;
      } else {
        // Handle error response
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      throw Exception('Error fetching orders: $e');
    }
  }

  // method to delete order by id
  Future<void> deleteOrderById({required String id, required context}) async {
    try {
      // Send an HTTP DELETE request to the server
      http.Response response = await http.delete(
        Uri.parse('$uri/api/orders/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Order deleted successfully');
        },
        onError: (error) {
          showSnackBar(context, error);
        },
      );
    } catch (e) {
      // Handle any exceptions that occur during the request
      showSnackBar(context, 'Error deleting order: $e');
    }
  }

  Future<void> updateDeliveryStatus(
      {required String id, required context}) async {
    try {
      // Send an HTTP PUT request to the server
      http.Response response = await http.patch(
        Uri.parse('$uri/api/orders/$id/delivered'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        // body: ({
        //   'delivered': true,
        // }),
      );
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Delivery status updated successfully');
        },
        onError: (error) {
          showSnackBar(context, error);
        },
      );
    } catch (e) {
      // Handle any exceptions that occur during the request
      showSnackBar(context, 'Error updating delivery status: $e');
    }
  }

  Future<void> cancelOrder({required String id, required context}) async {
    try {
      // Send an HTTP PUT request to the server
      http.Response response = await http.patch(
        Uri.parse('$uri/api/orders/$id/processing'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        // body: ({
        //   'processing': false,
        // }),
      );
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Order cancelled successfully');
        },
        onError: (error) {
          showSnackBar(context, error);
        },
      );
    } catch (e) {
      // Handle any exceptions that occur during the request
      showSnackBar(context, 'Error updating cancel status: $e');
    }
  }

  Future<void> markOrderCancelled(
      {required String id, required context}) async {
    try {
      http.Response response = await http.patch(
        Uri.parse('$uri/api/orders/$id/cancelled'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Order marked as cancelled');
        },
        onError: (error) {
          showSnackBar(context, error);
        },
      );
    } catch (e) {
      showSnackBar(context, 'Error cancelling order: $e');
    }
  }
}
