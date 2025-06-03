import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../domain/models/collection.dart';

class FirebaseCollectionState extends Equatable {
  List<Collection> collections;
  final bool isLoading;
  final bool isError;
  final DocumentSnapshot?
  lastDocumentSnapshot; // Store the last fetched document
  final bool isLoadingMore; // For loading subsequent pages
  final bool hasMoreData;

  FirebaseCollectionState({
    this.collections = const [],
    this.isLoading = false,
    this.isError = false,
    this.lastDocumentSnapshot,
    this.isLoadingMore = false,
    this.hasMoreData = true,
  });

  FirebaseCollectionState copyWith({
    List<Collection>? collections,
    bool? isLoading,
    bool? isFirebaseing,
    bool? isError,
    DocumentSnapshot? lastDocumentSnapshot,
    bool? isLoadingMore,
    bool? hasMoreData,
    bool explicitNullLastDocument =
        false, // Helper to explicitly set lastDocument to null
  }) {
    return FirebaseCollectionState(
      collections: collections ?? this.collections,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      lastDocumentSnapshot:
          explicitNullLastDocument
              ? null
              : (lastDocumentSnapshot ?? this.lastDocumentSnapshot),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }

  @override
  List<Object?> get props => [
    collections,
    isLoading,
    isError,
    lastDocumentSnapshot,
    isLoadingMore,
    hasMoreData,
  ];
}
