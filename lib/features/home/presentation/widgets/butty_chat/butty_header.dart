import 'package:flutter/material.dart';

import 'butty_model_mode_selector.dart';
import 'butty_header_text.dart';

class ButtyHeader extends StatelessWidget {
  const ButtyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color headerBg =
        Theme.of(context).appBarTheme.backgroundColor ??
        cs.surfaceContainerHigh;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(bottom: BorderSide(color: cs.outline)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primaryContainer,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/brand/ButtyRead.webp',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 1,
                        right: 1,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF46B986),
                            shape: BoxShape.circle,
                            border: Border.all(color: headerBg, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: ButtyHeaderText()),
                ],
              ),
              const SizedBox(height: 10),
              const ButtyModelModeSelector(),
            ],
          ),
        ),
      ),
    );
  }
}
