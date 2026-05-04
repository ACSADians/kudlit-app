// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(QuizNotifier)
final quizProvider = QuizNotifierProvider._();

final class QuizNotifierProvider
    extends $AsyncNotifierProvider<QuizNotifier, QuizState?> {
  QuizNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quizProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quizNotifierHash();

  @$internal
  @override
  QuizNotifier create() => QuizNotifier();
}

String _$quizNotifierHash() => r'177360f3e00be97e6ff4829c0d7a6f014856ba4e';

abstract class _$QuizNotifier extends $AsyncNotifier<QuizState?> {
  FutureOr<QuizState?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<QuizState?>, QuizState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<QuizState?>, QuizState?>,
              AsyncValue<QuizState?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
