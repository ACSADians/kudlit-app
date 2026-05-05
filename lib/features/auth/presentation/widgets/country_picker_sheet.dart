import 'package:flutter/material.dart';
import '../../domain/entities/country_code.dart';

class CountryPickerSheet extends StatelessWidget {
  const CountryPickerSheet({
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final CountryCode selected;
  final ValueChanged<CountryCode> onSelect;

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.72;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight.clamp(320, 560).toDouble(),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 12),
            const _CountryPickerHandle(),
            const SizedBox(height: 16),
            const _CountryPickerHeader(),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: CountryCode.values.length,
                itemBuilder: (BuildContext context, int index) {
                  final CountryCode code = CountryCode.values[index];
                  return _CountryPickerTile(
                    code: code,
                    selected: code == selected,
                    onTap: () => onSelect(code),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryPickerHandle extends StatelessWidget {
  const _CountryPickerHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _CountryPickerHeader extends StatelessWidget {
  const _CountryPickerHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Select country code',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _CountryPickerTile extends StatelessWidget {
  const _CountryPickerTile({
    required this.code,
    required this.selected,
    required this.onTap,
  });

  final CountryCode code;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Text(code.flag, style: const TextStyle(fontSize: 22)),
      title: Text(
        code.name,
        style: TextStyle(
          fontSize: 14,
          color: cs.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Text(
        code.dialCode,
        style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(153)),
      ),
      selected: selected,
      selectedTileColor: cs.primary.withAlpha(30),
      onTap: onTap,
    );
  }
}
