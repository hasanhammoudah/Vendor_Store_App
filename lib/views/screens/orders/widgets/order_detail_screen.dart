import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_vendor_store/controller/order_controller.dart';
import 'package:mac_vendor_store/models/orders.dart';
import 'package:mac_vendor_store/provider/order_provider.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key, required this.order});
  final Order order;

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  final OrderController orderController = OrderController();
  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);
    // Find the order in the list of orders
    final updatedOrder = orders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.order.productName,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: 335,
            height: 153,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(),
            child: SizedBox(
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 335,
                      height: 153,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: const Color(
                          0xFFEFF0F2,
                        ),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 13,
                            top: 9,
                            child: Container(
                              width: 78,
                              height: 78,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFBCC5FF,
                                  ),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    left: 10,
                                    top: 5,
                                    child: Image.network(
                                      widget.order.image,
                                      width: 58,
                                      height: 67,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 101,
                            top: 14,
                            child: SizedBox(
                              width: 216,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: double.infinity,
                                            child: Text(
                                              widget.order.productName,
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              widget.order.category,
                                              style: GoogleFonts.montserrat(
                                                color: const Color(
                                                  0xFF7F808C,
                                                ),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 2,
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "\$${widget.order.productPrice.toStringAsFixed(2)}",
                                              style: GoogleFonts.montserrat(
                                                color: const Color(
                                                  0xFF0B0C1E,
                                                ),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 13,
                    top: 113,
                    child: Container(
                      width: 100,
                      height: 25,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: updatedOrder.delivered == true
                            ? const Color(0xFF3C55EF)
                            : updatedOrder.processing == true
                                ? Colors.purple
                                : Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 9,
                            top: 2,
                            child: Text(
                              updatedOrder.delivered == true
                                  ? 'Delivered'
                                  : updatedOrder.processing == true
                                      ? 'Processing'
                                      : 'Cancelled',
                              style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  letterSpacing: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 20,
            ),
            child: Container(
              width: 336,
              height: 170,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFFEFF0F2),
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Address',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            letterSpacing: 1.7,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          "${widget.order.state}, ${widget.order.city} ${widget.order.locality}",
                          style: GoogleFonts.lato(
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF7F808C),
                          ),
                        ),
                        Text(
                          "To : ${widget.order.fullName}",
                          style: GoogleFonts.montserrat(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Order Id: ${widget.order.id}",
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: updatedOrder.delivered == true ||
                                updatedOrder.processing == false
                            ? null
                            : () async {
                                await orderController
                                    .updateDeliveryStatus(
                                  id: widget.order.id,
                                  context: context,
                                )
                                    .whenComplete(() {
                                  ref
                                      .read(orderProvider.notifier)
                                      .updateOrderStatus(
                                        widget.order.id,
                                        delivered: true,
                                      );
                                });
                              },
                        child: Text(
                          updatedOrder.delivered == true
                              ? "Delivered"
                              : "Mark as Delivered?",
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: updatedOrder.processing == false ||
                                updatedOrder.delivered == true
                            ? null
                            : () async {
                                await orderController
                                    .cancelOrder(
                                  id: widget.order.id,
                                  context: context,
                                )
                                    .whenComplete(
                                  () {
                                    ref
                                        .read(orderProvider.notifier)
                                        .updateOrderStatus(
                                          widget.order.id,
                                          processing: false,
                                        );
                                  },
                                );
                              },
                        child: Text(
                          updatedOrder.processing == false
                              ? "Canceled"
                              : "Cancel",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
