import 'package:flutter/material.dart';

import '../../../shared/presentation/widgets/placeholder_feature_content.dart';

class LearnPlaceholderScreen extends StatelessWidget {
  const LearnPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureContent(
      icon: Icons.menu_book_outlined,
      title: 'Learn',
      subtitle: 'Baybayin reference',
      body: 'Character lessons and kudlit practice will open here.',
    );
  }
}
