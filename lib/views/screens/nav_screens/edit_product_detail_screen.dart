// ✅ نسخة محدثة من EditProductDetailScreen بكامل الحقول من UploadScreen
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mac_vendor_store/controller/product_controller.dart';
import 'package:mac_vendor_store/models/product.dart';

class EditProductDetailScreen extends StatefulWidget {
  const EditProductDetailScreen({super.key, required this.product});
  final Product product;

  @override
  State<EditProductDetailScreen> createState() =>
      _EditProductDetailScreenState();
}

class _EditProductDetailScreenState extends State<EditProductDetailScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ProductController _productController = ProductController();

  late TextEditingController productNameController;
  late TextEditingController productPriceController;
  late TextEditingController quantityController;
  late TextEditingController productDescriptionController;
  late TextEditingController discountedPriceController;
  late TextEditingController brandController;
  late TextEditingController warrantyPeriodController;
  late TextEditingController returnPolicyController;
  late TextEditingController shippingInfoController;
  late TextEditingController originCountryController;

  final TextEditingController tagInputController = TextEditingController();
  final TextEditingController sizeInputController = TextEditingController();
  final TextEditingController colorInputController = TextEditingController();

  List<File> pickedImages = [];
  List<String> existingImages = [];

  List<String> tags = [];
  List<String> sizes = [];
  List<String> colors = [];

  bool hasDiscount = false;
  bool isPublished = true;
  bool recommend = false;
  bool isNewProduct = false;
  bool hasNextAvailableLabel = false;
  DateTime? newLabelExpiresAt;
  DateTime? nextAvailableAt;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    productNameController = TextEditingController(text: product.productName);
    productPriceController =
        TextEditingController(text: product.productPrice.toString());
    quantityController =
        TextEditingController(text: product.quantity.toString());
    productDescriptionController =
        TextEditingController(text: product.description);
    discountedPriceController =
        TextEditingController(text: product.discountedPrice.toString());
    brandController = TextEditingController(text: product.brand ?? '');
    warrantyPeriodController =
        TextEditingController(text: product.warrantyPeriod ?? '');
    returnPolicyController =
        TextEditingController(text: product.returnPolicy ?? '');
    shippingInfoController =
        TextEditingController(text: product.shippingInfo ?? '');
    originCountryController =
        TextEditingController(text: product.originCountry ?? '');
    existingImages = [...product.images];
    hasDiscount = product.hasDiscount;
    isPublished = product.isPublished;
    recommend = product.recommend;
    isNewProduct = product.isNewProduct;
    hasNextAvailableLabel = product.hasNextAvailableLabel;
    newLabelExpiresAt = product.newLabelExpiresAt != null
        ? DateTime.tryParse(product.newLabelExpiresAt!)
        : null;
    nextAvailableAt = product.nextAvailableAt;
    tags = List<String>.from(product.tags);
    sizes = List<String>.from(product.extraAttributes?["sizes"] ?? []);
    colors = List<String>.from(product.extraAttributes?["colors"] ?? []);
  }

  void _removeExistingImage(String imageUrl) {
    setState(() => existingImages.remove(imageUrl));
  }

  void _removePickedImage(int index) {
    setState(() => pickedImages.removeAt(index));
  }

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() => pickedImages.addAll(pickedFiles.map((x) => File(x.path))));
    }
  }

  Widget buildChipsSection(
      String label, List<String> list, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6.0,
          children: list
              .map((val) => Chip(
                    label: Text(val),
                    deleteIcon: Icon(Icons.close),
                    onDeleted: () => setState(() => list.remove(val)),
                  ))
              .toList(),
        ),
        TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Add $label'),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              setState(() => list.add(value.trim()));
              controller.clear();
            }
          },
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      List<String> uploadedImages = [...existingImages];
      if (pickedImages.isNotEmpty) {
        final uploads = await _productController.uploadImagesToCloudinary(
            pickedImages, widget.product);
        uploadedImages.addAll(uploads);
      }

      final updatedProduct = Product(
        id: widget.product.id,
        productName: productNameController.text,
        productPrice: int.tryParse(productPriceController.text) ?? 0,
        quantity: int.tryParse(quantityController.text) ?? 0,
        description: productDescriptionController.text,
        category: widget.product.category,
        vendorId: widget.product.vendorId,
        fullName: widget.product.fullName,
        subCategory: widget.product.subCategory,
        images: uploadedImages,
        averageRating: widget.product.averageRating,
        totalRating: widget.product.totalRating,
        hasDiscount: hasDiscount,
        discountedPrice: int.tryParse(discountedPriceController.text) ?? 0,
        isNewProduct: isNewProduct,
        newLabelExpiresAt: newLabelExpiresAt?.toIso8601String(),
        nextAvailableAt: nextAvailableAt,
        hasNextAvailableLabel: hasNextAvailableLabel,
        isPublished: isPublished,
        recommend: recommend,
        tags: tags,
        extraAttributes: {
          "sizes": sizes,
          "colors": colors,
        },
        returnPolicy: returnPolicyController.text,
        brand: brandController.text,
        warrantyPeriod: warrantyPeriodController.text,
        shippingInfo: shippingInfoController.text,
        originCountry: originCountryController.text,
      );

      await _productController.updateProduct(
        product: updatedProduct,
        pickedImages: pickedImages,
        context: context,
      );
    }
  }

  Widget buildDatePicker(
      String label, DateTime? selected, Function(DateTime) onPicked) {
    return ElevatedButton(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPicked(picked);
      },
      child: Text(selected == null
          ? 'Select $label'
          : '$label: ${selected.toLocal().toString().split(' ')[0]}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                    controller: productNameController,
                    decoration: InputDecoration(labelText: 'Product Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(
                    controller: productPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Price')),
                TextFormField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Quantity')),
                TextFormField(
                    controller: productDescriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(labelText: 'Description')),
                TextFormField(
                    controller: brandController,
                    decoration: InputDecoration(labelText: 'Brand')),
                TextFormField(
                    controller: warrantyPeriodController,
                    decoration: InputDecoration(labelText: 'Warranty Period')),
                TextFormField(
                    controller: shippingInfoController,
                    decoration: InputDecoration(labelText: 'Shipping Info')),
                TextFormField(
                    controller: originCountryController,
                    decoration: InputDecoration(labelText: 'Origin Country')),
                TextFormField(
                    controller: returnPolicyController,
                    decoration: InputDecoration(labelText: 'Return Policy')),
                SwitchListTile(
                    title: Text('Discount'),
                    value: hasDiscount,
                    onChanged: (v) => setState(() => hasDiscount = v)),
                if (hasDiscount)
                  TextFormField(
                      controller: discountedPriceController,
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: 'Discounted Price')),
                SwitchListTile(
                    title: Text('Recommend'),
                    value: recommend,
                    onChanged: (v) => setState(() => recommend = v)),
                SwitchListTile(
                    title: Text('New Product'),
                    value: isNewProduct,
                    onChanged: (v) => setState(() => isNewProduct = v)),
                if (isNewProduct)
                  buildDatePicker('New Label Expiry', newLabelExpiresAt,
                      (d) => setState(() => newLabelExpiresAt = d)),
                SwitchListTile(
                    title: Text('Has Next Available Label'),
                    value: hasNextAvailableLabel,
                    onChanged: (v) =>
                        setState(() => hasNextAvailableLabel = v)),
                if (hasNextAvailableLabel)
                  buildDatePicker('Next Available At', nextAvailableAt,
                      (d) => setState(() => nextAvailableAt = d)),
                SwitchListTile(
                    title: Text('Publish'),
                    value: isPublished,
                    onChanged: (v) => setState(() => isPublished = v)),
                buildChipsSection('Tags', tags, tagInputController),
                buildChipsSection('Sizes', sizes, sizeInputController),
                buildChipsSection('Colors', colors, colorInputController),
                ElevatedButton(
                    onPressed: _pickImages, child: Text('Pick Images')),
                Wrap(
                  spacing: 6,
                  children: existingImages
                      .map((img) => Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.network(img,
                                  width: 100, height: 100, fit: BoxFit.cover),
                              IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _removeExistingImage(img))
                            ],
                          ))
                      .toList(),
                ),
                Wrap(
                  spacing: 6,
                  children: pickedImages
                      .asMap()
                      .entries
                      .map((e) => Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.file(e.value,
                                  width: 100, height: 100, fit: BoxFit.cover),
                              IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _removePickedImage(e.key))
                            ],
                          ))
                      .toList(),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                    onPressed: _updateProduct, child: Text('Update Product')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
