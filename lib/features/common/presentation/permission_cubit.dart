// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
// import '../data/services/permission_service.dart';

// // State
// class PermissionState extends Equatable {
//   final bool isLoading;
//   final bool hasCameraPermission;
//   final bool hasGalleryPermission;
//   final bool pendingCameraCheck;
//   final bool pendingGalleryCheck;
//   final String? message;

//   const PermissionState({
//     this.isLoading = false,
//     this.hasCameraPermission = false,
//     this.hasGalleryPermission = false,
//     this.pendingCameraCheck = false,
//     this.pendingGalleryCheck = false,
//     this.message,
//   });

//   PermissionState copyWith({
//     bool? isLoading,
//     bool? hasCameraPermission,
//     bool? hasGalleryPermission,
//     bool? pendingCameraCheck,
//     bool? pendingGalleryCheck,
//     String? message,
//   }) {
//     return PermissionState(
//       isLoading: isLoading ?? this.isLoading,
//       hasCameraPermission: hasCameraPermission ?? this.hasCameraPermission,
//       hasGalleryPermission: hasGalleryPermission ?? this.hasGalleryPermission,
//       pendingCameraCheck: pendingCameraCheck ?? this.pendingCameraCheck,
//       pendingGalleryCheck: pendingGalleryCheck ?? this.pendingGalleryCheck,
//       message: message,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         isLoading,
//         hasCameraPermission,
//         hasGalleryPermission,
//         pendingCameraCheck,
//         pendingGalleryCheck,
//         message,
//       ];
// }

// // Cubit
// class PermissionCubit extends Cubit<PermissionState> {
//   final PermissionService _permissionService;

//   PermissionCubit({
//     PermissionService? permissionService,
//   })  : _permissionService = permissionService ?? PermissionService(),
//         super(const PermissionState());

//   // Initialize permissions status
//   Future<void> initializePermissions() async {
//     final cameraGranted = await _permissionService.isCameraGranted();
//     final galleryGranted = await _permissionService.isGalleryGranted();

//     emit(state.copyWith(
//       hasCameraPermission: cameraGranted,
//       hasGalleryPermission: galleryGranted,
//     ));
//   }

//   // Request camera permission
//   Future<PermissionResult> requestCameraPermission() async {
//     emit(state.copyWith(isLoading: true));

//     try {
//       final result = await _permissionService.requestCameraPermission();
      
//       emit(state.copyWith(
//         isLoading: false,
//         hasCameraPermission: result.isGranted,
//         pendingCameraCheck: result.shouldShowDialog,
//       ));

//       return result;
//     } catch (e) {
//       emit(state.copyWith(
//         isLoading: false,
//         message: 'Error requesting camera permission',
//       ));
//       rethrow;
//     }
//   }

//   // Request gallery permission
//   Future<PermissionResult> requestGalleryPermission() async {
//     emit(state.copyWith(isLoading: true));

//     try {
//       final result = await _permissionService.requestGalleryPermission();
      
//       emit(state.copyWith(
//         isLoading: false,
//         hasGalleryPermission: result.isGranted,
//         pendingGalleryCheck: result.shouldShowDialog,
//       ));

//       return result;
//     } catch (e) {
//       emit(state.copyWith(
//         isLoading: false,
//         message: 'Error requesting gallery permission',
//       ));
//       rethrow;
//     }
//   }

//   // Check pending permissions after app resume
//   Future<void> checkPendingPermissions() async {
//     // Add delay to ensure settings changes are reflected
//     await Future.delayed(const Duration(milliseconds: 500));

//     if (state.pendingCameraCheck) {
//       final isGranted = await _permissionService.isCameraGranted();
      
//       emit(state.copyWith(
//         hasCameraPermission: isGranted,
//         pendingCameraCheck: false,
//         message: isGranted ? 'Camera permission granted. Please take the picture again.' : null,
//       ));
//     }

//     if (state.pendingGalleryCheck) {
//       final isGranted = await _permissionService.isGalleryGranted();
      
//       emit(state.copyWith(
//         hasGalleryPermission: isGranted,
//         pendingGalleryCheck: false,
//         message: isGranted ? 'Photo library permission granted. Please select the picture again.' : null,
//       ));
//     }
//   }

//   // Clear any messages
//   void clearMessage() {
//     emit(state.copyWith(message: null));
//   }

//   // Open app settings
//   Future<void> openSettings() async {
//     await _permissionService.openSettings();
//   }
// }