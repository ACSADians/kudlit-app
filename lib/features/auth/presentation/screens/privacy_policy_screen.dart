import 'package:flutter/material.dart';

import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/legal_document_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Privacy Policy',
      subtitle: 'How Kudlit handles account, learning, and app data.',
      lastUpdated: 'May 6, 2026',
      summaryTitle: 'Privacy summary',
      summary:
          'Kudlit uses only the data needed to sign you in, keep the app '
          'usable, remember your learning experience, and run features like '
          'translation, sketch feedback, and scanner support. We do not sell '
          'your personal data.',
      relatedAction: LegalRelatedAction(
        label: 'Read Terms of Service',
        route: AppConstants.routeTerms,
      ),
      sections: <LegalSectionData>[
        LegalSectionData(
          title: 'Information you provide',
          body:
              'Kudlit may receive information you enter directly into the app, '
              'including account sign-in details, profile preferences, learning '
              'answers, translation text, sketchpad strokes, camera captures, '
              'gallery images, and feedback prompts.',
          points: <String>[
            'Account sign-in can include email, password-based authentication, phone OTP, or Google sign-in details handled through the configured auth provider.',
            'Learning and practice data may include lesson progress, attempts, badges, settings, and app preferences.',
          ],
        ),
        LegalSectionData(
          title: 'Information from your device',
          body:
              'The app may use device or browser capabilities when you choose a '
              'feature that needs them. Examples include camera access for '
              'scanner preview, gallery access for uploads, and local storage '
              'for cached preferences or progress.',
          points: <String>[
            'Camera and gallery access are requested for scanner or upload workflows.',
            'Device, browser, and error information may help diagnose crashes, layout issues, or app reliability problems.',
          ],
        ),
        LegalSectionData(
          title: 'How Kudlit uses information',
          body:
              'Kudlit uses information to provide the app features you request, '
              'keep your session working, save progress, personalize settings, '
              'detect scanner results, generate practice feedback, and improve '
              'the quality and reliability of the experience.',
          points: <String>[
            'Inputs may be processed locally on your device or sent to configured app services when a feature requires it.',
            'We use aggregated or diagnostic information to find problems such as crashes, broken states, or layout overflow.',
          ],
        ),
        LegalSectionData(
          title: 'AI, translation, and scanner processing',
          body:
              'Some Kudlit features use model-based processing. Text, sketches, '
              'images, or scanner frames may be processed to produce answers, '
              'detections, explanations, or practice feedback.',
          points: <String>[
            'Do not submit sensitive personal information, private documents, or images you do not want processed.',
            'AI-assisted output can be inaccurate and should be reviewed before use.',
          ],
        ),
        LegalSectionData(
          title: 'Storage and service providers',
          body:
              'Kudlit may rely on trusted services for authentication, storage, '
              'database access, hosting, analytics, model delivery, or AI '
              'processing. These providers process data only as needed to run '
              'the app features and infrastructure.',
          points: <String>[
            'Authentication and profile data may be stored through the configured backend service.',
            'Some data may also stay locally on your device as cache, preferences, or offline support.',
          ],
        ),
        LegalSectionData(
          title: 'Sharing and selling',
          body:
              'Kudlit does not sell your personal data. We may share data only '
              'when needed to operate the app, comply with valid legal '
              'requirements, protect users, prevent abuse, or support the '
              'services that provide Kudlit features.',
        ),
        LegalSectionData(
          title: 'Your choices',
          body:
              'You control many privacy choices through your account, device, '
              'browser, and operating system settings. You can limit camera or '
              'gallery permissions, avoid optional inputs, use guest mode where '
              'available, or stop using the app.',
          points: <String>[
            'If you want account changes or data help, use the support/contact path provided by the project owner.',
            'Revoking permissions may disable features that depend on those permissions.',
          ],
        ),
        LegalSectionData(
          title: 'Security and retention',
          body:
              'Kudlit uses reasonable technical safeguards through the app and '
              'its configured providers, but no app or network can be perfectly '
              'secure. Data is kept only as long as needed for the app, legal '
              'requirements, safety, abuse prevention, or operational records.',
        ),
        LegalSectionData(
          title: 'Children and updates',
          body:
              'Kudlit is designed for learning, but children should use it with '
              'parent or guardian guidance when required. This policy may be '
              'updated as the app changes; the last-updated date shows the '
              'current version.',
        ),
      ],
    );
  }
}
