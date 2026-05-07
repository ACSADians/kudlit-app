// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns the user's current consecutive-day learning streak.
///
/// A streak is the number of calendar days in a row (ending today or
/// yesterday) on which the user completed at least one lesson. Derived
/// purely from [learning_progress.completed_at] — no new table needed.
///
/// Returns 0 for unauthenticated users or on any network error.

@ProviderFor(streak)
final streakProvider = StreakProvider._();

/// Returns the user's current consecutive-day learning streak.
///
/// A streak is the number of calendar days in a row (ending today or
/// yesterday) on which the user completed at least one lesson. Derived
/// purely from [learning_progress.completed_at] — no new table needed.
///
/// Returns 0 for unauthenticated users or on any network error.

final class StreakProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Returns the user's current consecutive-day learning streak.
  ///
  /// A streak is the number of calendar days in a row (ending today or
  /// yesterday) on which the user completed at least one lesson. Derived
  /// purely from [learning_progress.completed_at] — no new table needed.
  ///
  /// Returns 0 for unauthenticated users or on any network error.
  StreakProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return streak(ref);
  }
}

String _$streakHash() => r'63590e45bc24f3a3b53cbd58b41ee45afda6846c';
