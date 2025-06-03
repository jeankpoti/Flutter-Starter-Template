/*
TodoRepo is an abstract class that defines the methods that the TodoRepository class must implement.

Here we define what the app can do
*/

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../presentation/collection_fetch_result.dart';
import '../models/collection.dart';

abstract class FirebaseCollectionRepo {
  // Future<List<Animal>> getAnimals();
  Future<CollectionFetchResult> getCollections({
    DocumentSnapshot? lastDocument,
    int limit,
  });

  Future<void> saveCollection(Collection collection);
  Future<void> deleteCollection(Collection collection);
}

/*

The repo in domain layer outlines what operations the app can do, bu
it doesn't worry about the specific implementation details. That's for the data layer.

- Everything in the domain layer should be technology-agnostic, which means it 
should not depend on any specific libraries or frameworks.

*/
