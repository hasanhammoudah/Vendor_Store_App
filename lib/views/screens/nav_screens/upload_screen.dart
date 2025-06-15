// تم التحديث لحل مشاكل قيم خاطئة بعد الإدخال وتنظيف الحقول تلقائياً بعد الضغط على Enter وتحسين عرض التاريخ

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mac_vendor_store/controller/category_controller.dart';
import 'package:mac_vendor_store/controller/product_controller.dart';
import 'package:mac_vendor_store/controller/subcategory_controller.dart';
import 'package:mac_vendor_store/models/category.dart';
import 'package:mac_vendor_store/models/subcategory.dart';
import 'package:mac_vendor_store/provider/vendor_provider.dart';
import 'package:mac_vendor_store/services/manage_http_response.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();
  List<File> images = [];
  late Future<List<Category>> futureCategories;
  Future<List<Subcategory>>? futureSubCategories;
  Category? selectedCategory;
  Subcategory? selectedSubCategory;

  final ProductController _productController = ProductController();
  late String productName;
  late int productPrice;
  late int quantity;
  late String description;
  bool isLoading = false;
  bool hasDiscount = false;
  bool recommend = false;
  bool isNewProduct = false;
  bool hasNextAvailableLabel = false;
  bool isPublished = true;

  final TextEditingController discountedPriceController =
      TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController warrantyPeriodController =
      TextEditingController();
  final TextEditingController shippingInfoController = TextEditingController();
  final TextEditingController originCountryController = TextEditingController();
  final TextEditingController returnPolicyController = TextEditingController();

  final TextEditingController tagInputController = TextEditingController();
  final TextEditingController sizeInputController = TextEditingController();
  final TextEditingController colorInputController = TextEditingController();

  List<String> sizes = [];
  List<String> colors = [];
  List<String> tags = [];

  DateTime? newLabelExpiresAt;
  DateTime? nextAvailableAt;

  chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        images.add(File(pickedFile.path));
      });
    }
  }

  getSubCategoryByCategory(value) {
    futureSubCategories =
        SubcategoryController().getSubCategoriesByCategoryName(value.name);
    selectedSubCategory = null;
  }

  @override
  void initState() {
    super.initState();
    futureCategories = CategoryController().loadCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Upload Product',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: images.length + 1,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return GestureDetector(
                        onTap: chooseImage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.add,
                              size: 36, color: Colors.grey.shade600),
                        ),
                      );
                    } else {
                      return Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(images[index - 1],
                                fit: BoxFit.cover),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                images.removeAt(index - 1);
                              });
                            },
                          ),
                        ],
                      );
                    }
                  },
                ),
                SizedBox(height: 20),
                buildTextField('Enter product name', 'Product Name',
                    (value) => productName = value),
                SizedBox(
                  height: 5,
                ),
                buildTextField('Enter product Price', 'Price', (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null) {
                    productPrice = parsed;
                  } else {
                    productPrice = 0; // أو اعرض رسالة خطأ لو أردت
                  }
                }, type: TextInputType.number),
                SizedBox(
                  height: 5,
                ),
                buildTextField('Enter product Quantity', 'Quantity', (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null) {
                    quantity = parsed;
                  } else {
                    quantity = 0; // أو اعرض رسالة خطأ لو أردت
                  }
                }, type: TextInputType.number),
                SizedBox(
                  height: 5,
                ),
                buildCategoryDropdown(),
                if (selectedCategory?.name.toLowerCase() == 'clothes') ...[
                  SizedBox(height: 5),
                  buildChipsSection('Sizes', sizes, sizeInputController),
                  buildChipsSection('Colors', colors, colorInputController),
                ],
                SizedBox(height: 5),
                buildSubcategoryDropdown(),
                SizedBox(
                  height: 5,
                ),
                buildTextField('Description', 'Product Description',
                    (value) => description = value,
                    maxLines: 3, maxLength: 500),
                SizedBox(
                  height: 5,
                ),
                buildControllerField(brandController, 'Brand', 'Brand'),
                SizedBox(
                  height: 5,
                ),
                buildControllerField(warrantyPeriodController,
                    'Warranty Period', 'Warranty Period'),
                SizedBox(
                  height: 5,
                ),
                buildControllerField(
                    shippingInfoController, 'Shipping Info', 'Shipping Info'),
                SizedBox(
                  height: 5,
                ),
                buildControllerField(originCountryController, 'Origin Country',
                    'Origin Country'),
                SizedBox(
                  height: 5,
                ),
                buildControllerField(
                    returnPolicyController, 'Return Policy', 'Return Policy'),
                SizedBox(
                  height: 5,
                ),
                SwitchListTile(
                  title: Text('Enable Discount'),
                  value: hasDiscount,
                  onChanged: (value) => setState(() => hasDiscount = value),
                ),
                if (hasDiscount)
                  buildControllerField(discountedPriceController,
                      'Discounted Price', 'Discounted Price'),
                SwitchListTile(
                  title: Text('Is New Product?'),
                  value: isNewProduct,
                  onChanged: (value) => setState(() => isNewProduct = value),
                ),
                if (isNewProduct)
                  buildDatePickerButton(
                      'New Label Expiry Date',
                      newLabelExpiresAt,
                      (picked) => setState(() => newLabelExpiresAt = picked)),
                SwitchListTile(
                  title: Text('Recommend'),
                  value: recommend,
                  onChanged: (value) => setState(() => recommend = value),
                ),
                SwitchListTile(
                  title: Text('Enable Next Available Label'),
                  value: hasNextAvailableLabel,
                  onChanged: (value) =>
                      setState(() => hasNextAvailableLabel = value),
                ),
                if (hasNextAvailableLabel)
                  buildDatePickerButton('Next Available At', nextAvailableAt,
                      (picked) => setState(() => nextAvailableAt = picked)),
                SwitchListTile(
                  title: Text('Publish Product'),
                  value: isPublished,
                  onChanged: (value) => setState(() => isPublished = value),
                ),
                buildChipsSection('Tags', tags, tagInputController),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLoading ? null : handleUpload,
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Upload Product',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hint, String label, Function(String) onChanged,
      {TextInputType type = TextInputType.text,
      int maxLines = 1,
      int? maxLength}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: type,
        onChanged: onChanged,
        maxLines: maxLines,
        maxLength: maxLength,
        validator: (value) => value!.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget buildControllerField(
      TextEditingController controller, String hint, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget buildCategoryDropdown() {
    return FutureBuilder<List<Category>>(
      future: futureCategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return Text("No categories Found");
        }
        return DropdownButtonFormField<Category>(
          value: selectedCategory,
          decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          hint: Text('Select Category'),
          items: snapshot.data!.map((Category category) {
            return DropdownMenuItem<Category>(
              value: category,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCategory = value;
            });
            getSubCategoryByCategory(selectedCategory);
          },
        );
      },
    );
  }

  Widget buildSubcategoryDropdown() {
    return FutureBuilder<List<Subcategory>>(
      future: futureSubCategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return Text("No Subcategories Found");
        }
        return DropdownButtonFormField<Subcategory>(
          value: selectedSubCategory,
          decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          hint: Text('Select Subcategory'),
          items: snapshot.data!.map((Subcategory subCategory) {
            return DropdownMenuItem<Subcategory>(
              value: subCategory,
              child: Text(subCategory.subCategoryName),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedSubCategory = value;
            });
          },
        );
      },
    );
  }

  Widget buildChipsSection(
      String label, List<String> values, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: values
              .map((val) => Chip(
                    label: Text(val),
                    deleteIcon: Icon(Icons.close),
                    onDeleted: () => setState(() => values.remove(val)),
                  ))
              .toList(),
        ),
        TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Add $label'),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              setState(() => values.add(value.trim()));
              controller.clear();
            }
          },
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget buildDatePickerButton(
      String label, DateTime? selectedDate, Function(DateTime) onDatePicked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (picked != null) onDatePicked(picked);
        },
        child: Text(
          selectedDate == null
              ? 'Select $label'
              : '$label: ${selectedDate.toLocal().toString().split(' ')[0]}',
        ),
      ),
    );
  }

  void handleUpload() async {
    final fullName = ref.read(vendorProvider)!.fullName;
    final vendorId = ref.read(vendorProvider)!.id;

    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      await _productController
          .uploadProduct(
        productName: productName,
        description: description,
        productPrice: productPrice,
        quantity: quantity,
        category: selectedCategory!.name,
        vendorId: vendorId,
        fullName: fullName,
        subCategory: selectedSubCategory!.subCategoryName,
        pickedImages: images,
        hasDiscount: hasDiscount,
        discountedPrice:
            hasDiscount ? int.parse(discountedPriceController.text) : 0,
        brand: brandController.text,
        warrantyPeriod: warrantyPeriodController.text,
        shippingInfo: shippingInfoController.text,
        originCountry: originCountryController.text,
        isNewProduct: isNewProduct,
        newLabelExpiresAt: newLabelExpiresAt?.toIso8601String(),
        nextAvailableAt: nextAvailableAt,
        returnPolicy: returnPolicyController.text,
        tags: tags,
        extraAttributes: {
          'sizes': sizes,
          'colors': colors,
        },
        hasNextAvailableLabel: hasNextAvailableLabel,
        context: context,
        recommend: recommend,
      )
          .whenComplete(() {
        setState(() {
          isLoading = false;
          _formKey.currentState!.reset();
          images.clear();
          sizes.clear();
          colors.clear();
          tags.clear();
          selectedCategory = null;
          selectedSubCategory = null;
          discountedPriceController.clear();
          brandController.clear();
          warrantyPeriodController.clear();
          shippingInfoController.clear();
          originCountryController.clear();
          returnPolicyController.clear();
          newLabelExpiresAt = null;
          nextAvailableAt = null;
          hasDiscount = false;
          isNewProduct = false;
          hasNextAvailableLabel = false;
          isPublished = true;
          recommend = false;
        });
        Navigator.pop(context);
      });
    } else {
      showSnackBar(context, 'Please fill all fields');
    }
  }
}
