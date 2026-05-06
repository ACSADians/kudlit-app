import 'package:flutter/material.dart';

import 'create_account_button.dart';

class GuestTile extends StatelessWidget {
  const GuestTile({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool narrow = constraints.maxWidth < 280;
          final Widget identity = Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primaryContainer,
                  border: Border.all(color: cs.outline),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 22,
                  color: cs.onSurface.withAlpha(102),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Guest',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      'Not signed in',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: cs.onSurface.withAlpha(128),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                identity,
                const SizedBox(height: 12),
                const CreateAccountButton(fullWidth: true),
              ],
            );
          }

          return Row(
            children: <Widget>[
              Expanded(child: identity),
              const SizedBox(width: 12),
              const Flexible(flex: 0, child: CreateAccountButton()),
            ],
          );
        },
      ),
    );
  }
}
