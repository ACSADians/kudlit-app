import 'package:meta/meta.dart';

@immutable
class ProfilePreferences {
  const ProfilePreferences({
    required this.highContrast,
    required this.reducedMotion,
    required this.dataSharingConsent,
  });

  final bool highContrast;
  final bool reducedMotion;
  final bool dataSharingConsent;

  ProfilePreferences copyWith({
    bool? highContrast,
    bool? reducedMotion,
    bool? dataSharingConsent,
  }) {
    return ProfilePreferences(
      highContrast: highContrast ?? this.highContrast,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      dataSharingConsent: dataSharingConsent ?? this.dataSharingConsent,
    );
  }
}
