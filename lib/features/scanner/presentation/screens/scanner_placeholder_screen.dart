import 'package:flutter/material.dart';

import '../../../shared/presentation/widgets/placeholder_feature_content.dart';

class ScannerPlaceholderScreen extends StatelessWidget {
  const ScannerPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureContent(
      icon: Icons.document_scanner_outlined,
      title: 'Kudlit',
      subtitle: 'Scan Baybayin',
      body: 'Camera detection will open here.',
    );
  }
}
