import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/providers/butty_chat_controller.dart';

import 'butty_model_mode_selector.dart';
import 'butty_header_text.dart';

class ButtyHeader extends ConsumerWidget {
  const ButtyHeader({super.key});

  Future<void> _confirmStartFresh(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Start fresh?'),
          content: const Text(
            'This clears the visible conversation. Butty still remembers '
            'what you have shared in past chats — those memory facts are kept '
            'so future conversations stay personal.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Start fresh'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    await ref.read(buttyChatControllerProvider.notifier).startFresh();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
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
              const SizedBox(width: 10),
              const ButtyHeaderText(),
              const SizedBox(width: 10),
              const ButtyModelModeSelector(showHelperText: false),
              const Spacer(),
              PopupMenuButton<String>(
                tooltip: 'Chat options',
                icon: Icon(Icons.more_vert, color: cs.onSurface),
                onSelected: (String value) {
                  if (value == 'start_fresh') {
                    _confirmStartFresh(context, ref);
                  }
                },
                itemBuilder: (BuildContext ctx) {
                  return const <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'start_fresh',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.restart_alt),
                        title: Text('Start fresh'),
                        subtitle: Text('Clear chat, keep memory'),
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
