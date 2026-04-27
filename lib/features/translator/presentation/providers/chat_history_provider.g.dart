// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatHistoryNotifierHash() =>
    r'c0000000000000000000000000000000000000c1';

@ProviderFor(ChatHistoryNotifier)
final chatHistoryNotifierProvider =
    AsyncNotifierProvider<ChatHistoryNotifier, List<ChatMessage>>.internal(
      ChatHistoryNotifier.new,
      name: r'chatHistoryNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatHistoryNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatHistoryNotifier = AsyncNotifier<List<ChatMessage>>;

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
