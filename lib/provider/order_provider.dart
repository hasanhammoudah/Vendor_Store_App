import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_vendor_store/models/orders.dart';

class OrderProvider extends StateNotifier<List<Order>> {
  OrderProvider() : super([]); // Initialize with an empty list of orders

  // set the list of orders
  void setOrders(List<Order> orders) {
    state = orders;
  }

  // delete an order
  void removeOrder(String orderId) {
    state = state.where((order) => order.id != orderId).toList();
  }

  void updateOrderStatus(String orderId,
      {bool? processing, bool? delivered, bool? cancelled}) {
    state = [
      for (final order in state)
        if (order.id == orderId)
          Order(
            id: order.id,
            email: order.email,
            fullName: order.fullName,
            state: order.state,
            city: order.city,
            locality: order.locality,
            productName: order.productName,
            productPrice: order.productPrice,
            quantity: order.quantity,
            category: order.category,
            image: order.image,
            vendorId: order.vendorId,
            buyerId: order.buyerId,
            processing: processing ?? order.processing,
            delivered: delivered ?? order.delivered,
            cancelled: cancelled ?? order.cancelled,
            productId: order.productId,
          )
        else
          order,
    ];
  }
}

final orderProvider = StateNotifierProvider<OrderProvider, List<Order>>((ref) {
  return OrderProvider();
});
