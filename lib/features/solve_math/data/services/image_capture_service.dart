import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../../../common/utils/file_size_validator.dart';

/// Service responsible for handling image capture and upload operations
class ImageCaptureService {
  final ImagePicker _picker;
  
  ImageCaptureService({ImagePicker? picker}) 
    : _picker = picker ?? ImagePicker();

  /// Captures an image from the camera
  /// Returns the captured image file or null if cancelled
  Future<File?> captureFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo == null) {
        return null; // User cancelled
      }

      final file = await _saveImageSecurely(photo);
      
      // Validate file size for homework images (10MB max)
      if (!FileSizeValidator.isValidHomeworkImage(file)) {
        await deleteImage(file); // Clean up the file
        throw ImageCaptureException(
          FileSizeValidator.getFileSizeErrorMessage(
            file, 
            FileSizeValidator.homeworkImageMaxSizeMB
          )
        );
      }
      
      return file;
    } catch (e) {
      // Re-throw if it's already an ImageCaptureException
      if (e is ImageCaptureException) rethrow;
      // Log error or handle as needed
      throw ImageCaptureException('Failed to capture image from camera: $e');
    }
  }

  /// Selects an image from the gallery
  /// Returns the selected image file or null if cancelled
  Future<File?> selectFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 85,
      );

      if (image == null) {
        return null; // User cancelled
      }

      final file = await _saveImageSecurely(image);
      
      // Validate file size for homework images (10MB max)
      if (!FileSizeValidator.isValidHomeworkImage(file)) {
        await deleteImage(file); // Clean up the file
        throw ImageCaptureException(
          FileSizeValidator.getFileSizeErrorMessage(
            file, 
            FileSizeValidator.homeworkImageMaxSizeMB
          )
        );
      }
      
      return file;
    } catch (e) {
      // Re-throw if it's already an ImageCaptureException
      if (e is ImageCaptureException) rethrow;
      // Log error or handle as needed
      throw ImageCaptureException('Failed to select image from gallery: $e');
    }
  }

  /// Saves the image to a secure location in app documents directory
  Future<File> _saveImageSecurely(XFile image) async {
    try {
      // Get secure app documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      
      // Generate unique filename with timestamp
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = 'math_${timestamp}_${path.basename(image.path)}';
      final String secureFilePath = path.join(appDir.path, fileName);

      // Copy image to secure location
      final File localImage = File(secureFilePath);
      await localImage.writeAsBytes(await image.readAsBytes());

      return localImage;
    } catch (e) {
      throw ImageCaptureException('Failed to save image securely: $e');
    }
  }

  /// Deletes an image file if it exists
  Future<void> deleteImage(File? imageFile) async {
    if (imageFile != null && await imageFile.exists()) {
      try {
        await imageFile.delete();
      } catch (e) {
        // Log error but don't throw - deletion failure is not critical
      }
    }
  }
}

/// Custom exception for image capture errors
class ImageCaptureException implements Exception {
  final String message;
  
  ImageCaptureException(this.message);
  
  @override
  String toString() => 'ImageCaptureException: $message';
}