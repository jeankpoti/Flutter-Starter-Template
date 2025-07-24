import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/study_material_entity.dart';
import '../../domain/repositories/study_material_repository.dart';
import '../datasources/study_material_local_datasource.dart';
import '../datasources/study_material_remote_datasource.dart';
import '../models/study_material_model.dart';

/// Implementation of StudyMaterialRepository
class StudyMaterialRepositoryImpl implements StudyMaterialRepository {
  final StudyMaterialRemoteDataSource remoteDataSource;
  final StudyMaterialLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  StudyMaterialRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<StudyMaterialEntity>>> getUserMaterials() async {
    try {
      if (await networkInfo.isConnected) {
        final materials = await remoteDataSource.getUserMaterials();
        await localDataSource.cacheMaterials(materials);
        return Success(materials.map((model) => model.toEntity()).toList());
      } else {
        final cachedMaterials = await localDataSource.getCachedMaterials();
        return Success(cachedMaterials.map((model) => model.toEntity()).toList());
      }
    } on ServerException catch (e) {
      // Try to return cached data on server error
      try {
        final cachedMaterials = await localDataSource.getCachedMaterials();
        return Success(cachedMaterials.map((model) => model.toEntity()).toList());
      } on CacheException {
        return Error(ServerFailure(e.message, e.code));
      }
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message, e.code));
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message, e.code));
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message, e.code));
    } catch (e) {
      return Error(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<StudyMaterialEntity>> getMaterialById(String id) async {
    try {
      if (await networkInfo.isConnected) {
        final material = await remoteDataSource.getMaterialById(id);
        await localDataSource.cacheMaterial(material);
        return Success(material.toEntity());
      } else {
        final cachedMaterial = await localDataSource.getCachedMaterial(id);
        if (cachedMaterial != null) {
          return Success(cachedMaterial.toEntity());
        } else {
          return const Error(CacheFailure('Material not found in cache'));
        }
      }
    } on ServerException catch (e) {
      // Try cached version
      try {
        final cachedMaterial = await localDataSource.getCachedMaterial(id);
        if (cachedMaterial != null) {
          return Success(cachedMaterial.toEntity());
        } else {
          return Error(ServerFailure(e.message, e.code));
        }
      } on CacheException {
        return Error(ServerFailure(e.message, e.code));
      }
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message, e.code));
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message, e.code));
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message, e.code));
    } on PermissionException catch (e) {
      return Error(PermissionFailure(e.message, e.code));
    } catch (e) {
      return Error(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> saveMaterial(StudyMaterialEntity material) async {
    try {
      final model = StudyMaterialModel.fromEntity(material);
      
      if (await networkInfo.isConnected) {
        await remoteDataSource.saveMaterial(model);
        await localDataSource.cacheMaterial(model);
        return const Success(null);
      } else {
        return const Error(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message, e.code));
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message, e.code));
    } on PermissionException catch (e) {
      return Error(PermissionFailure(e.message, e.code));
    } catch (e) {
      return Error(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> updateMaterial(StudyMaterialEntity material) async {
    try {
      final model = StudyMaterialModel.fromEntity(material);
      
      if (await networkInfo.isConnected) {
        await remoteDataSource.updateMaterial(model);
        await localDataSource.cacheMaterial(model);
        return const Success(null);
      } else {
        return const Error(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message, e.code));
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message, e.code));
    } on PermissionException catch (e) {
      return Error(PermissionFailure(e.message, e.code));
    } catch (e) {
      return Error(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> deleteMaterial(String id) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteMaterial(id);
        await localDataSource.removeCachedMaterial(id);
        return const Success(null);
      } else {
        return const Error(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message, e.code));
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message, e.code));
    } on PermissionException catch (e) {
      return Error(PermissionFailure(e.message, e.code));
    } catch (e) {
      return Error(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<StudyMaterialEntity>> uploadAndProcessImage({
    required String imagePath,
    required String title,
    String? description,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        // Generate unique ID for the material
        final materialId = DateTime.now().millisecondsSinceEpoch.toString();
        
        // Upload image first
        final downloadUrl = await remoteDataSource.uploadImage(imagePath, materialId);
        
        // Create material entity
        final material = StudyMaterialEntity(
          id: materialId,
          userId: '', // Will be set by remote data source
          title: title,
          description: description,
          type: MaterialType.image,
          status: MaterialStatus.processing,
          imagePath: downloadUrl,
          firebaseStoragePath: 'study_materials/$materialId.jpg',
          difficultyLevel: 'Elementary', // Default, will be analyzed
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Save the material
        final model = StudyMaterialModel.fromEntity(material);
        await remoteDataSource.saveMaterial(model);
        await localDataSource.cacheMaterial(model);
        
        return Success(material);
      } else {
        return const Error(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message, e.code));
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message, e.code));
    } catch (e) {
      return Error(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<StudyMaterialEntity>> processTextContent({
    required String content,
    required String title,
    String? description,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        // Generate unique ID for the material
        final materialId = DateTime.now().millisecondsSinceEpoch.toString();
        
        // Create material entity
        final material = StudyMaterialEntity(
          id: materialId,
          userId: '', // Will be set by remote data source
          title: title,
          description: description,
          type: MaterialType.text,
          status: MaterialStatus.processing,
          content: content,
          difficultyLevel: 'Elementary', // Default, will be analyzed
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Save the material
        final model = StudyMaterialModel.fromEntity(material);
        await remoteDataSource.saveMaterial(model);
        await localDataSource.cacheMaterial(model);
        
        return Success(material);
      } else {
        return const Error(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message, e.code));
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message, e.code));
    } catch (e) {
      return Error(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<StudyMaterialEntity>>> searchMaterials(String query) async {
    // For now, implement simple client-side search
    // In production, this should be server-side search
    final result = await getUserMaterials();
    return result.map((materials) {
      return materials.where((material) {
        return material.title.toLowerCase().contains(query.toLowerCase()) ||
               (material.description?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
               material.extractedTopics.any((topic) => 
                 topic.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    });
  }

  @override
  Future<Result<List<StudyMaterialEntity>>> getMaterialsByStatus(MaterialStatus status) async {
    final result = await getUserMaterials();
    return result.map((materials) {
      return materials.where((material) => material.status == status).toList();
    });
  }

  @override
  Future<Result<List<StudyMaterialEntity>>> getMaterialsByType(MaterialType type) async {
    final result = await getUserMaterials();
    return result.map((materials) {
      return materials.where((material) => material.type == type).toList();
    });
  }
}