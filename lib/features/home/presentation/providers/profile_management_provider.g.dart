// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_management_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$supabaseHash() => r'fb098cc6e867811a983d533c1ec70af181985fcf';

/// See also [supabase].
@ProviderFor(supabase)
final supabaseProvider = AutoDisposeProvider<SupabaseClient>.internal(
  supabase,
  name: r'supabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$supabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SupabaseRef = AutoDisposeProviderRef<SupabaseClient>;
String _$profileManagementDatasourceHash() =>
    r'365ae1c4b1ddc1bc71205973fc9fd46efaae0169';

/// See also [profileManagementDatasource].
@ProviderFor(profileManagementDatasource)
final profileManagementDatasourceProvider =
    AutoDisposeProvider<ProfileManagementDatasource>.internal(
      profileManagementDatasource,
      name: r'profileManagementDatasourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileManagementDatasourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileManagementDatasourceRef =
    AutoDisposeProviderRef<ProfileManagementDatasource>;
String _$localProfileManagementDatasourceHash() =>
    r'a745fbaf8272f848f5849f57fedad13760a7229d';

/// See also [localProfileManagementDatasource].
@ProviderFor(localProfileManagementDatasource)
final localProfileManagementDatasourceProvider =
    Provider<LocalProfileManagementDatasource>.internal(
      localProfileManagementDatasource,
      name: r'localProfileManagementDatasourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$localProfileManagementDatasourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalProfileManagementDatasourceRef =
    ProviderRef<LocalProfileManagementDatasource>;
String _$profileManagementRepositoryHash() =>
    r'2eaf582d0d5a0f94930fb97e1ece50cb608c6f21';

/// See also [profileManagementRepository].
@ProviderFor(profileManagementRepository)
final profileManagementRepositoryProvider =
    AutoDisposeProvider<ProfileManagementRepository>.internal(
      profileManagementRepository,
      name: r'profileManagementRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileManagementRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileManagementRepositoryRef =
    AutoDisposeProviderRef<ProfileManagementRepository>;
String _$getProfileSummaryUseCaseHash() =>
    r'a71dd6af2092eb7ff1fbc35155c5a6fdb6acc1d2';

/// See also [getProfileSummaryUseCase].
@ProviderFor(getProfileSummaryUseCase)
final getProfileSummaryUseCaseProvider =
    AutoDisposeProvider<GetProfileSummary>.internal(
      getProfileSummaryUseCase,
      name: r'getProfileSummaryUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getProfileSummaryUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetProfileSummaryUseCaseRef = AutoDisposeProviderRef<GetProfileSummary>;
String _$getProfilePreferencesUseCaseHash() =>
    r'3c0b4128743c67421d1f184f41f842b155d529a7';

/// See also [getProfilePreferencesUseCase].
@ProviderFor(getProfilePreferencesUseCase)
final getProfilePreferencesUseCaseProvider =
    AutoDisposeProvider<GetProfilePreferences>.internal(
      getProfilePreferencesUseCase,
      name: r'getProfilePreferencesUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getProfilePreferencesUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetProfilePreferencesUseCaseRef =
    AutoDisposeProviderRef<GetProfilePreferences>;
String _$updateDisplayNameUseCaseHash() =>
    r'f96ad3980545156cc06ce9e0ca3ba29299ace62b';

/// See also [updateDisplayNameUseCase].
@ProviderFor(updateDisplayNameUseCase)
final updateDisplayNameUseCaseProvider =
    AutoDisposeProvider<UpdateDisplayName>.internal(
      updateDisplayNameUseCase,
      name: r'updateDisplayNameUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$updateDisplayNameUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpdateDisplayNameUseCaseRef = AutoDisposeProviderRef<UpdateDisplayName>;
String _$saveProfilePreferencesUseCaseHash() =>
    r'c20e6defd68e19d82377c3c59af32224cffb22a0';

/// See also [saveProfilePreferencesUseCase].
@ProviderFor(saveProfilePreferencesUseCase)
final saveProfilePreferencesUseCaseProvider =
    AutoDisposeProvider<SaveProfilePreferences>.internal(
      saveProfilePreferencesUseCase,
      name: r'saveProfilePreferencesUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$saveProfilePreferencesUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SaveProfilePreferencesUseCaseRef =
    AutoDisposeProviderRef<SaveProfilePreferences>;
String _$profileSummaryNotifierHash() =>
    r'd31440cc011580ffdbb7f2f3bc583faa4d00a4ec';

/// See also [ProfileSummaryNotifier].
@ProviderFor(ProfileSummaryNotifier)
final profileSummaryNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      ProfileSummaryNotifier,
      Option<ProfileSummary>
    >.internal(
      ProfileSummaryNotifier.new,
      name: r'profileSummaryNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileSummaryNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProfileSummaryNotifier =
    AutoDisposeAsyncNotifier<Option<ProfileSummary>>;
String _$profilePreferencesNotifierHash() =>
    r'9657cfe982806b134ab4424fba9acb6356cf7d78';

/// See also [ProfilePreferencesNotifier].
@ProviderFor(ProfilePreferencesNotifier)
final profilePreferencesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      ProfilePreferencesNotifier,
      Option<ProfilePreferences>
    >.internal(
      ProfilePreferencesNotifier.new,
      name: r'profilePreferencesNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profilePreferencesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProfilePreferencesNotifier =
    AutoDisposeAsyncNotifier<Option<ProfilePreferences>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
