// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_management_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

/// See also [supabase].
@ProviderFor(supabase)
final supabaseProvider = Provider<SupabaseClient>.internal(
  supabase,
  name: r'supabaseProvider',
  from: null,
  argument: null,
  isAutoDispose: true,
  dependencies: null,
  $allTransitiveDependencies: null,
  retry: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SupabaseRef = Ref;

/// See also [profileManagementDatasource].
@ProviderFor(profileManagementDatasource)
final profileManagementDatasourceProvider =
    Provider<ProfileManagementDatasource>.internal(
      profileManagementDatasource,
      name: r'profileManagementDatasourceProvider',
      from: null,
      argument: null,
      isAutoDispose: true,
      dependencies: null,
      $allTransitiveDependencies: null,
      retry: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileManagementDatasourceRef = Ref;

/// See also [localProfileManagementDatasource].
@ProviderFor(localProfileManagementDatasource)
final localProfileManagementDatasourceProvider =
    Provider<LocalProfileManagementDatasource>.internal(
      localProfileManagementDatasource,
      name: r'localProfileManagementDatasourceProvider',
      from: null,
      argument: null,
      isAutoDispose: false,
      dependencies: null,
      $allTransitiveDependencies: null,
      retry: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalProfileManagementDatasourceRef = Ref;

/// See also [profileManagementRepository].
@ProviderFor(profileManagementRepository)
final profileManagementRepositoryProvider =
    Provider<ProfileManagementRepository>.internal(
      profileManagementRepository,
      name: r'profileManagementRepositoryProvider',
      from: null,
      argument: null,
      isAutoDispose: true,
      dependencies: null,
      $allTransitiveDependencies: null,
      retry: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileManagementRepositoryRef = Ref;

/// See also [getProfileSummaryUseCase].
@ProviderFor(getProfileSummaryUseCase)
final getProfileSummaryUseCaseProvider = Provider<GetProfileSummary>.internal(
  getProfileSummaryUseCase,
  name: r'getProfileSummaryUseCaseProvider',
  from: null,
  argument: null,
  isAutoDispose: true,
  dependencies: null,
  $allTransitiveDependencies: null,
  retry: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetProfileSummaryUseCaseRef = Ref;

/// See also [getProfilePreferencesUseCase].
@ProviderFor(getProfilePreferencesUseCase)
final getProfilePreferencesUseCaseProvider =
    Provider<GetProfilePreferences>.internal(
      getProfilePreferencesUseCase,
      name: r'getProfilePreferencesUseCaseProvider',
      from: null,
      argument: null,
      isAutoDispose: true,
      dependencies: null,
      $allTransitiveDependencies: null,
      retry: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetProfilePreferencesUseCaseRef = Ref;

/// See also [updateDisplayNameUseCase].
@ProviderFor(updateDisplayNameUseCase)
final updateDisplayNameUseCaseProvider = Provider<UpdateDisplayName>.internal(
  updateDisplayNameUseCase,
  name: r'updateDisplayNameUseCaseProvider',
  from: null,
  argument: null,
  isAutoDispose: true,
  dependencies: null,
  $allTransitiveDependencies: null,
  retry: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpdateDisplayNameUseCaseRef = Ref;

/// See also [saveProfilePreferencesUseCase].
@ProviderFor(saveProfilePreferencesUseCase)
final saveProfilePreferencesUseCaseProvider =
    Provider<SaveProfilePreferences>.internal(
      saveProfilePreferencesUseCase,
      name: r'saveProfilePreferencesUseCaseProvider',
      from: null,
      argument: null,
      isAutoDispose: true,
      dependencies: null,
      $allTransitiveDependencies: null,
      retry: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SaveProfilePreferencesUseCaseRef = Ref;

/// See also [ProfileSummaryNotifier].
@ProviderFor(ProfileSummaryNotifier)
final profileSummaryNotifierProvider =
    AsyncNotifierProvider<
      ProfileSummaryNotifier,
      Option<ProfileSummary>
    >.internal(
      ProfileSummaryNotifier.new,
      name: r'profileSummaryNotifierProvider',
      from: null,
      argument: null,
      isAutoDispose: true,
      dependencies: null,
      $allTransitiveDependencies: null,
      retry: null,
    );

typedef _$ProfileSummaryNotifier = AsyncNotifier<Option<ProfileSummary>>;

/// See also [ProfilePreferencesNotifier].
@ProviderFor(ProfilePreferencesNotifier)
final profilePreferencesNotifierProvider =
    AsyncNotifierProvider<
      ProfilePreferencesNotifier,
      Option<ProfilePreferences>
    >.internal(
      ProfilePreferencesNotifier.new,
      name: r'profilePreferencesNotifierProvider',
      from: null,
      argument: null,
      isAutoDispose: true,
      dependencies: null,
      $allTransitiveDependencies: null,
      retry: null,
    );

typedef _$ProfilePreferencesNotifier =
    AsyncNotifier<Option<ProfilePreferences>>;

// ignore_for_file: type=lint
// ignore_for_file: unused_element, subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
