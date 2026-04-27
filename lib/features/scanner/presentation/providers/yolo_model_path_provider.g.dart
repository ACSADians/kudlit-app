// GENERATED CODE - DO NOT MODIFY BY HAND
// Hand-written: build_runner unavailable (Xcode licence issue — exit 69).

part of 'yolo_model_path_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$yoloModelPathHash() => r'yoloModelPath';

/// Resolves the effective YOLO model path, checking for a locally cached
/// download before falling back to the bundled Flutter asset.
///
/// Copied from [yoloModelPath].
@ProviderFor(yoloModelPath)
final yoloModelPathProvider = FutureProvider<String>.internal(
  yoloModelPath,
  name: r'yoloModelPathProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$yoloModelPathHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead.')
typedef YoloModelPathRef = FutureProviderRef<String>;

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
