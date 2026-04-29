import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/country_code.dart';

class PhoneField extends StatelessWidget {
  const PhoneField({
    required this.controller,
    required this.country,
    required this.onPickCountry,
    this.validator,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final CountryCode country;
  final VoidCallback onPickCountry;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: 'Phone number',
        border: const OutlineInputBorder(),
        prefixIcon: _CountryCodeButton(country: country, onTap: onPickCountry),
      ),
    );
  }
}

class _CountryCodeButton extends StatelessWidget {
  const _CountryCodeButton({required this.country, required this.onTap});

  final CountryCode country;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(country.flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 4),
            Text(
              country.dialCode,
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: cs.onSurface.withAlpha(128),
            ),
            const SizedBox(width: 4),
            Container(width: 1, height: 20, color: cs.outline),
          ],
        ),
      ),
    );
  }
}
