import 'package:flutter/material.dart';

class SuggestedQuestionsRow extends StatelessWidget {
  const SuggestedQuestionsRow({super.key, required this.onTap});

  final void Function(String question) onTap;

  static const double _floatingNavClearance = 72;

  static const List<String> _questions = <String>[
    'Write my name in Baybayin',
    'What is a kudlit?',
    'Baybayin history?',
    'Translate "mahal kita"',
    'How many letters are there?',
    'Why did Baybayin disappear?',
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: _floatingNavClearance),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
          itemCount: _questions.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, int i) => Semantics(
            button: true,
            label: _questions[i],
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onTap(_questions[i]),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: cs.primary.withAlpha(120)),
                    borderRadius: BorderRadius.circular(17),
                    color: cs.primary.withAlpha(16),
                  ),
                  child: Text(
                    _questions[i],
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
