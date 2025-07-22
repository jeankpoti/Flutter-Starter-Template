import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import '../../domain/models/collection.dart';
import '../../domain/respository/firebase_collection_repo.dart';
import '../../presentation/collection_fetch_result.dart';

class FirebaseMathRepo implements FirebaseCollectionRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  final user = FirebaseAuth.instance.currentUser;

  CollectionReference get _collection => firestore.collection('homework');

  @override
  Future<CollectionFetchResult> getCollections({
    DocumentSnapshot?
    lastDocument, // Pass the last document of the previous page
    int limit = 10, // Number of problems to fetch per page
  }) async {
    try {
      print('FirebaseMathRepo: Getting collections for user: ${user?.uid}');
      if (user != null) {
        final userId = user!.uid;
        Query query = _collection
            .where('userId', isEqualTo: userId)
            // IMPORTANT: You NEED an orderBy clause for consistent pagination.
            // Choose a field that makes sense, like a timestamp.
            // Ensure this field exists in your documents and you have an index for it.
            .orderBy(
              'createdAt',
              descending: true,
            ); // Example: order by creation time

        if (lastDocument != null) {
          query = query.startAfterDocument(lastDocument);
        }

        final snapshot = await query.limit(limit).get();
        print('FirebaseMathRepo: Found ${snapshot.docs.length} documents');

        final collections =
            snapshot.docs.map((doc) {
              print(
                'FirebaseMathRepo: Processing doc ${doc.id}: ${doc.data()}',
              );
              return Collection.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              });
            }).toList();

        final DocumentSnapshot? newLastDocument =
            snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

        print('FirebaseMathRepo: Returning ${collections.length} collections');
        return CollectionFetchResult(
          collections: collections,
          lastDocument: newLastDocument,
        );
      } else {
        print('FirebaseMathRepo: No user logged in');
      }
    } catch (e) {
      print('Error fetching collections in Repo: $e');
      // Rethrow or handle as per your app's error strategy
      rethrow;
    }
    // Return an empty result if user is null or other unhandled cases
    return CollectionFetchResult(collections: []);
  }

  @override
  Future<void> saveCollection(Collection collection) async {
    try {
      if (user != null) {
        final userId = user!.uid;

        final docRef = _collection.doc();

        // Store collection data with image URL placeholder
        Map<String, dynamic> collectionData = {
          ...collection.toJson(),
          'userId': userId,
          'id': docRef.id,
          'createdAt': FieldValue.serverTimestamp(),
        };

        // If we have an image file path
        if (collection.imagePath != null && collection.imagePath!.isNotEmpty) {
          // Upload the image to Firebase Storage
          String? imageUrl = await _uploadImage(
            File(collection.imagePath!),
            userId,
          );

          if (imageUrl != null) {
            // Update animal data with the image URL
            collectionData['imageUrl'] = imageUrl;
          }
        }

        // Save to Firestore (single set operation)
        await docRef.set(collectionData);
      }
    } catch (e) {
      rethrow; // Rethrow to handle in the UI
    }
  }

  /// Uploads an image to Firebase Storage and returns the download URL
  Future<String?> _uploadImage(File imageFile, String userId) async {
    try {
      // Create a unique filename
      final fileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';

      // Create storage reference
      final storageRef = storage.ref().child('homework_images/$fileName');

      // Upload the file
      final uploadTask = storageRef.putFile(imageFile);

      // Wait for the upload to complete
      final snapshot = await uploadTask.whenComplete(() {});

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteCollection(Collection collection) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        if (collection.id != null) {
          // First delete the image if it exists
          if (collection.imageUrl != null && collection.imageUrl!.isNotEmpty) {
            // Extract the file path from the URL
            final fileExists = await _doesFileExist(collection.imageUrl!);
            if (fileExists) {
              try {
                final ref = storage.refFromURL(collection.imageUrl!);
                await ref.delete();
              } catch (e) {
                // Continue with document deletion
              }
            }
            // try {
            //   // Create a reference from the URL
            //   final ref = storage.refFromURL(animal.imageUrl!);
            //   await ref.delete();
            // } catch (e) {
            //   // Continue with document deletion even if image deletion fails
            // }
          }

          // Delete the Firestore document
          await _collection.doc(collection.id).delete();
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> _doesFileExist(String url) async {
    try {
      final ref = storage.refFromURL(url);
      await ref.getMetadata(); // This will throw if file doesn't exist
      return true;
    } catch (e) {
      return false;
    }
  }
}
