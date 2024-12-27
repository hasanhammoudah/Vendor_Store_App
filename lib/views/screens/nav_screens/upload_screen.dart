import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mac_vendor_store/controller/category_controller.dart';
import 'package:mac_vendor_store/controller/subcategory_controller.dart';
import 'package:mac_vendor_store/models/category.dart';
import 'package:mac_vendor_store/models/subcategory.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Future<List<Category>> futureCategories;
  Category? selectedCategory;
  final ImagePicker picker = ImagePicker();
  List<File> images = [];
  Future<List<Subcategory>>? futureSubCategories;
  Subcategory? selectedSubCategory;
  chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      print('no image selected');
    } else {
      setState(() {
        images.add(File(pickedFile.path));
      });
    }
  }

//TODO: get subcategories by category
  getSubCategoryByCategory(value) {
    futureSubCategories =
        SubcategoryController().getSubCategoriesByCategoryName(value.name);
    //rest the selected subcategory
    selectedSubCategory = null;
  }

  @override
  void initState() {
    super.initState();
    futureCategories = CategoryController().loadCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
              shrinkWrap: true,
              itemCount: images.length + 1,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                return index == 0
                    ? Center(
                        child: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            chooseImage();
                          },
                        ),
                      )
                    : SizedBox(
                        width: 50,
                        height: 40,
                        child: Image.file(images[index - 1]),
                      );
              }),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter product name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter product name',
                      labelText: 'Enter Product Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter product price';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter product Price',
                      labelText: 'Enter Product Price',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter product quantity';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter product Quantity',
                      labelText: 'Enter Product Quantity',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 200,
                  child: FutureBuilder<List<Category>>(
                      future: futureCategories,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text("No categories Found"),
                          );
                        } else {
                          return DropdownButton<Category>(
                              value: selectedCategory,
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
                              });
                        }
                      }),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 200,
                  child: FutureBuilder<List<Subcategory>>(
                      future: futureSubCategories,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text("No Subcategories Found"),
                          );
                        } else {
                          return DropdownButton<Subcategory>(
                              value: selectedSubCategory,
                              hint: Text('Select Category'),
                              items:
                                  snapshot.data!.map((Subcategory subCategory) {
                                return DropdownMenuItem<Subcategory>(
                                  value: subCategory,
                                  child: Text(subCategory.subCategoryName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedSubCategory = value;
                                });
                              });
                        }
                      }),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 400,
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter product Description';
                      }
                      return null;
                    },
                    maxLines: 3,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'Enter product Description',
                      labelText: 'Enter Product Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: InkWell(
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  print('Form is valid');
                } else {
                  print('Form is invalid');
                }
              },
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.blue.shade900,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
                    'Upload Product',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.7),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
