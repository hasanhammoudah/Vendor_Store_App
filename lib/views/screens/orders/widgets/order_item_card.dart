import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_vendor_store/models/orders.dart';
import 'package:mac_vendor_store/provider/order_provider.dart';
import 'package:mac_vendor_store/views/screens/orders/controller/order_screen_controller.dart';
import 'package:mac_vendor_store/views/screens/orders/widgets/order_detail_screen.dart';

class OrderItemCard extends ConsumerStatefulWidget {
  const OrderItemCard({super.key, required this.order});
  final Order order;

  @override
  ConsumerState<OrderItemCard> createState() => _OrderItemCardState();
}

class _OrderItemCardState extends ConsumerState<OrderItemCard> {
  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);
    // Find the order in the list of orders
    final updatedOrder = orders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(order: widget.order),
            ),
          );
        },
        child: Container(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                widget.order.delivered == true
                    ? Positioned(
                        top: 120,
                        right: 20,
                        child: InkWell(
                          onTap: () {
                            deleteOrders(ref, widget.order.id, context);
                          },
                          child: Image.asset(
                            'assets/icons/delete.png',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
