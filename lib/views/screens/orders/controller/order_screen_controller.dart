import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_vendor_store/controller/order_controller.dart';
import 'package:mac_vendor_store/provider/order_provider.dart';
import 'package:mac_vendor_store/provider/vendor_provider.dart';

Future<void> fetchOrders(WidgetRef ref) async {
  final user = ref.read(vendorProvider);
  if (user != null) {
    final OrderController orderController = OrderController();
    try {
      final orders = await orderController.getOrderByVendorId(
        vendorId: user.id,
      );
      ref.read(orderProvider.notifier).setOrders(orders);
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }
}

Future<void> deleteOrders(WidgetRef ref, String orderId, context) async {
  final OrderController orderController = OrderController();
  try {
    await orderController.deleteOrderById(id: orderId, context: context);
    // fetchOrders(ref);
    ref.read(orderProvider.notifier).removeOrder(orderId);
  } catch (e) {
    print("Error deleting order: $e");
  }
}
