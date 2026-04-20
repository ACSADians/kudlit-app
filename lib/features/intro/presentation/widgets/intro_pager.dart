import 'package:flutter/material.dart';

import '../models/intro_slide_content.dart';
import 'intro_page.dart';

class IntroPager extends StatelessWidget {
  const IntroPager({
    required this.controller,
    required this.onPageChanged,
    super.key,
  });

  final PageController controller;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: introSlides.length,
      onPageChanged: onPageChanged,
      itemBuilder: (BuildContext context, int index) {
        return IntroPage(slide: introSlides[index]);
      },
    );
  }
}
