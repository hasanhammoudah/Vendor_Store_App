import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_vendor_store/controller/product_controller.dart';
import 'package:mac_vendor_store/provider/vendor_product_provider.dart';
import 'package:mac_vendor_store/provider/vendor_provider.dart';
import 'package:mac_vendor_store/views/screens/nav_screens/edit_product_detail_screen.dart';
import 'package:mac_vendor_store/views/screens/nav_screens/upload_screen.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
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
      print('Error fetching products: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void deleteProduct(String productId) async {
    final ProductController _productController = ProductController();

    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ProductController()
            .deleteProduct(productId: productId, context: context);
        await _fetchProduct();
      } catch (e) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to delete product'),
          ),
        );
      }
    }
  }

  void navigateToAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UploadScreen()),
    ).then((_) => _fetchProduct());
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(vendorProductProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('My Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: navigateToAddProduct,
            tooltip: 'Add Product',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : ListView.builder(
              shrinkWrap: true,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
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
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProductDetailScreen(
                              product: product,
                            ),
                          ),
                        ).then((_) => _fetchProduct());
                      } else if (value == 'delete') {
                        deleteProduct(product.id);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
