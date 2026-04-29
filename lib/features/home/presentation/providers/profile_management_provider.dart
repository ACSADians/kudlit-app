import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kudlit_ph/core/usecases/usecase.dart';
import 'package:kudlit_ph/features/home/data/datasources/profile_management_datasource.dart';
import 'package:kudlit_ph/features/home/data/repositories/profile_management_repository_impl.dart';
import 'package:kudlit_ph/features/home/domain/entities/profile_preferences.dart';
import 'package:kudlit_ph/features/home/domain/entities/profile_summary.dart';
import 'package:kudlit_ph/features/home/domain/repositories/profile_management_repository.dart';
import 'package:kudlit_ph/features/home/domain/usecases/get_profile_preferences.dart';
import 'package:kudlit_ph/features/home/domain/usecases/get_profile_summary.dart';
import 'package:kudlit_ph/features/home/domain/usecases/save_profile_preferences.dart';
import 'package:kudlit_ph/features/home/domain/usecases/update_display_name.dart';

part 'profile_management_provider.g.dart';

@riverpod
SupabaseClient supabase(SupabaseRef ref) {
  return Supabase.instance.client;
}

@riverpod
ProfileManagementDatasource profileManagementDatasource(
  ProfileManagementDatasourceRef ref,
) {
  return SupabaseProfileManagementDatasource(ref.watch(supabaseProvider));
}

@riverpod
ProfileManagementRepository profileManagementRepository(
  ProfileManagementRepositoryRef ref,
) {
  return ProfileManagementRepositoryImpl(
    ref.watch(profileManagementDatasourceProvider),
  );
}

@riverpod
GetProfileSummary getProfileSummaryUseCase(GetProfileSummaryUseCaseRef ref) {
  return GetProfileSummary(ref.watch(profileManagementRepositoryProvider));
}

@riverpod
GetProfilePreferences getProfilePreferencesUseCase(
  GetProfilePreferencesUseCaseRef ref,
) {
  return GetProfilePreferences(ref.watch(profileManagementRepositoryProvider));
}

@riverpod
UpdateDisplayName updateDisplayNameUseCase(UpdateDisplayNameUseCaseRef ref) {
  return UpdateDisplayName(ref.watch(profileManagementRepositoryProvider));
}

@riverpod
SaveProfilePreferences saveProfilePreferencesUseCase(
  SaveProfilePreferencesUseCaseRef ref,
) {
  return SaveProfilePreferences(ref.watch(profileManagementRepositoryProvider));
}

@riverpod
class ProfileSummaryNotifier extends _$ProfileSummaryNotifier {
  @override
  FutureOr<Option<ProfileSummary>> build() async {
    return _fetchSummary();
  }

  Future<Option<ProfileSummary>> _fetchSummary() async {
    final useCase = ref.read(getProfileSummaryUseCaseProvider);
    final result = await useCase(const NoParams());
    return result.fold((l) => const None(), (r) => Some(r));
  }

  Future<void> updateDisplayName(String displayName) async {
    state = const AsyncValue.loading();
    final useCase = ref.read(updateDisplayNameUseCaseProvider);
    final result = await useCase(
      UpdateDisplayNameParams(displayName: displayName),
    );

    state = await result.fold(
      (l) => AsyncValue.error(l, StackTrace.current),
      (r) async => AsyncValue.data(await _fetchSummary()),
    );
  }
}

@riverpod
class ProfilePreferencesNotifier extends _$ProfilePreferencesNotifier {
  @override
  FutureOr<Option<ProfilePreferences>> build() async {
    return _fetchPreferences();
  }

  Future<Option<ProfilePreferences>> _fetchPreferences() async {
    final useCase = ref.read(getProfilePreferencesUseCaseProvider);
    final result = await useCase(const NoParams());
    return result.fold((l) => const None(), (r) => Some(r));
  }

  Future<void> updatePreferences(ProfilePreferences preferences) async {
    state = const AsyncValue.loading();
    final useCase = ref.read(saveProfilePreferencesUseCaseProvider);
    final result = await useCase(
      SaveProfilePreferencesParams(preferences: preferences),
    );

    state = await result.fold(
      (l) => AsyncValue.error(l, StackTrace.current),
      (r) async => AsyncValue.data(await _fetchPreferences()),
    );
  }
}
