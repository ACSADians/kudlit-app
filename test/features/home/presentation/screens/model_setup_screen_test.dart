import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kudlit_ph/features/home/presentation/providers/model_setup_controller.dart';
import 'package:kudlit_ph/features/home/presentation/screens/model_setup_screen.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_provider.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_state.dart';

void main() {
  testWidgets('model setup hides raw network exception details', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 593));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiInferenceNotifierProvider.overrideWith(
            _RawErrorInferenceNotifier.new,
          ),
        ],
        child: const MaterialApp(home: ModelSetupScreen()),
      ),
    );
    await tester.pump();

    expect(
      find.textContaining(
        'Check your connection, then retry the model download.',
      ),
      findsWidgets,
    );
    expect(find.textContaining('AuthRetryableFetchException'), findsNothing);
    expect(find.textContaining('SocketException'), findsNothing);
    expect(find.textContaining('supabase.co'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('model setup download error also uses friendly copy', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(593, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          modelSetupControllerProvider.overrideWith(
            _RawErrorModelSetupController.new,
          ),
          aiInferenceNotifierProvider.overrideWith(
            _RawErrorInferenceNotifier.new,
          ),
        ],
        child: const MaterialApp(home: ModelSetupScreen()),
      ),
    );
    await tester.pump();

    expect(
      find.textContaining(
        'Check your connection, then retry the model download.',
      ),
      findsWidgets,
    );
    expect(find.textContaining('SocketException'), findsNothing);
    expect(find.textContaining('supabase.co'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class _RawErrorInferenceNotifier extends AiInferenceNotifier {
  @override
  Future<AiInferenceState> build() async => const AiInferenceError(
    'AuthRetryableFetchException(message: ClientException with '
    'SocketException: Failed host lookup: rxrreoftioidkvdowauv.supabase.co)',
  );
}

class _RawErrorModelSetupController extends ModelSetupController {
  @override
  ModelSetupState build() => const ModelSetupState(
    busy: false,
    errorMessage:
        'ClientException with SocketException: Failed host lookup: '
        'rxrreoftioidkvdowauv.supabase.co',
  );
}
