import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShorebirdUpdateController extends GetxController {
  /// Constants
  static const _ackKey = 'shorebird_patch_acknowledged';
  static const _checkInterval = Duration(seconds: 5);
  static const _snackbarDuration = Duration(seconds: 2);

  /// Services
  final ShorebirdUpdater _updater = ShorebirdUpdater();

  /// Timer
  Timer? _timer;

  /// Observable states
  final Rx<UpdateStatus> status = UpdateStatus.upToDate.obs;
  final RxBool bannerVisible = false.obs;
  final RxBool checking = false.obs;
  final RxString error = ''.obs;
  final RxBool showUpdatedSnackbar = false.obs;

  @override
  void onInit() {
    super.onInit();
    _handlePostRestart();
    checkForUpdate();
    _startPeriodicCheck();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  /// Start periodic update checks
  void _startPeriodicCheck() {
    _timer = Timer.periodic(_checkInterval, (_) => checkForUpdate());
  }

  Future<void> checkForUpdate() async {
    if (checking.value) return;

    checking.value = true;
    try {
      final result = await _updater.checkForUpdate();
      status.value = result;

      if (result == UpdateStatus.restartRequired) {
        await _handleRestartRequired();
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      checking.value = false;
    }
  }

  /// Handle actions when restart is required
  Future<void> _handleRestartRequired() async {
    bannerVisible.value = true;
    _timer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ackKey, false);
  }

  /// Handle post-restart: show snackbar if patch was applied
  Future<void> _handlePostRestart() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_ackKey) ?? false) return;

    final result = await _updater.checkForUpdate();
    if (result == UpdateStatus.upToDate) {
      showUpdatedSnackbar.value = true;
      await prefs.setBool(_ackKey, true);
    }
  }

  /// Show snackbar for successful update
  void showUpdateSnackbar() {
    Get.snackbar(
      'Updated',
      'App has been updated successfully!',
      colorText: Colors.white,
      backgroundColor: Colors.green.withValues(alpha: 0.9),
      snackPosition: SnackPosition.TOP,
      duration: _snackbarDuration,
    );
    showUpdatedSnackbar.value = false;
  }
}
