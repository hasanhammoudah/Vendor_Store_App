import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_vendor_store/controller/product_controller.dart';
import 'package:mac_vendor_store/core/widgets/custom_app_bar.dart';
import 'package:mac_vendor_store/provider/vendor_product_provider.dart';
import 'package:mac_vendor_store/provider/vendor_provider.dart';
import 'package:mac_vendor_store/views/screens/nav_screens/edit_product_detail_screen.dart';

class EditScreen extends ConsumerStatefulWidget {
  const EditScreen({super.key});

  @override
  ConsumerState<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends ConsumerState<EditScreen> {
  bool isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // futurePopularProducts = ProductController().getProducts();
    final products = ref.read(vendorProductProvider);
    if (products.isEmpty) {
      _fetchProduct();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchProduct() async {
    final vendor = ref.read(vendorProvider);
    final ProductController _productController = ProductController();
    try {
      final products = await _productController.loadVendorsProducts(vendor!.id);
      ref.read(vendorProductProvider.notifier).setProducts(products);
    } catch (e) {
      // Handle error
      print('Error fetching products: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(vendorProductProvider);
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Products',
        count: products.length.toString(),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : ListView.builder(
              shrinkWrap: true,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProductDetailScreen(
                            product: product,
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(product.images.isNotEmpty
                            ? product.images[0]
                            : 'https://via.placeholder.com/150'),
                      ),
                      title: Text(
                        product.productName,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        product.category.isNotEmpty
                            ? product.category
                            : 'No Category',
                      ),
                      trailing: Text('\$${product.productPrice}'),
                    ));
              },
            ),
    );
  }
}
