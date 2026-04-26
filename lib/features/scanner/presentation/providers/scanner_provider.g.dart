// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanner_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$baybayinDetectorHash() => r'baybayinDetector';

/// Provides the correct [BaybayinDetector] for the current platform.
///
/// Copied from [baybayinDetector].
@ProviderFor(baybayinDetector)
final baybayinDetectorProvider = Provider<BaybayinDetector>.internal(
  baybayinDetector,
  name: r'baybayinDetectorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$baybayinDetectorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead.')
typedef BaybayinDetectorRef = ProviderRef<BaybayinDetector>;

String _$scannerNotifierHash() => r'scannerNotifier';

/// Holds the latest list of detections pushed from [ScannerCamera].
///
/// Copied from [ScannerNotifier].
@ProviderFor(ScannerNotifier)
final scannerNotifierProvider =
    AutoDisposeNotifierProvider<
      ScannerNotifier,
      List<BaybayinDetection>
    >.internal(
      ScannerNotifier.new,
      name: r'scannerNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$scannerNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ScannerNotifier = AutoDisposeNotifier<List<BaybayinDetection>>;

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
