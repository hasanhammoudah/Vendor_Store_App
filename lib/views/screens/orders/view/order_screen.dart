import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_vendor_store/core/widgets/custom_app_bar.dart';
import 'package:mac_vendor_store/provider/order_provider.dart';
import 'package:mac_vendor_store/views/screens/orders/controller/order_screen_controller.dart';
import 'package:mac_vendor_store/views/screens/orders/widgets/order_item_card.dart';


class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});
  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  @override
  void initState() {
    super.initState();
    fetchOrders(ref);
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'My Orders',
      ),
      body: orders.isEmpty
          ? const Center(child: Text('No orders found'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return OrderItemCard(
                  order: order,
                );
              },
            ),
    );
  }
}
