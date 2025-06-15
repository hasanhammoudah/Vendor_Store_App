import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_vendor_store/controller/vendor_auth_controller.dart';
import 'package:mac_vendor_store/provider/vendor_provider.dart';
import 'package:mac_vendor_store/views/screens/authentication/login_screen.dart';
import 'package:mac_vendor_store/views/screens/main_vendor_screen.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {

  Future<void> checkTokenAndSetUser(WidgetRef ref, context) async {
    await VendorAuthController().getUserData(context, ref);

    ref.watch(vendorProvider);
  }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder(
          future: checkTokenAndSetUser(ref,context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final vendor = ref.watch(vendorProvider);
            return vendor!.token.isNotEmpty
                ? const MainVendorScreen()
                : const LoginScreen();
          }),
    );
  }
}
