import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kudlit_ph/features/auth/domain/entities/country_code.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/country_picker_sheet.dart';

void main() {
  testWidgets('country picker fits a mobile web viewport without overflow', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 744));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: CountryPickerSheet(
              selected: CountryCode.ph,
              onSelect: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Select country code'), findsOneWidget);
    expect(find.text('Philippines'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
