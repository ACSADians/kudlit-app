import 'package:kudlit_ph/features/home/domain/entities/profile_preferences.dart';

class ProfilePreferencesModel extends ProfilePreferences {
  const ProfilePreferencesModel({
    required super.highContrast,
    required super.reducedMotion,
    required super.dataSharingConsent,
  });

  factory ProfilePreferencesModel.fromJson(Map<String, dynamic> json) {
    return ProfilePreferencesModel(
      highContrast: json['high_contrast'] as bool? ?? false,
      reducedMotion: json['reduced_motion'] as bool? ?? false,
      dataSharingConsent: json['data_sharing_consent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'high_contrast': highContrast,
      'reduced_motion': reducedMotion,
      'data_sharing_consent': dataSharingConsent,
    };
  }
}
