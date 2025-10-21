import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// State
class PermissionState extends Equatable {
  final bool isLoading;
  final bool isFirstTimeCamera;
  final bool isFirstTimeGallery;
  final bool isFirstTimeMicrophone;
  final bool hasCameraBeenDenied;
  final bool hasGalleryBeenDenied;
  final bool hasMicrophoneBeenDenied;
  final bool pendingCameraPermission;
  final bool pendingGalleryPermission;
  final bool pendingMicrophonePermission;
  final PermissionStatus? cameraStatus;
  final PermissionStatus? galleryStatus;
  final PermissionStatus? microphoneStatus;
  final String? message;

  const PermissionState({
    this.isLoading = false,
    this.isFirstTimeCamera = true,
    this.isFirstTimeGallery = true,
    this.isFirstTimeMicrophone = true,
    this.hasCameraBeenDenied = false,
    this.hasGalleryBeenDenied = false,
    this.hasMicrophoneBeenDenied = false,
    this.pendingCameraPermission = false,
    this.pendingGalleryPermission = false,
    this.pendingMicrophonePermission = false,
    this.cameraStatus,
    this.galleryStatus,
    this.microphoneStatus,
    this.message,
  });

  PermissionState copyWith({
    bool? isLoading,
    bool? isFirstTimeCamera,
    bool? isFirstTimeGallery,
    bool? isFirstTimeMicrophone,
    bool? hasCameraBeenDenied,
    bool? hasGalleryBeenDenied,
    bool? hasMicrophoneBeenDenied,
    bool? pendingCameraPermission,
    bool? pendingGalleryPermission,
    bool? pendingMicrophonePermission,
    PermissionStatus? cameraStatus,
    PermissionStatus? galleryStatus,
    PermissionStatus? microphoneStatus,
    String? message,
  }) {
    return PermissionState(
      isLoading: isLoading ?? this.isLoading,
      isFirstTimeCamera: isFirstTimeCamera ?? this.isFirstTimeCamera,
      isFirstTimeGallery: isFirstTimeGallery ?? this.isFirstTimeGallery,
      isFirstTimeMicrophone: isFirstTimeMicrophone ?? this.isFirstTimeMicrophone,
      hasCameraBeenDenied: hasCameraBeenDenied ?? this.hasCameraBeenDenied,
      hasGalleryBeenDenied: hasGalleryBeenDenied ?? this.hasGalleryBeenDenied,
      hasMicrophoneBeenDenied: hasMicrophoneBeenDenied ?? this.hasMicrophoneBeenDenied,
      pendingCameraPermission: pendingCameraPermission ?? this.pendingCameraPermission,
      pendingGalleryPermission: pendingGalleryPermission ?? this.pendingGalleryPermission,
      pendingMicrophonePermission: pendingMicrophonePermission ?? this.pendingMicrophonePermission,
      cameraStatus: cameraStatus ?? this.cameraStatus,
      galleryStatus: galleryStatus ?? this.galleryStatus,
      microphoneStatus: microphoneStatus ?? this.microphoneStatus,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isFirstTimeCamera,
    isFirstTimeGallery,
    isFirstTimeMicrophone,
    hasCameraBeenDenied,
    hasGalleryBeenDenied,
    hasMicrophoneBeenDenied,
    pendingCameraPermission,
    pendingGalleryPermission,
    pendingMicrophonePermission,
    cameraStatus,
    galleryStatus,
    microphoneStatus,
    message,
  ];
}

// Cubit
class PermissionCubit extends Cubit<PermissionState> {
  PermissionCubit() : super(const PermissionState());

  // Initialize permissions - load first time flags from SharedPreferences
  Future<void> initializePermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTimeCamera = prefs.getBool('isFirstTimeCamera') ?? true;
    final isFirstTimeGallery = prefs.getBool('isFirstTimeGallery') ?? true;
    final isFirstTimeMicrophone = prefs.getBool('isFirstTimeMicrophone') ?? true;
    final hasCameraBeenDenied = prefs.getBool('hasCameraBeenDenied') ?? false;
    final hasGalleryBeenDenied = prefs.getBool('hasGalleryBeenDenied') ?? false;
    final hasMicrophoneBeenDenied = prefs.getBool('hasMicrophoneBeenDenied') ?? false;

    emit(
      state.copyWith(
        isFirstTimeCamera: isFirstTimeCamera,
        isFirstTimeGallery: isFirstTimeGallery,
        isFirstTimeMicrophone: isFirstTimeMicrophone,
        hasCameraBeenDenied: hasCameraBeenDenied,
        hasGalleryBeenDenied: hasGalleryBeenDenied,
        hasMicrophoneBeenDenied: hasMicrophoneBeenDenied,
      ),
    );
  }

  // Request camera permission
  Future<PermissionStatus> requestCameraPermission() async {
    emit(state.copyWith(isLoading: true));

    try {
      PermissionStatus cameraStatus = PermissionStatus.denied;
      
      // Store the previous denial status before making the request
      final wasPreviouslyDenied = state.hasCameraBeenDenied;
      
      // Request camera permission based on platform
      if (Platform.isAndroid || Platform.isIOS) {
        cameraStatus = await Permission.camera.request();
      }

      final prefs = await SharedPreferences.getInstance();
      
      // If it was the first time AND permission was granted, update the flag
      if (state.isFirstTimeCamera && cameraStatus.isGranted) {
        await prefs.setBool('isFirstTimeCamera', false);
        emit(state.copyWith(isFirstTimeCamera: false));
      }
      
      // Track if camera permission has been denied
      if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
        await prefs.setBool('hasCameraBeenDenied', true);
      }

      // Update state with camera status
      emit(
        state.copyWith(
          isLoading: false,
          cameraStatus: cameraStatus,
          hasCameraBeenDenied: cameraStatus.isDenied || cameraStatus.isPermanentlyDenied,
          pendingCameraPermission: wasPreviouslyDenied && 
            (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied),
        ),
      );

      return cameraStatus;
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          message: 'Error requesting camera permission',
        ),
      );
      rethrow;
    }
  }

  // Request microphone permission
  Future<PermissionStatus> requestMicrophonePermission() async {
    emit(state.copyWith(isLoading: true));

    try {
      PermissionStatus microphoneStatus = PermissionStatus.denied;
      
      // Store the previous denial status before making the request
      final wasPreviouslyDenied = state.hasMicrophoneBeenDenied;
      
      // Request microphone permission based on platform
      if (Platform.isAndroid || Platform.isIOS) {
        microphoneStatus = await Permission.microphone.request();
      }

      final prefs = await SharedPreferences.getInstance();
      
      // If it was the first time AND permission was granted, update the flag
      if (state.isFirstTimeMicrophone && microphoneStatus.isGranted) {
        await prefs.setBool('isFirstTimeMicrophone', false);
        emit(state.copyWith(isFirstTimeMicrophone: false));
      }
      
      // Track if microphone permission has been denied
      if (microphoneStatus.isDenied || microphoneStatus.isPermanentlyDenied) {
        await prefs.setBool('hasMicrophoneBeenDenied', true);
      }

      // Update state with microphone status
      emit(
        state.copyWith(
          isLoading: false,
          microphoneStatus: microphoneStatus,
          hasMicrophoneBeenDenied: microphoneStatus.isDenied || microphoneStatus.isPermanentlyDenied,
          pendingMicrophonePermission: wasPreviouslyDenied && 
            (microphoneStatus.isDenied || microphoneStatus.isPermanentlyDenied),
        ),
      );

      return microphoneStatus;
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          message: 'Error requesting microphone permission',
        ),
      );
      rethrow;
    }
  }

  // Request gallery permission
  Future<PermissionStatus> requestGalleryPermission() async {
    emit(state.copyWith(isLoading: true));

    try {
      PermissionStatus photoStatus = PermissionStatus.denied;
      
      // Store the previous denial status before making the request
      final wasPreviouslyDenied = state.hasGalleryBeenDenied;
      
      // Request photo library permission based on platform
      if (Platform.isAndroid || Platform.isIOS) {
        photoStatus = await Permission.photos.request();
      }

      final prefs = await SharedPreferences.getInstance();
      
      // If it was the first time AND permission was granted, update the flag
      if (state.isFirstTimeGallery && photoStatus.isGranted) {
        await prefs.setBool('isFirstTimeGallery', false);
        emit(state.copyWith(isFirstTimeGallery: false));
      }
      
      // Track if gallery permission has been denied
      if (photoStatus.isDenied || photoStatus.isPermanentlyDenied) {
        await prefs.setBool('hasGalleryBeenDenied', true);
      }

      // Update state with gallery status
      emit(
        state.copyWith(
          isLoading: false,
          galleryStatus: photoStatus,
          hasGalleryBeenDenied: photoStatus.isDenied || photoStatus.isPermanentlyDenied,
          pendingGalleryPermission: wasPreviouslyDenied && 
            (photoStatus.isDenied || photoStatus.isPermanentlyDenied),
        ),
      );

      return photoStatus;
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          message: 'Error requesting gallery permission',
        ),
      );
      rethrow;
    }
  }

  // Check pending permissions after app resume
  Future<void> checkPendingPermissions() async {
    // Add delay to ensure settings changes are reflected
    await Future.delayed(const Duration(milliseconds: 500));

    if (state.pendingCameraPermission) {
      final cameraStatus = await Permission.camera.status;

      emit(
        state.copyWith(
          cameraStatus: cameraStatus,
          pendingCameraPermission: false,
          message:
              cameraStatus.isGranted
                  ? 'Camera permission granted. Please take the picture again.'
                  : null,
        ),
      );
    }

    if (state.pendingGalleryPermission) {
      final photoStatus = await Permission.photos.status;

      emit(
        state.copyWith(
          galleryStatus: photoStatus,
          pendingGalleryPermission: false,
          message:
              photoStatus.isGranted
                  ? 'Photo library permission granted. Please upload the picture again.'
                  : null,
        ),
      );
    }

    if (state.pendingMicrophonePermission) {
      final microphoneStatus = await Permission.microphone.status;

      emit(
        state.copyWith(
          microphoneStatus: microphoneStatus,
          pendingMicrophonePermission: false,
          message:
              microphoneStatus.isGranted
                  ? 'Microphone permission granted. Please try voice input again.'
                  : null,
        ),
      );
    }
  }

  // Clear any messages
  void clearMessage() {
    emit(state.copyWith(message: null));
  }

  // Set pending permission flags
  void setPendingCameraPermission(bool pending) {
    emit(state.copyWith(pendingCameraPermission: pending));
  }

  void setPendingGalleryPermission(bool pending) {
    emit(state.copyWith(pendingGalleryPermission: pending));
  }

  void setPendingMicrophonePermission(bool pending) {
    emit(state.copyWith(pendingMicrophonePermission: pending));
  }

  // Check if should show permission dialog
  bool shouldShowCameraDialog(PermissionStatus status) {
    // Show dialog only if:
    // 1. Permission was denied in a previous attempt (stored in state before this request)
    // 2. Permission is currently denied or permanently denied
    // Note: We check the state that was loaded from SharedPreferences,
    // not the state updated during the current request
    return state.hasCameraBeenDenied && 
           (status.isDenied || status.isPermanentlyDenied);
  }

  bool shouldShowGalleryDialog(PermissionStatus status) {
    // Show dialog only if:
    // 1. Permission was denied in a previous attempt (stored in state before this request)
    // 2. Permission is currently denied or permanently denied
    // Note: We check the state that was loaded from SharedPreferences,
    // not the state updated during the current request
    return state.hasGalleryBeenDenied && 
           (status.isDenied || status.isPermanentlyDenied);
  }

  bool shouldShowMicrophoneDialog(PermissionStatus status) {
    // Show dialog only if:
    // 1. Permission was denied in a previous attempt (stored in state before this request)
    // 2. Permission is currently denied or permanently denied
    // Note: We check the state that was loaded from SharedPreferences,
    // not the state updated during the current request
    return state.hasMicrophoneBeenDenied && 
           (status.isDenied || status.isPermanentlyDenied);
  }

  // Open app settings
  Future<void> openSettings() async {
    await openAppSettings();
  }
}