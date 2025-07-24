import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/study_material_model.dart';

/// Abstract class for local data source
abstract class StudyMaterialLocalDataSource {
  Future<List<StudyMaterialModel>> getCachedMaterials();
  Future<void> cacheMaterials(List<StudyMaterialModel> materials);
  Future<StudyMaterialModel?> getCachedMaterial(String id);
  Future<void> cacheMaterial(StudyMaterialModel material);
  Future<void> removeCachedMaterial(String id);
  Future<void> clearCache();
}

/// Implementation of local data source using SharedPreferences
class StudyMaterialLocalDataSourceImpl implements StudyMaterialLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _cachedMaterialsKey = 'CACHED_STUDY_MATERIALS';
  static const String _materialPrefix = 'STUDY_MATERIAL_';

  StudyMaterialLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<StudyMaterialModel>> getCachedMaterials() async {
    try {
      final jsonString = sharedPreferences.getString(_cachedMaterialsKey);
      if (jsonString == null) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((jsonMap) => StudyMaterialModel.fromMap(jsonMap))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get cached materials: $e');
    }
  }

  @override
  Future<void> cacheMaterials(List<StudyMaterialModel> materials) async {
    try {
      final jsonList = materials.map((material) => material.toMap()).toList();
      final jsonString = json.encode(jsonList);
      await sharedPreferences.setString(_cachedMaterialsKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to cache materials: $e');
    }
  }

  @override
  Future<StudyMaterialModel?> getCachedMaterial(String id) async {
    try {
      final jsonString = sharedPreferences.getString('$_materialPrefix$id');
      if (jsonString == null) {
        return null;
      }

      final jsonMap = json.decode(jsonString);
      return StudyMaterialModel.fromMap(jsonMap);
    } catch (e) {
      throw CacheException('Failed to get cached material: $e');
    }
  }

  @override
  Future<void> cacheMaterial(StudyMaterialModel material) async {
    try {
      final jsonString = json.encode(material.toMap());
      await sharedPreferences.setString('$_materialPrefix${material.id}', jsonString);
    } catch (e) {
      throw CacheException('Failed to cache material: $e');
    }
  }

  @override
  Future<void> removeCachedMaterial(String id) async {
    try {
      await sharedPreferences.remove('$_materialPrefix$id');
    } catch (e) {
      throw CacheException('Failed to remove cached material: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(_cachedMaterialsKey);
      
      // Remove individual cached materials
      final keys = sharedPreferences.getKeys();
      final materialKeys = keys.where((key) => key.startsWith(_materialPrefix));
      
      for (final key in materialKeys) {
        await sharedPreferences.remove(key);
      }
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }
}