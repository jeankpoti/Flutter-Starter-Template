import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/services/image_capture_service.dart';
import '../../common/presentation/permission_cubit.dart';

// State
class ImageCaptureState extends Equatable {
  final File? imageFile;
  final bool isLoading;
  final bool isCamera;
  final bool isGallery;
  final String? errorMessage;

  const ImageCaptureState({
    this.imageFile,
    this.isLoading = false,
    this.isCamera = false,
    this.isGallery = false,
    this.errorMessage,
  });

  ImageCaptureState copyWith({
    File? imageFile,
    bool? isLoading,
    bool? isCamera,
    bool? isGallery,
    String? errorMessage,
  }) {
    return ImageCaptureState(
      imageFile: imageFile ?? this.imageFile,
      isLoading: isLoading ?? this.isLoading,
      isCamera: isCamera ?? this.isCamera,
      isGallery: isGallery ?? this.isGallery,
      errorMessage: errorMessage,
    );
  }

  ImageCaptureState clearImage() {
    return ImageCaptureState(
      imageFile: null,
      isLoading: false,
      isCamera: false,
      isGallery: false,
      errorMessage: null,
    );
  }

  @override
  List<Object?> get props => [imageFile, isLoading, isCamera, isGallery, errorMessage];
}

// Cubit
class ImageCaptureCubit extends Cubit<ImageCaptureState> {
  final ImageCaptureService _imageCaptureService;
  final PermissionCubit _permissionCubit;

  ImageCaptureCubit({
    required PermissionCubit permissionCubit,
    ImageCaptureService? imageCaptureService,
  })  : _permissionCubit = permissionCubit,
        _imageCaptureService = imageCaptureService ?? ImageCaptureService(),
        super(const ImageCaptureState());

  /// Captures image from camera with permission handling
  Future<bool> captureFromCamera() async {
    emit(state.copyWith(
      isLoading: true,
      isCamera: true,
      isGallery: false,
      errorMessage: null,
    ));

    try {
      // Check if we should show dialog BEFORE making the request
      final shouldShowDialogBeforeRequest = _permissionCubit.state.hasCameraBeenDenied;
      
      // Request camera permission
      final cameraStatus = await _permissionCubit.requestCameraPermission();

      // Check if should show dialog based on the state before the request
      if (shouldShowDialogBeforeRequest && (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied)) {
        _permissionCubit.setPendingCameraPermission(true);
        emit(state.copyWith(isLoading: false));
        return false; // Caller should show permission dialog
      }

      // If permission is denied, don't proceed
      if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
        emit(state.copyWith(isLoading: false));
        return true; // Permission was handled, but denied
      }

      // Capture image
      final imageFile = await _imageCaptureService.captureFromCamera();
      
      if (imageFile != null) {
        emit(state.copyWith(
          imageFile: imageFile,
          isLoading: false,
        ));
      } else {
        // User cancelled
        emit(state.copyWith(isLoading: false));
      }
      
      return true; // Permission was handled successfully
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to capture image',
      ));
      return true;
    }
  }

  /// Selects image from gallery with permission handling
  Future<bool> selectFromGallery() async {
    emit(state.copyWith(
      isLoading: true,
      isCamera: false,
      isGallery: true,
      errorMessage: null,
    ));

    try {
      // Check if we should show dialog BEFORE making the request
      final shouldShowDialogBeforeRequest = _permissionCubit.state.hasGalleryBeenDenied;
      
      // Request gallery permission
      final photoStatus = await _permissionCubit.requestGalleryPermission();

      // Check if should show dialog based on the state before the request
      if (shouldShowDialogBeforeRequest && (photoStatus.isDenied || photoStatus.isPermanentlyDenied)) {
        _permissionCubit.setPendingGalleryPermission(true);
        emit(state.copyWith(isLoading: false));
        return false; // Caller should show permission dialog
      }

      // If permission is denied, don't proceed
      if (photoStatus.isDenied || photoStatus.isPermanentlyDenied) {
        emit(state.copyWith(isLoading: false));
        return true; // Permission was handled, but denied
      }

      // Select image
      final imageFile = await _imageCaptureService.selectFromGallery();
      
      if (imageFile != null) {
        emit(state.copyWith(
          imageFile: imageFile,
          isLoading: false,
        ));
      } else {
        // User cancelled
        emit(state.copyWith(isLoading: false));
      }
      
      return true; // Permission was handled successfully
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to select image',
      ));
      return true;
    }
  }

  /// Clears the current image
  Future<void> clearImage() async {
    if (state.imageFile != null) {
      await _imageCaptureService.deleteImage(state.imageFile);
    }
    emit(state.clearImage());
  }

  /// Resets the state but keeps the image
  void resetLoadingState() {
    emit(state.copyWith(
      isLoading: false,
      isCamera: false,
      isGallery: false,
    ));
  }

  @override
  Future<void> close() async {
    // Clean up any remaining image file
    await _imageCaptureService.deleteImage(state.imageFile);
    return super.close();
  }
}