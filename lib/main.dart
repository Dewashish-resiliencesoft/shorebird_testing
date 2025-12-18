import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
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
      backgroundColor: Colors.red[500],
      body: SafeArea(
        child: Obx(() {
          /// ✅ Show snackbar ONCE after patch is applied
          if (controller.showUpdatedSnackbar.value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.snackbar(
                'Updated',
                'App has been updated successfully!',
                colorText: Colors.white,
                backgroundColor: Colors.green,
                snackPosition: SnackPosition.TOP,
                duration: const Duration(seconds: 2),
              );

              controller.showUpdatedSnackbar.value = false;
            });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// Debug helper
              if (kDebugMode)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    onPressed: () {
                      controller.status.value = UpdateStatus.restartRequired;
                      controller.bannerVisible.value = true;
                    },
                    child: const Text('Simulate restart required (debug)'),
                  ),
                ),

              /// UPDATE BANNER
              if (controller.status.value == UpdateStatus.restartRequired &&
                  controller.bannerVisible.value)
                Dismissible(
                  key: const ValueKey('update_banner'),
                  direction: DismissDirection.up,
                  onDismissed: (_) => controller.dismissBanner(),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.system_update_alt, color: Colors.grey),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'An update is ready.\nRestart the app to apply the latest patch.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        ElevatedButton(
                          /// ✅ CORRECT METHOD
                          onPressed: controller.restartApp,
                          child: const Text('Restart'),
                        ),
                      ],
                    ),
                  ),
                ),

              /// MAIN CONTENT
              const Expanded(
                child: Center(
                  child: Text(
                    'Shorebird Code Push\nis successfully implemented! \n checking the restart finally...',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
