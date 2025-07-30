import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/models/collection.dart';
import '../domain/respository/firebase_collection_repo.dart';
import 'firebase_collection_state.dart';

const int _defaultPageSize = 10; // Define how many items to load per page

class FirebaseCollectionCubit extends Cubit<FirebaseCollectionState> {
  final FirebaseCollectionRepo firebaseCollectionRepo;

  FirebaseCollectionCubit(this.firebaseCollectionRepo)
    : super(FirebaseCollectionState());

  // Fetches the initial set of animals or refreshes the list
  Future<void> getCollections({bool isRefresh = false}) async {
    if (isRefresh) {
      // For pull-to-refresh, reset everything
      emit(
        state.copyWith(
          isLoading: true,
          collections: [],
          lastDocumentSnapshot: null, // Explicitly set to null for clarity
          explicitNullLastDocument: true,
          hasMoreData: true, // Assume more data on refresh
          isError: false,
          isLoadingMore: false,
        ),
      );
    } else {
      // Initial load
      emit(
        state.copyWith(isLoading: true, isError: false, isLoadingMore: false),
      );
    }

    try {
      final result = await firebaseCollectionRepo.getCollections(
        limit: _defaultPageSize,
      );

      emit(
        state.copyWith(
          collections: result.collections,
          isLoading: false,
          lastDocumentSnapshot: result.lastDocument,
          // If fewer items than page size are returned, there's no more data
          hasMoreData:
              result.collections.length == _defaultPageSize &&
              result.lastDocument != null,
          isError: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isError: true,
          isLoading: false,
          collections: isRefresh ? [] : state.collections,
        ),
      );
    }
  }

  bool _isFetchingMore = false;

  // Fetches the next page of animals
  Future<void> loadMoreCollections() async {
    // Prevent multiple "load more" requests simultaneously or if no more data
    if (_isFetchingMore ||
        state.isLoadingMore ||
        !state.hasMoreData ||
        state.isLoading) {
      return;
    }

    _isFetchingMore = true;

    try {
      emit(state.copyWith(isLoadingMore: true, isError: false));

      final result = await firebaseCollectionRepo.getCollections(
        lastDocument: state.lastDocumentSnapshot,
        limit: _defaultPageSize,
      );

      final newCollectionList = List<Collection>.from(state.collections)
        ..addAll(result.collections);

      emit(
        state.copyWith(
          collections: newCollectionList,
          isLoadingMore: false,
          lastDocumentSnapshot: result.lastDocument,
          hasMoreData:
              result.collections.length == _defaultPageSize &&
              result.lastDocument != null,
          isError: false,
        ),
      );
    } catch (e) {
      _isFetchingMore = false;

      emit(
        state.copyWith(
          // Keep existing animals, but indicate error for load more
          isError: true, // Or a specific 'isLoadMoreError' flag
          isLoadingMore: false,
        ),
      );
    } finally {
      _isFetchingMore = false;
    }
  }

  // Future<void> getAnimals() async {
  //   emit(state.copyWith(isLoading: true));
  //   try {
  //     final animals = await firebaseAnimalRepo.getAnimals();

  //     emit(state.copyWith(animals: animals, isLoading: false));
  //   } catch (e) {
  //     emit(
  //       state.copyWith(animals: state.animals, isError: true, isLoading: false),
  //     );
  //   }
  // }

  Future<void> saveCollection(Collection collection) async {
    emit(state.copyWith(isLoading: true));
    try {
      await firebaseCollectionRepo.saveCollection(collection);

      final result = await firebaseCollectionRepo.getCollections();

      emit(state.copyWith(collections: result.collections, isLoading: false));
    } catch (e) {
      emit(state.copyWith(collections: state.collections, isLoading: false));
    }
  }

  Future<void> deleteCollection(Collection collection) async {
    emit(state.copyWith(isLoading: true));
    try {
      await firebaseCollectionRepo.deleteCollection(collection);

      final result = await firebaseCollectionRepo.getCollections();

      emit(state.copyWith(collections: result.collections, isLoading: false));
    } catch (e) {
      emit(state.copyWith(collections: state.collections, isLoading: false));
    }
  }
}
