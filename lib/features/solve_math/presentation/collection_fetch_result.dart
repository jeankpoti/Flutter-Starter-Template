// Create a class to hold the result of fetching animals, including the last document
import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/models/collection.dart';

class CollectionFetchResult {
  final List<Collection> collections;
  final DocumentSnapshot?
  lastDocument; // The last document fetched in this batch

  CollectionFetchResult({required this.collections, this.lastDocument});
}
