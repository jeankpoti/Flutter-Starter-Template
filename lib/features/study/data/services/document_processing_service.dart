import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Service for processing PDF and document files
/// Since we don't have a PDF text extraction library, we'll send PDFs as images to the AI
class DocumentProcessingService {
  static final DocumentProcessingService _instance = DocumentProcessingService._internal();
  
  factory DocumentProcessingService() {
    return _instance;
  }
  
  DocumentProcessingService._internal();
  
  /// Process a PDF file and prepare it for AI analysis
  /// For now, we'll treat PDFs as binary data that the AI can analyze
  Future<Uint8List> processPdfFile(File pdfFile) async {
    try {
      // Read the PDF file as bytes
      final bytes = await pdfFile.readAsBytes();
      
      // Validate file size (limit to 10MB for PDFs)
      const maxSizeBytes = 10 * 1024 * 1024; // 10MB
      if (bytes.length > maxSizeBytes) {
        final sizeMB = bytes.length / (1024 * 1024);
        throw DocumentProcessingException(
          'PDF file size (${sizeMB.toStringAsFixed(1)}MB) exceeds the maximum allowed size of 10MB'
        );
      }
      
      return bytes;
    } catch (e) {
      if (e is DocumentProcessingException) rethrow;
      throw DocumentProcessingException('Failed to process PDF file: $e');
    }
  }
  
  /// Validate if the file is a valid PDF
  bool isValidPdfFile(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return extension == 'pdf';
  }
  
  /// Get file size in MB
  Future<double> getFileSizeInMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }
}

/// Custom exception for document processing errors
class DocumentProcessingException implements Exception {
  final String message;
  
  DocumentProcessingException(this.message);
  
  @override
  String toString() => 'DocumentProcessingException: $message';
}