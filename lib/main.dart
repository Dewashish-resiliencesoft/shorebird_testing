import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shorebird_test/shorebirdupdatecontroller.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShorebirdUpdateController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Successfully implemented Shorebird'),
        centerTitle: true,
        elevation: 2,
      ),
      backgroundColor: Colors.white70,
      body: SafeArea(
        child: Obx(() {
          /// ✅ Show snackbar ONCE after patch is applied
          if (controller.showUpdatedSnackbar.value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.showUpdateSnackbar();
            });
          }
          return Center(
            child: Text(
              'Current app version: 6.0.0',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }),
      ),
    );
  }
}
