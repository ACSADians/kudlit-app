// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_inference_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiInferenceNotifierHash() =>
    r'58c48edd54379e73537142c7ff1b96587395e905';

/// Global, lazy AI inference notifier.
///
/// Not instantiated until first read. Once read it stays alive
/// (`keepAlive: true`) and routes to the correct backend
/// (local `flutter_gemma` or cloud stub) based on `AiPreference`.
///
/// Copied from [AiInferenceNotifier].
@ProviderFor(AiInferenceNotifier)
final aiInferenceNotifierProvider =
    AsyncNotifierProvider<AiInferenceNotifier, AiInferenceState>.internal(
      AiInferenceNotifier.new,
      name: r'aiInferenceNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$aiInferenceNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AiInferenceNotifier = AsyncNotifier<AiInferenceState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
