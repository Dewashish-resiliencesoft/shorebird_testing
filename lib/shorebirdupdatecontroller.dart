import 'dart:async';

import 'package:get/get.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShorebirdUpdateController extends GetxController {
  final ShorebirdUpdater _updater = ShorebirdUpdater();

  Timer? _timer;

  final Rx<UpdateStatus> status = UpdateStatus.upToDate.obs;
  final RxBool bannerVisible = false.obs;
  final RxBool checking = false.obs;
  final RxString error = ''.obs;

  /// UI signal (observed in UI)
  final RxBool showUpdatedSnackbar = false.obs;

  /// One-time acknowledgment per patch
  static const _ackKey = 'shorebird_patch_acknowledged';

  @override
  void onInit() {
    super.onInit();

    /// Runs once after every app launch
    _handlePostRestart();

    /// Initial check
    checkForUpdate();

    /// Periodic check (optional)
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => checkForUpdate(),
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> checkForUpdate() async {
    if (checking.value) return;

    try {
      checking.value = true;

      final result = await _updater.checkForUpdate();
      status.value = result;

      /// ✅ Correct signal: patch downloaded & waiting
      if (result == UpdateStatus.restartRequired) {
        bannerVisible.value = true;

        /// Stop polling once restart is required
        _timer?.cancel();

        /// Allow snackbar to show again AFTER restart
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_ackKey, false);
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      checking.value = false;
    }
  }

  /// ✅ SAFE restart (Shorebird-compatible, Play Store safe)
  void restartApp() {
    Restart.restartApp();
  }

  void dismissBanner() {
    bannerVisible.value = false;
  }

  /// 🔑 Runs ONCE per applied patch
  Future<void> _handlePostRestart() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyAcked = prefs.getBool(_ackKey) ?? false;

    if (alreadyAcked) return;

    final result = await _updater.checkForUpdate();

    /// Patch successfully applied
    if (result == UpdateStatus.upToDate) {
      showUpdatedSnackbar.value = true;
      await prefs.setBool(_ackKey, true);
    }
  }
}
