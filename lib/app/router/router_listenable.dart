import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/auth/presentation/providers/auth_notifier.dart';

class RouterListenable extends ChangeNotifier {
  RouterListenable(this._ref) {
    _ref.listen<AsyncValue<AuthUser?>>(
      authNotifierProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref _ref;

  AsyncValue<AuthUser?> get authState => _ref.read(authNotifierProvider);
}

final routerListenableProvider = Provider<RouterListenable>(
  (ref) => RouterListenable(ref),
);
