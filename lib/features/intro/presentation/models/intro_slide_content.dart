import 'package:flutter/material.dart';

class IntroSlideContent {
  const IntroSlideContent({
    required this.icon,
    required this.title,
    required this.body,
    required this.example,
  });

  final IconData icon;
  final String title;
  final String body;
  final String example;
}

const List<IntroSlideContent> introSlides = <IntroSlideContent>[
  IntroSlideContent(
    icon: Icons.auto_stories_outlined,
    title: 'What is Kudlit?',
    body:
        'A kudlit is the small mark that changes a Baybayin character vowel. '
        'Above changes ka to ki, below changes ka to ku.',
    example: 'ᜃ  ᜃᜒ  ᜃᜓ',
  ),
  IntroSlideContent(
    icon: Icons.camera_alt_outlined,
    title: 'Scan Baybayin',
    body:
        'Point your camera at handwritten or printed characters and let '
        'on-device detection find each glyph.',
    example: 'ᜊᜌ᜔ᜊᜌᜒᜈ᜔',
  ),
  IntroSlideContent(
    icon: Icons.translate_outlined,
    title: 'Translate and Learn',
    body:
        'Review the romanized reading, see what each mark changes, and build '
        'confidence with the character reference.',
    example: 'ka -> ki -> ku',
  ),
];
