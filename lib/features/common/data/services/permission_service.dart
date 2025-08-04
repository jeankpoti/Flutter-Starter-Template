import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionService {
  static const String _firstTimeCameraKey = 'isFirstTimeCamera';
  static const String _firstTimeGalleryKey = 'isFirstTimeGallery';

  // Check if it's the first time requesting a specific permission
  Future<bool> isFirstTimePermission(PermissionType type) async {
    final prefs = await SharedPreferences.getInstance();
    switch (type) {
      case PermissionType.camera:
        return prefs.getBool(_firstTimeCameraKey) ?? true;
      case PermissionType.gallery:
        return prefs.getBool(_firstTimeGalleryKey) ?? true;
    }
  }

  // Mark that permission has been requested at least once
  Future<void> markPermissionRequested(PermissionType type) async {
    final prefs = await SharedPreferences.getInstance();
    switch (type) {
      case PermissionType.camera:
        await prefs.setBool(_firstTimeCameraKey, false);
        break;
      case PermissionType.gallery:
        await prefs.setBool(_firstTimeGalleryKey, false);
        break;
    }
  }

  // Request camera permission
  Future<PermissionResult> requestCameraPermission() async {
    final isFirstTime = await isFirstTimePermission(PermissionType.camera);
    final currentStatus = await Permission.camera.status;
    
    print('Camera permission - First time: $isFirstTime, Current status: $currentStatus');
    
    // Always request on first time, regardless of current status
    if (isFirstTime) {
      final status = await Permission.camera.request();
      await markPermissionRequested(PermissionType.camera);
      
      return PermissionResult(
        status: status,
        isFirstTime: true,
        type: PermissionType.camera,
      );
    }
    
    // Not first time - check if we should show dialog or request again
    if (currentStatus.isDenied || currentStatus.isPermanentlyDenied) {
      // Don't request, just return current status - this will trigger the dialog
      return PermissionResult(
        status: currentStatus,
        isFirstTime: false,
        type: PermissionType.camera,
      );
    }
    
    // Permission might be granted or restricted, try requesting
    final status = await Permission.camera.request();
    return PermissionResult(
      status: status,
      isFirstTime: false,
      type: PermissionType.camera,
    );
  }

  // Request gallery permission
  Future<PermissionResult> requestGalleryPermission() async {
    final isFirstTime = await isFirstTimePermission(PermissionType.gallery);
    final currentStatus = await Permission.photos.status;
    
    print('Gallery permission - First time: $isFirstTime, Current status: $currentStatus');
    
    // Always request on first time, regardless of current status
    if (isFirstTime) {
      final status = await Permission.photos.request();
      await markPermissionRequested(PermissionType.gallery);
      
      return PermissionResult(
        status: status,
        isFirstTime: true,
        type: PermissionType.gallery,
      );
    }
    
    // Not first time - check if we should show dialog or request again
    if (currentStatus.isDenied || currentStatus.isPermanentlyDenied) {
      // Don't request, just return current status - this will trigger the dialog
      return PermissionResult(
        status: currentStatus,
        isFirstTime: false,
        type: PermissionType.gallery,
      );
    }
    
    // Permission might be granted or restricted, try requesting
    final status = await Permission.photos.request();
    return PermissionResult(
      status: status,
      isFirstTime: false,
      type: PermissionType.gallery,
    );
  }

  // Check current permission status
  Future<PermissionStatus> checkCameraStatus() async {
    return await Permission.camera.status;
  }

  Future<PermissionStatus> checkGalleryStatus() async {
    return await Permission.photos.status;
  }

  // Check if permission is granted
  Future<bool> isCameraGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  Future<bool> isGalleryGranted() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  // Open app settings
  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}

enum PermissionType {
  camera,
  gallery,
}

class PermissionResult {
  final PermissionStatus status;
  final bool isFirstTime;
  final PermissionType type;

  PermissionResult({
    required this.status,
    required this.isFirstTime,
    required this.type,
  });

  bool get isGranted => status.isGranted;
  bool get isDenied => status.isDenied;
  bool get isPermanentlyDenied => status.isPermanentlyDenied;
  
  // Show dialog only when:
  // 1. It's not the first time (user has seen the system permission dialog before)
  // 2. Permission is currently denied or permanently denied
  bool get shouldShowDialog => !isFirstTime && (isDenied || isPermanentlyDenied);
}