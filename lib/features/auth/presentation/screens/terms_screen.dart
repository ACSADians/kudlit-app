import 'package:flutter/material.dart';

import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/legal_document_screen.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Terms of Service',
      subtitle: 'The rules for using Kudlit respectfully and safely.',
      lastUpdated: 'May 6, 2026',
      summaryTitle: 'Quick read',
      summary:
          'Kudlit is a Baybayin learning, translation, and scanner app. Use it '
          'for learning and practice, keep your account safe, and avoid using '
          'the app in ways that harm people, services, or cultural learning.',
      relatedAction: LegalRelatedAction(
        label: 'Read Privacy Policy',
        route: AppConstants.routePrivacyPolicy,
      ),
      sections: <LegalSectionData>[
        LegalSectionData(
          title: 'Using Kudlit',
          body:
              'Kudlit helps you study Baybayin, practice kudlit marks, scan or '
              'upload images for recognition, and translate or explain text. '
              'The app is meant for education and personal learning, not for '
              'official, legal, medical, financial, or emergency decisions.',
          points: <String>[
            'You may use guest mode where available, but some features work best with an account.',
            'You are responsible for checking learning, translation, and scanner results before relying on them.',
          ],
        ),
        LegalSectionData(
          title: 'Your account',
          body:
              'If you create an account, use accurate sign-in information and '
              'protect your password, email account, and device access. You are '
              'responsible for activity that happens under your account.',
          points: <String>[
            'Tell us or reset your password if you believe your account is no longer secure.',
            'Do not use another person\'s account or attempt to bypass authentication.',
          ],
        ),
        LegalSectionData(
          title: 'Acceptable use',
          body:
              'Use Kudlit in a way that supports learning and respects other '
              'people, the app, and the services that keep it running.',
          points: <String>[
            'Do not upload, draw, or submit harmful, abusive, illegal, or privacy-invading content.',
            'Do not attempt to disrupt, reverse engineer, overload, scrape, or abuse the app or its services.',
            'Do not misrepresent scanner or AI-assisted results as guaranteed or official translations.',
          ],
        ),
        LegalSectionData(
          title: 'Learning, scanner, and AI results',
          body:
              'Kudlit may use local models, browser/device capabilities, and '
              'cloud-assisted AI features to provide feedback. These results '
              'can be incomplete or wrong, especially with unclear images, '
              'unusual handwriting, mixed text, or ambiguous input.',
          points: <String>[
            'Treat results as learning support, not final authority.',
            'Camera, gallery, sketchpad, and text inputs should only include content you are allowed to use.',
          ],
        ),
        LegalSectionData(
          title: 'App changes and availability',
          body:
              'Kudlit may change, pause, remove, or improve features over time. '
              'Some features may depend on device support, browser support, '
              'network access, model availability, or third-party services.',
          points: <String>[
            'We try to keep the app useful, but we cannot promise uninterrupted or error-free access.',
            'If a feature is unavailable, the app may show fallback states or disable related controls.',
          ],
        ),
        LegalSectionData(
          title: 'Intellectual property',
          body:
              'The Kudlit app, interface, artwork, design system, code, and '
              'learning materials belong to their respective owners. Your own '
              'inputs remain yours, but you allow Kudlit to process them so the '
              'requested feature can work.',
          points: <String>[
            'Do not copy or reuse Kudlit assets outside the app unless you have permission.',
            'Do not submit content unless you have the right to use it.',
          ],
        ),
        LegalSectionData(
          title: 'If these terms change',
          body:
              'We may update these terms as Kudlit grows. If changes are '
              'important, we will try to make them visible in the app. '
              'Continuing to use Kudlit after updates means you accept the '
              'current terms.',
        ),
      ],
    );
  }
}
