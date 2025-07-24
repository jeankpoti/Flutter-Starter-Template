// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'study_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$StudyState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )
    materialsLoaded,
    required TResult Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )
    materialUploaded,
    required TResult Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )
    materialDeleted,
    required TResult Function(
      Failure failure,
      List<StudyMaterialEntity>? materials,
    )
    error,
    required TResult Function(
      String message,
      List<StudyMaterialEntity>? materials,
    )
    processing,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )?
    materialsLoaded,
    TResult? Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )?
    materialUploaded,
    TResult? Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )?
    materialDeleted,
    TResult? Function(Failure failure, List<StudyMaterialEntity>? materials)?
    error,
    TResult? Function(String message, List<StudyMaterialEntity>? materials)?
    processing,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )?
    materialsLoaded,
    TResult Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )?
    materialUploaded,
    TResult Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )?
    materialDeleted,
    TResult Function(Failure failure, List<StudyMaterialEntity>? materials)?
    error,
    TResult Function(String message, List<StudyMaterialEntity>? materials)?
    processing,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_MaterialsLoaded value) materialsLoaded,
    required TResult Function(_MaterialUploaded value) materialUploaded,
    required TResult Function(_MaterialDeleted value) materialDeleted,
    required TResult Function(_Error value) error,
    required TResult Function(_Processing value) processing,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_MaterialsLoaded value)? materialsLoaded,
    TResult? Function(_MaterialUploaded value)? materialUploaded,
    TResult? Function(_MaterialDeleted value)? materialDeleted,
    TResult? Function(_Error value)? error,
    TResult? Function(_Processing value)? processing,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_MaterialsLoaded value)? materialsLoaded,
    TResult Function(_MaterialUploaded value)? materialUploaded,
    TResult Function(_MaterialDeleted value)? materialDeleted,
    TResult Function(_Error value)? error,
    TResult Function(_Processing value)? processing,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudyStateCopyWith<$Res> {
  factory $StudyStateCopyWith(
    StudyState value,
    $Res Function(StudyState) then,
  ) = _$StudyStateCopyWithImpl<$Res, StudyState>;
}

/// @nodoc
class _$StudyStateCopyWithImpl<$Res, $Val extends StudyState>
    implements $StudyStateCopyWith<$Res> {
  _$StudyStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudyState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
    _$InitialImpl value,
    $Res Function(_$InitialImpl) then,
  ) = __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$StudyStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
    _$InitialImpl _value,
    $Res Function(_$InitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudyState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'StudyState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )
    materialsLoaded,
    required TResult Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )
    materialUploaded,
    required TResult Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )
    materialDeleted,
    required TResult Function(
      Failure failure,
      List<StudyMaterialEntity>? materials,
    )
    error,
    required TResult Function(
      String message,
      List<StudyMaterialEntity>? materials,
    )
    processing,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )?
    materialsLoaded,
    TResult? Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )?
    materialUploaded,
    TResult? Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )?
    materialDeleted,
    TResult? Function(Failure failure, List<StudyMaterialEntity>? materials)?
    error,
    TResult? Function(String message, List<StudyMaterialEntity>? materials)?
    processing,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )?
    materialsLoaded,
    TResult Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )?
    materialUploaded,
    TResult Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )?
    materialDeleted,
    TResult Function(Failure failure, List<StudyMaterialEntity>? materials)?
    error,
    TResult Function(String message, List<StudyMaterialEntity>? materials)?
    processing,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_MaterialsLoaded value) materialsLoaded,
    required TResult Function(_MaterialUploaded value) materialUploaded,
    required TResult Function(_MaterialDeleted value) materialDeleted,
    required TResult Function(_Error value) error,
    required TResult Function(_Processing value) processing,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_MaterialsLoaded value)? materialsLoaded,
    TResult? Function(_MaterialUploaded value)? materialUploaded,
    TResult? Function(_MaterialDeleted value)? materialDeleted,
    TResult? Function(_Error value)? error,
    TResult? Function(_Processing value)? processing,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_MaterialsLoaded value)? materialsLoaded,
    TResult Function(_MaterialUploaded value)? materialUploaded,
    TResult Function(_MaterialDeleted value)? materialDeleted,
    TResult Function(_Error value)? error,
    TResult Function(_Processing value)? processing,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements StudyState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
    _$LoadingImpl value,
    $Res Function(_$LoadingImpl) then,
  ) = __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$StudyStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
    _$LoadingImpl _value,
    $Res Function(_$LoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudyState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'StudyState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )
    materialsLoaded,
    required TResult Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )
    materialUploaded,
    required TResult Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )
    materialDeleted,
    required TResult Function(
      Failure failure,
      List<StudyMaterialEntity>? materials,
    )
    error,
    required TResult Function(
      String message,
      List<StudyMaterialEntity>? materials,
    )
    processing,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )?
    materialsLoaded,
    TResult? Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )?
    materialUploaded,
    TResult? Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )?
    materialDeleted,
    TResult? Function(Failure failure, List<StudyMaterialEntity>? materials)?
    error,
    TResult? Function(String message, List<StudyMaterialEntity>? materials)?
    processing,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )?
    materialsLoaded,
    TResult Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )?
    materialUploaded,
    TResult Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )?
    materialDeleted,
    TResult Function(Failure failure, List<StudyMaterialEntity>? materials)?
    error,
    TResult Function(String message, List<StudyMaterialEntity>? materials)?
    processing,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_MaterialsLoaded value) materialsLoaded,
    required TResult Function(_MaterialUploaded value) materialUploaded,
    required TResult Function(_MaterialDeleted value) materialDeleted,
    required TResult Function(_Error value) error,
    required TResult Function(_Processing value) processing,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_MaterialsLoaded value)? materialsLoaded,
    TResult? Function(_MaterialUploaded value)? materialUploaded,
    TResult? Function(_MaterialDeleted value)? materialDeleted,
    TResult? Function(_Error value)? error,
    TResult? Function(_Processing value)? processing,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_MaterialsLoaded value)? materialsLoaded,
    TResult Function(_MaterialUploaded value)? materialUploaded,
    TResult Function(_MaterialDeleted value)? materialDeleted,
    TResult Function(_Error value)? error,
    TResult Function(_Processing value)? processing,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements StudyState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$MaterialsLoadedImplCopyWith<$Res> {
  factory _$$MaterialsLoadedImplCopyWith(
    _$MaterialsLoadedImpl value,
    $Res Function(_$MaterialsLoadedImpl) then,
  ) = __$$MaterialsLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    List<StudyMaterialEntity> materials,
    List<StudyMaterialEntity>? filteredMaterials,
    String? searchQuery,
  });
}

/// @nodoc
class __$$MaterialsLoadedImplCopyWithImpl<$Res>
    extends _$StudyStateCopyWithImpl<$Res, _$MaterialsLoadedImpl>
    implements _$$MaterialsLoadedImplCopyWith<$Res> {
  __$$MaterialsLoadedImplCopyWithImpl(
    _$MaterialsLoadedImpl _value,
    $Res Function(_$MaterialsLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudyState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? materials = null,
    Object? filteredMaterials = freezed,
    Object? searchQuery = freezed,
  }) {
    return _then(
      _$MaterialsLoadedImpl(
        materials:
            null == materials
                ? _value._materials
                : materials // ignore: cast_nullable_to_non_nullable
                    as List<StudyMaterialEntity>,
        filteredMaterials:
            freezed == filteredMaterials
                ? _value._filteredMaterials
                : filteredMaterials // ignore: cast_nullable_to_non_nullable
                    as List<StudyMaterialEntity>?,
        searchQuery:
            freezed == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc

class _$MaterialsLoadedImpl implements _MaterialsLoaded {
  const _$MaterialsLoadedImpl({
    required final List<StudyMaterialEntity> materials,
    final List<StudyMaterialEntity>? filteredMaterials,
    this.searchQuery,
  }) : _materials = materials,
       _filteredMaterials = filteredMaterials;

  final List<StudyMaterialEntity> _materials;
  @override
  List<StudyMaterialEntity> get materials {
    if (_materials is EqualUnmodifiableListView) return _materials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_materials);
  }

  final List<StudyMaterialEntity>? _filteredMaterials;
  @override
  List<StudyMaterialEntity>? get filteredMaterials {
    final value = _filteredMaterials;
    if (value == null) return null;
    if (_filteredMaterials is EqualUnmodifiableListView)
      return _filteredMaterials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? searchQuery;

  @override
  String toString() {
    return 'StudyState.materialsLoaded(materials: $materials, filteredMaterials: $filteredMaterials, searchQuery: $searchQuery)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MaterialsLoadedImpl &&
            const DeepCollectionEquality().equals(
              other._materials,
              _materials,
            ) &&
            const DeepCollectionEquality().equals(
              other._filteredMaterials,
              _filteredMaterials,
            ) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_materials),
    const DeepCollectionEquality().hash(_filteredMaterials),
    searchQuery,
  );

  /// Create a copy of StudyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MaterialsLoadedImplCopyWith<_$MaterialsLoadedImpl> get copyWith =>
      __$$MaterialsLoadedImplCopyWithImpl<_$MaterialsLoadedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )
    materialsLoaded,
    required TResult Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )
    materialUploaded,
    required TResult Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )
    materialDeleted,
    required TResult Function(
      Failure failure,
      List<StudyMaterialEntity>? materials,
    )
    error,
    required TResult Function(
      String message,
      List<StudyMaterialEntity>? materials,
    )
    processing,
  }) {
    return materialsLoaded(materials, filteredMaterials, searchQuery);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )?
    materialsLoaded,
    TResult? Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )?
    materialUploaded,
    TResult? Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )?
    materialDeleted,
    TResult? Function(Failure failure, List<StudyMaterialEntity>? materials)?
    error,
    TResult? Function(String message, List<StudyMaterialEntity>? materials)?
    processing,
  }) {
    return materialsLoaded?.call(materials, filteredMaterials, searchQuery);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )?
    materialsLoaded,
    TResult Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )?
    materialUploaded,
    TResult Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )?
    materialDeleted,
    TResult Function(Failure failure, List<StudyMaterialEntity>? materials)?
    error,
    TResult Function(String message, List<StudyMaterialEntity>? materials)?
    processing,
    required TResult orElse(),
  }) {
    if (materialsLoaded != null) {
      return materialsLoaded(materials, filteredMaterials, searchQuery);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_MaterialsLoaded value) materialsLoaded,
    required TResult Function(_MaterialUploaded value) materialUploaded,
    required TResult Function(_MaterialDeleted value) materialDeleted,
    required TResult Function(_Error value) error,
    required TResult Function(_Processing value) processing,
  }) {
    return materialsLoaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_MaterialsLoaded value)? materialsLoaded,
    TResult? Function(_MaterialUploaded value)? materialUploaded,
    TResult? Function(_MaterialDeleted value)? materialDeleted,
    TResult? Function(_Error value)? error,
    TResult? Function(_Processing value)? processing,
  }) {
    return materialsLoaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_MaterialsLoaded value)? materialsLoaded,
    TResult Function(_MaterialUploaded value)? materialUploaded,
    TResult Function(_MaterialDeleted value)? materialDeleted,
    TResult Function(_Error value)? error,
    TResult Function(_Processing value)? processing,
    required TResult orElse(),
  }) {
    if (materialsLoaded != null) {
      return materialsLoaded(this);
    }
    return orElse();
  }
}

abstract class _MaterialsLoaded implements StudyState {
  const factory _MaterialsLoaded({
    required final List<StudyMaterialEntity> materials,
    final List<StudyMaterialEntity>? filteredMaterials,
    final String? searchQuery,
  }) = _$MaterialsLoadedImpl;

  List<StudyMaterialEntity> get materials;
  List<StudyMaterialEntity>? get filteredMaterials;
  String? get searchQuery;

  /// Create a copy of StudyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MaterialsLoadedImplCopyWith<_$MaterialsLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MaterialUploadedImplCopyWith<$Res> {
  factory _$$MaterialUploadedImplCopyWith(
    _$MaterialUploadedImpl value,
    $Res Function(_$MaterialUploadedImpl) then,
  ) = __$$MaterialUploadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    StudyMaterialEntity material,
    List<StudyMaterialEntity> allMaterials,
  });
}

/// @nodoc
class __$$MaterialUploadedImplCopyWithImpl<$Res>
    extends _$StudyStateCopyWithImpl<$Res, _$MaterialUploadedImpl>
    implements _$$MaterialUploadedImplCopyWith<$Res> {
  __$$MaterialUploadedImplCopyWithImpl(
    _$MaterialUploadedImpl _value,
    $Res Function(_$MaterialUploadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudyState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? material = null, Object? allMaterials = null}) {
    return _then(
      _$MaterialUploadedImpl(
        material:
            null == material
                ? _value.material
                : material // ignore: cast_nullable_to_non_nullable
                    as StudyMaterialEntity,
        allMaterials:
            null == allMaterials
                ? _value._allMaterials
                : allMaterials // ignore: cast_nullable_to_non_nullable
                    as List<StudyMaterialEntity>,
      ),
    );
  }
}

/// @nodoc

class _$MaterialUploadedImpl implements _MaterialUploaded {
  const _$MaterialUploadedImpl({
    required this.material,
    required final List<StudyMaterialEntity> allMaterials,
  }) : _allMaterials = allMaterials;

  @override
  final StudyMaterialEntity material;
  final List<StudyMaterialEntity> _allMaterials;
  @override
  List<StudyMaterialEntity> get allMaterials {
    if (_allMaterials is EqualUnmodifiableListView) return _allMaterials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allMaterials);
  }

  @override
  String toString() {
    return 'StudyState.materialUploaded(material: $material, allMaterials: $allMaterials)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MaterialUploadedImpl &&
            (identical(other.material, material) ||
                other.material == material) &&
            const DeepCollectionEquality().equals(
              other._allMaterials,
              _allMaterials,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    material,
    const DeepCollectionEquality().hash(_allMaterials),
  );

  /// Create a copy of StudyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MaterialUploadedImplCopyWith<_$MaterialUploadedImpl> get copyWith =>
      __$$MaterialUploadedImplCopyWithImpl<_$MaterialUploadedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )
    materialsLoaded,
    required TResult Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )
    materialUploaded,
    required TResult Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )
    materialDeleted,
    required TResult Function(
      Failure failure,
      List<StudyMaterialEntity>? materials,
    )
    error,
    required TResult Function(
      String message,
      List<StudyMaterialEntity>? materials,
    )
    processing,
  }) {
    return materialUploaded(material, allMaterials);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )?
    materialsLoaded,
    TResult? Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )?
    materialUploaded,
    TResult? Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )?
    materialDeleted,
    TResult? Function(Failure failure, List<StudyMaterialEntity>? materials)?
    error,
    TResult? Function(String message, List<StudyMaterialEntity>? materials)?
    processing,
  }) {
    return materialUploaded?.call(material, allMaterials);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )?
    materialsLoaded,
    TResult Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )?
    materialUploaded,
    TResult Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )?
    materialDeleted,
    TResult Function(Failure failure, List<StudyMaterialEntity>? materials)?
    error,
    TResult Function(String message, List<StudyMaterialEntity>? materials)?
    processing,
    required TResult orElse(),
  }) {
    if (materialUploaded != null) {
      return materialUploaded(material, allMaterials);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_MaterialsLoaded value) materialsLoaded,
    required TResult Function(_MaterialUploaded value) materialUploaded,
    required TResult Function(_MaterialDeleted value) materialDeleted,
    required TResult Function(_Error value) error,
    required TResult Function(_Processing value) processing,
  }) {
    return materialUploaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_MaterialsLoaded value)? materialsLoaded,
    TResult? Function(_MaterialUploaded value)? materialUploaded,
    TResult? Function(_MaterialDeleted value)? materialDeleted,
    TResult? Function(_Error value)? error,
    TResult? Function(_Processing value)? processing,
  }) {
    return materialUploaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_MaterialsLoaded value)? materialsLoaded,
    TResult Function(_MaterialUploaded value)? materialUploaded,
    TResult Function(_MaterialDeleted value)? materialDeleted,
    TResult Function(_Error value)? error,
    TResult Function(_Processing value)? processing,
    required TResult orElse(),
  }) {
    if (materialUploaded != null) {
      return materialUploaded(this);
    }
    return orElse();
  }
}

abstract class _MaterialUploaded implements StudyState {
  const factory _MaterialUploaded({
    required final StudyMaterialEntity material,
    required final List<StudyMaterialEntity> allMaterials,
  }) = _$MaterialUploadedImpl;

  StudyMaterialEntity get material;
  List<StudyMaterialEntity> get allMaterials;

  /// Create a copy of StudyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MaterialUploadedImplCopyWith<_$MaterialUploadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MaterialDeletedImplCopyWith<$Res> {
  factory _$$MaterialDeletedImplCopyWith(
    _$MaterialDeletedImpl value,
    $Res Function(_$MaterialDeletedImpl) then,
  ) = __$$MaterialDeletedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String materialId, List<StudyMaterialEntity> remainingMaterials});
}

/// @nodoc
class __$$MaterialDeletedImplCopyWithImpl<$Res>
    extends _$StudyStateCopyWithImpl<$Res, _$MaterialDeletedImpl>
    implements _$$MaterialDeletedImplCopyWith<$Res> {
  __$$MaterialDeletedImplCopyWithImpl(
    _$MaterialDeletedImpl _value,
    $Res Function(_$MaterialDeletedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudyState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? materialId = null, Object? remainingMaterials = null}) {
    return _then(
      _$MaterialDeletedImpl(
        materialId:
            null == materialId
                ? _value.materialId
                : materialId // ignore: cast_nullable_to_non_nullable
                    as String,
        remainingMaterials:
            null == remainingMaterials
                ? _value._remainingMaterials
                : remainingMaterials // ignore: cast_nullable_to_non_nullable
                    as List<StudyMaterialEntity>,
      ),
    );
  }
}

/// @nodoc

class _$MaterialDeletedImpl implements _MaterialDeleted {
  const _$MaterialDeletedImpl({
    required this.materialId,
    required final List<StudyMaterialEntity> remainingMaterials,
  }) : _remainingMaterials = remainingMaterials;

  @override
  final String materialId;
  final List<StudyMaterialEntity> _remainingMaterials;
  @override
  List<StudyMaterialEntity> get remainingMaterials {
    if (_remainingMaterials is EqualUnmodifiableListView)
      return _remainingMaterials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_remainingMaterials);
  }

  @override
  String toString() {
    return 'StudyState.materialDeleted(materialId: $materialId, remainingMaterials: $remainingMaterials)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MaterialDeletedImpl &&
            (identical(other.materialId, materialId) ||
                other.materialId == materialId) &&
            const DeepCollectionEquality().equals(
              other._remainingMaterials,
              _remainingMaterials,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    materialId,
    const DeepCollectionEquality().hash(_remainingMaterials),
  );

  /// Create a copy of StudyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MaterialDeletedImplCopyWith<_$MaterialDeletedImpl> get copyWith =>
      __$$MaterialDeletedImplCopyWithImpl<_$MaterialDeletedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )
    materialsLoaded,
    required TResult Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )
    materialUploaded,
    required TResult Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )
    materialDeleted,
    required TResult Function(
      Failure failure,
      List<StudyMaterialEntity>? materials,
    )
    error,
    required TResult Function(
      String message,
      List<StudyMaterialEntity>? materials,
    )
    processing,
  }) {
    return materialDeleted(materialId, remainingMaterials);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )?
    materialsLoaded,
    TResult? Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )?
    materialUploaded,
    TResult? Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )?
    materialDeleted,
    TResult? Function(Failure failure, List<StudyMaterialEntity>? materials)?
    error,
    TResult? Function(String message, List<StudyMaterialEntity>? materials)?
    processing,
  }) {
    return materialDeleted?.call(materialId, remainingMaterials);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )?
    materialsLoaded,
    TResult Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )?
    materialUploaded,
    TResult Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )?
    materialDeleted,
    TResult Function(Failure failure, List<StudyMaterialEntity>? materials)?
    error,
    TResult Function(String message, List<StudyMaterialEntity>? materials)?
    processing,
    required TResult orElse(),
  }) {
    if (materialDeleted != null) {
      return materialDeleted(materialId, remainingMaterials);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_MaterialsLoaded value) materialsLoaded,
    required TResult Function(_MaterialUploaded value) materialUploaded,
    required TResult Function(_MaterialDeleted value) materialDeleted,
    required TResult Function(_Error value) error,
    required TResult Function(_Processing value) processing,
  }) {
    return materialDeleted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_MaterialsLoaded value)? materialsLoaded,
    TResult? Function(_MaterialUploaded value)? materialUploaded,
    TResult? Function(_MaterialDeleted value)? materialDeleted,
    TResult? Function(_Error value)? error,
    TResult? Function(_Processing value)? processing,
  }) {
    return materialDeleted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_MaterialsLoaded value)? materialsLoaded,
    TResult Function(_MaterialUploaded value)? materialUploaded,
    TResult Function(_MaterialDeleted value)? materialDeleted,
    TResult Function(_Error value)? error,
    TResult Function(_Processing value)? processing,
    required TResult orElse(),
  }) {
    if (materialDeleted != null) {
      return materialDeleted(this);
    }
    return orElse();
  }
}

abstract class _MaterialDeleted implements StudyState {
  const factory _MaterialDeleted({
    required final String materialId,
    required final List<StudyMaterialEntity> remainingMaterials,
  }) = _$MaterialDeletedImpl;

  String get materialId;
  List<StudyMaterialEntity> get remainingMaterials;

  /// Create a copy of StudyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MaterialDeletedImplCopyWith<_$MaterialDeletedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
    _$ErrorImpl value,
    $Res Function(_$ErrorImpl) then,
  ) = __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Failure failure, List<StudyMaterialEntity>? materials});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$StudyStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl _value,
    $Res Function(_$ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudyState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? failure = null, Object? materials = freezed}) {
    return _then(
      _$ErrorImpl(
        failure:
            null == failure
                ? _value.failure
                : failure // ignore: cast_nullable_to_non_nullable
                    as Failure,
        materials:
            freezed == materials
                ? _value._materials
                : materials // ignore: cast_nullable_to_non_nullable
                    as List<StudyMaterialEntity>?,
      ),
    );
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl({
    required this.failure,
    final List<StudyMaterialEntity>? materials,
  }) : _materials = materials;

  @override
  final Failure failure;
  final List<StudyMaterialEntity>? _materials;
  @override
  List<StudyMaterialEntity>? get materials {
    final value = _materials;
    if (value == null) return null;
    if (_materials is EqualUnmodifiableListView) return _materials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'StudyState.error(failure: $failure, materials: $materials)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.failure, failure) || other.failure == failure) &&
            const DeepCollectionEquality().equals(
              other._materials,
              _materials,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    failure,
    const DeepCollectionEquality().hash(_materials),
  );

  /// Create a copy of StudyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )
    materialsLoaded,
    required TResult Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )
    materialUploaded,
    required TResult Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )
    materialDeleted,
    required TResult Function(
      Failure failure,
      List<StudyMaterialEntity>? materials,
    )
    error,
    required TResult Function(
      String message,
      List<StudyMaterialEntity>? materials,
    )
    processing,
  }) {
    return error(failure, materials);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )?
    materialsLoaded,
    TResult? Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )?
    materialUploaded,
    TResult? Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )?
    materialDeleted,
    TResult? Function(Failure failure, List<StudyMaterialEntity>? materials)?
    error,
    TResult? Function(String message, List<StudyMaterialEntity>? materials)?
    processing,
  }) {
    return error?.call(failure, materials);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )?
    materialsLoaded,
    TResult Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )?
    materialUploaded,
    TResult Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )?
    materialDeleted,
    TResult Function(Failure failure, List<StudyMaterialEntity>? materials)?
    error,
    TResult Function(String message, List<StudyMaterialEntity>? materials)?
    processing,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(failure, materials);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_MaterialsLoaded value) materialsLoaded,
    required TResult Function(_MaterialUploaded value) materialUploaded,
    required TResult Function(_MaterialDeleted value) materialDeleted,
    required TResult Function(_Error value) error,
    required TResult Function(_Processing value) processing,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_MaterialsLoaded value)? materialsLoaded,
    TResult? Function(_MaterialUploaded value)? materialUploaded,
    TResult? Function(_MaterialDeleted value)? materialDeleted,
    TResult? Function(_Error value)? error,
    TResult? Function(_Processing value)? processing,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_MaterialsLoaded value)? materialsLoaded,
    TResult Function(_MaterialUploaded value)? materialUploaded,
    TResult Function(_MaterialDeleted value)? materialDeleted,
    TResult Function(_Error value)? error,
    TResult Function(_Processing value)? processing,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements StudyState {
  const factory _Error({
    required final Failure failure,
    final List<StudyMaterialEntity>? materials,
  }) = _$ErrorImpl;

  Failure get failure;
  List<StudyMaterialEntity>? get materials;

  /// Create a copy of StudyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ProcessingImplCopyWith<$Res> {
  factory _$$ProcessingImplCopyWith(
    _$ProcessingImpl value,
    $Res Function(_$ProcessingImpl) then,
  ) = __$$ProcessingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, List<StudyMaterialEntity>? materials});
}

/// @nodoc
class __$$ProcessingImplCopyWithImpl<$Res>
    extends _$StudyStateCopyWithImpl<$Res, _$ProcessingImpl>
    implements _$$ProcessingImplCopyWith<$Res> {
  __$$ProcessingImplCopyWithImpl(
    _$ProcessingImpl _value,
    $Res Function(_$ProcessingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudyState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? materials = freezed}) {
    return _then(
      _$ProcessingImpl(
        message:
            null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                    as String,
        materials:
            freezed == materials
                ? _value._materials
                : materials // ignore: cast_nullable_to_non_nullable
                    as List<StudyMaterialEntity>?,
      ),
    );
  }
}

/// @nodoc

class _$ProcessingImpl implements _Processing {
  const _$ProcessingImpl({
    required this.message,
    final List<StudyMaterialEntity>? materials,
  }) : _materials = materials;

  @override
  final String message;
  final List<StudyMaterialEntity>? _materials;
  @override
  List<StudyMaterialEntity>? get materials {
    final value = _materials;
    if (value == null) return null;
    if (_materials is EqualUnmodifiableListView) return _materials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'StudyState.processing(message: $message, materials: $materials)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProcessingImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(
              other._materials,
              _materials,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    const DeepCollectionEquality().hash(_materials),
  );

  /// Create a copy of StudyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProcessingImplCopyWith<_$ProcessingImpl> get copyWith =>
      __$$ProcessingImplCopyWithImpl<_$ProcessingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )
    materialsLoaded,
    required TResult Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )
    materialUploaded,
    required TResult Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )
    materialDeleted,
    required TResult Function(
      Failure failure,
      List<StudyMaterialEntity>? materials,
    )
    error,
    required TResult Function(
      String message,
      List<StudyMaterialEntity>? materials,
    )
    processing,
  }) {
    return processing(message, materials);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )?
    materialsLoaded,
    TResult? Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )?
    materialUploaded,
    TResult? Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )?
    materialDeleted,
    TResult? Function(Failure failure, List<StudyMaterialEntity>? materials)?
    error,
    TResult? Function(String message, List<StudyMaterialEntity>? materials)?
    processing,
  }) {
    return processing?.call(message, materials);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<StudyMaterialEntity> materials,
      List<StudyMaterialEntity>? filteredMaterials,
      String? searchQuery,
    )?
    materialsLoaded,
    TResult Function(
      StudyMaterialEntity material,
      List<StudyMaterialEntity> allMaterials,
    )?
    materialUploaded,
    TResult Function(
      String materialId,
      List<StudyMaterialEntity> remainingMaterials,
    )?
    materialDeleted,
    TResult Function(Failure failure, List<StudyMaterialEntity>? materials)?
    error,
    TResult Function(String message, List<StudyMaterialEntity>? materials)?
    processing,
    required TResult orElse(),
  }) {
    if (processing != null) {
      return processing(message, materials);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_MaterialsLoaded value) materialsLoaded,
    required TResult Function(_MaterialUploaded value) materialUploaded,
    required TResult Function(_MaterialDeleted value) materialDeleted,
    required TResult Function(_Error value) error,
    required TResult Function(_Processing value) processing,
  }) {
    return processing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_MaterialsLoaded value)? materialsLoaded,
    TResult? Function(_MaterialUploaded value)? materialUploaded,
    TResult? Function(_MaterialDeleted value)? materialDeleted,
    TResult? Function(_Error value)? error,
    TResult? Function(_Processing value)? processing,
  }) {
    return processing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_MaterialsLoaded value)? materialsLoaded,
    TResult Function(_MaterialUploaded value)? materialUploaded,
    TResult Function(_MaterialDeleted value)? materialDeleted,
    TResult Function(_Error value)? error,
    TResult Function(_Processing value)? processing,
    required TResult orElse(),
  }) {
    if (processing != null) {
      return processing(this);
    }
    return orElse();
  }
}

abstract class _Processing implements StudyState {
  const factory _Processing({
    required final String message,
    final List<StudyMaterialEntity>? materials,
  }) = _$ProcessingImpl;

  String get message;
  List<StudyMaterialEntity>? get materials;

  /// Create a copy of StudyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProcessingImplCopyWith<_$ProcessingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
