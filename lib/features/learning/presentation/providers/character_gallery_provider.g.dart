// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_gallery_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(characterGallery)
final characterGalleryProvider = CharacterGalleryProvider._();

final class CharacterGalleryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GlyphEntry>>,
          List<GlyphEntry>,
          FutureOr<List<GlyphEntry>>
        >
    with $FutureModifier<List<GlyphEntry>>, $FutureProvider<List<GlyphEntry>> {
  CharacterGalleryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'characterGalleryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$characterGalleryHash();

  @$internal
  @override
  $FutureProviderElement<List<GlyphEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GlyphEntry>> create(Ref ref) {
    return characterGallery(ref);
  }
}

String _$characterGalleryHash() => r'41628b5eadb1f6826f93934540d50450487631d7';
