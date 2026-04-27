import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/auth/presentation/providers/auth_notifier.dart';
import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';

class RouterListenable extends ChangeNotifier {
  RouterListenable(this._ref) {
    _ref.listen<AsyncValue<AuthUser?>>(
      authNotifierProvider,
      (_, __) => notifyListeners(),
    );
    _ref.listen<AsyncValue<AppPreferences>>(
      appPreferencesNotifierProvider,
      (_, __) => notifyListeners(),
    );
    _ref.listen<bool>(
      modelSetupSkippedProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref _ref;

  AsyncValue<AuthUser?> get authState => _ref.read(authNotifierProvider);
  AsyncValue<AppPreferences> get prefsState =>
      _ref.read(appPreferencesNotifierProvider);

  /// True when the user tapped "Not now" this session.
  /// Resets to false on every cold launch — setup screen shows again next time.
  bool get sessionSkipped => _ref.read(modelSetupSkippedProvider);
}

final routerListenableProvider = Provider<RouterListenable>(
  (ref) => RouterListenable(ref),
);
