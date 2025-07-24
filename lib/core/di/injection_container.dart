import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/network_info.dart';
import '../../features/study/data/datasources/study_material_local_datasource.dart';
import '../../features/study/data/datasources/study_material_remote_datasource.dart';
import '../../features/study/data/repositories/study_material_repository_impl.dart';
import '../../features/study/domain/repositories/study_material_repository.dart';
import '../../features/study/domain/usecases/get_user_materials.dart';
import '../../features/study/domain/usecases/save_material.dart';
import '../../features/study/domain/usecases/upload_and_process_image.dart';
import '../../features/study/domain/usecases/process_text_content.dart';
import '../../features/study/presentation/bloc/study_bloc.dart';

/// Service locator instance
final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // Core dependencies
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  
  // Initialize feature dependencies
  await _initStudyFeature();
  await _initAccountFeature();
  await _initSolveMathFeature();
  await _initSubscriptionFeature();
}

/// Initialize study feature dependencies
Future<void> _initStudyFeature() async {
  // Data sources
  getIt.registerLazySingleton<StudyMaterialRemoteDataSource>(() =>
      StudyMaterialRemoteDataSourceImpl(
        firestore: getIt(),
        storage: getIt(),
        auth: getIt(),
      ));

  getIt.registerLazySingleton<StudyMaterialLocalDataSource>(() =>
      StudyMaterialLocalDataSourceImpl(
        sharedPreferences: getIt(),
      ));

  // Repository
  getIt.registerLazySingleton<StudyMaterialRepository>(() =>
      StudyMaterialRepositoryImpl(
        remoteDataSource: getIt(),
        localDataSource: getIt(),
        networkInfo: getIt(),
      ));

  // Use cases
  getIt.registerLazySingleton(() => GetUserMaterialsUseCase(getIt()));
  getIt.registerLazySingleton(() => SaveMaterialUseCase(getIt()));
  getIt.registerLazySingleton(() => UploadAndProcessImageUseCase(getIt()));
  getIt.registerLazySingleton(() => ProcessTextContentUseCase(getIt()));

  // BLoCs - will be registered as factories for fresh instances
  getIt.registerFactory(() => StudyBloc(
        getUserMaterials: getIt(),
        uploadAndProcessImage: getIt(),
        processTextContent: getIt(),
        repository: getIt(),
      ));
}

/// Initialize account feature dependencies
Future<void> _initAccountFeature() async {
  // TODO: Initialize account feature dependencies
}

/// Initialize solve math feature dependencies
Future<void> _initSolveMathFeature() async {
  // TODO: Initialize solve math feature dependencies
}

/// Initialize subscription feature dependencies
Future<void> _initSubscriptionFeature() async {
  // TODO: Initialize subscription feature dependencies
}