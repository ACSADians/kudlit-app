import 'package:flutter/material.dart';

import 'kudlit_colors.dart';

class KudlitTheme {
  const KudlitTheme._();

  static ThemeData get light {
    final ColorScheme colorScheme = const ColorScheme.light(
      primary: KudlitColors.primary,
      onPrimary: KudlitColors.onPrimary,
      secondary: KudlitColors.blue700,
      onSecondary: Colors.white,
      error: KudlitColors.danger400,
      onError: Colors.white,
      surface: KudlitColors.paper,
      onSurface: KudlitColors.foreground,
      outline: KudlitColors.borderSoft,
      outlineVariant: KudlitColors.grey400,
      shadow: Color(0x290E1425),
    );

    final TextTheme base = Typography.material2021().black;
    final TextTheme textTheme = base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 40,
        height: 1.15,
        fontWeight: FontWeight.w700,
        color: KudlitColors.blue300,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 32,
        height: 1.15,
        fontWeight: FontWeight.w700,
        color: KudlitColors.blue300,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 24,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: KudlitColors.blue400,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: KudlitColors.blue400,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.5,
        color: KudlitColors.foreground,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.5,
        color: KudlitColors.foreground,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.5,
        color: KudlitColors.subtleForeground,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w600,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: KudlitColors.background,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: KudlitColors.topbar,
        foregroundColor: KudlitColors.blue900,
        centerTitle: false,
        elevation: 2,
        scrolledUnderElevation: 2,
      ),
      cardTheme: CardThemeData(
        color: KudlitColors.paper,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: KudlitColors.borderSoft),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.75),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: _inputBorder(KudlitColors.borderSoft),
        enabledBorder: _inputBorder(KudlitColors.borderSoft),
        focusedBorder: _inputBorder(KudlitColors.primary),
        errorBorder: _inputBorder(KudlitColors.danger400),
        focusedErrorBorder: _inputBorder(KudlitColors.danger400),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: KudlitColors.primary,
          foregroundColor: KudlitColors.onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KudlitColors.blue300,
          side: const BorderSide(color: KudlitColors.border),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KudlitColors.blue300,
          textStyle: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        disabledColor: KudlitColors.grey500,
        selectedColor: KudlitColors.yellow200,
        secondarySelectedColor: KudlitColors.yellow200,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        labelStyle: textTheme.bodySmall?.copyWith(
          color: KudlitColors.blue300,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: KudlitColors.borderSoft),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      dividerTheme: const DividerThemeData(
        color: KudlitColors.grey400,
        thickness: 1,
      ),
    );
  }

  static TextStyle baybayinDisplay(BuildContext context) {
    return Theme.of(context).textTheme.displayLarge!.copyWith(
      fontFamily: 'Baybayin Simple TAWBID',
      fontWeight: FontWeight.w400,
    );
  }

  static OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color),
    );
  }
}
