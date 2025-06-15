import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mac_vendor_store/controller/vendor_auth_controller.dart';
import 'package:mac_vendor_store/provider/vendor_provider.dart';
import 'package:mac_vendor_store/services/manage_http_response.dart';
import 'package:mac_vendor_store/views/screens/orders/view/order_screen.dart';

class VendorProfileScreen extends ConsumerStatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  ConsumerState<VendorProfileScreen> createState() =>
      _VendorProfileScreenState();
}

class _VendorProfileScreenState extends ConsumerState<VendorProfileScreen> {
  final VendorAuthController _vendorAuthController = VendorAuthController();
  final ImagePicker imagePicker = ImagePicker();
  //Define a ValueNotifier to manage the state of the profile picture
  final ValueNotifier<File?> imageNotifier = ValueNotifier<File?>(null);

  //Function to pick an image from the gallery
  Future<void> _pickImage() async {
    try {
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (pickedFile != null) {
        imageNotifier.value = File(pickedFile.path);
      } else {
        showSnackBar(context, 'No image selected');
      }
    } catch (e) {
      showSnackBar(context, 'Error picking image: $e');
    }
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Sign Out',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold, fontSize: 20),
            ),
            content: Text(
              'Are you sure you want to sign out?',
              style: GoogleFonts.montserrat(
                color: Colors.grey.shade700,
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style:
                      GoogleFonts.montserrat(color: Colors.grey, fontSize: 16),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  await _vendorAuthController.signOutUser(
                      context: context, ref: ref);
                  Navigator.of(context).pushReplacementNamed('/login');
                  showSnackBar(context, 'Logout Successfully');
                },
                child: Text(
                  'Sign Out',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        });
  }

  void showEditProfileDialog(BuildContext context) {
    final user = ref.read(vendorProvider);
    final TextEditingController storeDescriptionController =
        TextEditingController();
    storeDescriptionController.text = user?.storeDescription ?? '';

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "Edit Profile",
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //TODO read about details of ValueListenableBuilder
                ValueListenableBuilder(
                    valueListenable: imageNotifier,
                    builder: (context, value, child) {
                      return InkWell(
                        onTap: () {
                          _pickImage();
                        },
                        child: value != null
                            ? CircleAvatar(
                                radius: 50,
                                backgroundImage: FileImage(value),
                              )
                            : CircleAvatar(
                                radius: 50,
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Icon(
                                    CupertinoIcons.photo,
                                    size: 24,
                                  ),
                                ),
                              ),
                      );
                    }),
                const SizedBox(height: 10),
                TextFormField(
                  controller: storeDescriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Store Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  await _vendorAuthController.updateVendorData(
                    ref: ref,
                    context: context,
                    id: ref.read(vendorProvider)!.id,
                    storeImage: imageNotifier.value,
                    storeDescription: storeDescriptionController.text,
                  );
                  Navigator.pop(context);
                },
                child: Text(
                  'Save',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(vendorProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 450,
                  width: double.infinity,
                  child: Image.network(
                    'https://img.freepik.com/free-vector/gradient-blue-abstract-technology-background_23-2149213765.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 30,
                  right: 30,
                  child: Image.asset(
                    'assets/icons/not.png',
                    width: 30,
                    height: 30,
                  ),
                ),
                Align(
                  alignment: const Alignment(0, -0.5),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 65,
                        backgroundImage:user!.storeImage != null
                            ? NetworkImage(user.storeImage!)
                            : const
                         NetworkImage(
                          "https://i.pravatar.cc/150?img=3",
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            debugPrint("✅ تم الضغط على أيقونة التعديل");
                            showEditProfileDialog(context);
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: const Alignment(0, 0.03),
                  child: Text(
                    user.fullName != "" ? user!.fullName : 'User',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
               
              ],
            ),
            const SizedBox(height: 10),
            ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const OrderScreen();
                }));
              },
              leading: Image.asset('assets/icons/orders.png'),
              title: Text(
                'Track your order',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const OrderScreen();
                }));
              },
              leading: Image.asset('assets/icons/history.png'),
              title: Text(
                'History',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              onTap: () {},
              leading: Image.asset('assets/icons/help.png'),
              title: Text(
                'Help',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              onTap: () {
                _showSignOutDialog(context);
              },
              leading: Image.asset('assets/icons/logout.png'),
              title: Text(
                'Logout',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
