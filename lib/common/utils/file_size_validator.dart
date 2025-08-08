import 'dart:io';

/// Utility class for validating file sizes based on Firebase Storage rules
class FileSizeValidator {
  // Size limits in MB matching Firebase Storage rules
  static const int homeworkImageMaxSizeMB = 10;
  static const int studyMaterialMaxSizeMB = 50;
  static const int profilePictureMaxSizeMB = 5;
  static const int tempFileMaxSizeMB = 100;

  /// Validates if a file size is within the allowed limit
  static bool isValidFileSize(File file, int maxSizeMB) {
    final fileSizeInBytes = file.lengthSync();
    final maxSizeInBytes = maxSizeMB * 1024 * 1024;
    return fileSizeInBytes <= maxSizeInBytes;
  }

  /// Gets the file size in MB
  static double getFileSizeInMB(File file) {
    final fileSizeInBytes = file.lengthSync();
    return fileSizeInBytes / (1024 * 1024);
  }

  /// Validates homework image size (max 10MB)
  static bool isValidHomeworkImage(File file) {
    return isValidFileSize(file, homeworkImageMaxSizeMB);
  }

  /// Validates study material size (max 50MB)
  static bool isValidStudyMaterial(File file) {
    return isValidFileSize(file, studyMaterialMaxSizeMB);
  }

  /// Validates profile picture size (max 5MB)
  static bool isValidProfilePicture(File file) {
    return isValidFileSize(file, profilePictureMaxSizeMB);
  }

  /// Validates temp file size (max 100MB)
  static bool isValidTempFile(File file) {
    return isValidFileSize(file, tempFileMaxSizeMB);
  }

  /// Gets a user-friendly error message for file size validation
  static String getFileSizeErrorMessage(File file, int maxSizeMB) {
    final fileSizeMB = getFileSizeInMB(file);
    return 'File size (${fileSizeMB.toStringAsFixed(1)}MB) exceeds the maximum allowed size of ${maxSizeMB}MB';
  }

  /// Formats file size to a human-readable string
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}