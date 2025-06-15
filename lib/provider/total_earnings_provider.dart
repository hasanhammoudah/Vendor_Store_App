import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_vendor_store/models/orders.dart';

class TotalEarningsProvider extends StateNotifier<Map<String, dynamic>> {
  TotalEarningsProvider()
      : super({
          'totalEarnings': 0.0,
          'orderCount': 0,
        });

  void calculateEarnings(List<Order> orders) {
    double earnings = 0.0;
    int orderCount = 0;

    for (Order order in orders) {
      if (order.delivered) {
        earnings += order.productPrice * order.quantity;
        orderCount++;
      }
    }

    state = {
      'totalEarnings': earnings,
      'orderCount': orderCount,
    };
  }
}

final totalEarningsProvider =
    StateNotifierProvider<TotalEarningsProvider, Map<String, dynamic>>((ref) {
  return TotalEarningsProvider();
});
