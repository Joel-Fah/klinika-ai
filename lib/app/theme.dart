import 'package:flutter/material.dart';

class KlinikaPalette {
  KlinikaPalette._();

  static const emerald = Color(0xFF00C48C);
  static const emeraldDim = Color(0xFF00A374);
  static const emeraldSurface = Color(0xFF0D2E24);

  static const ink = Color(0xFF0A0F0D);
  static const inkLight = Color(0xFF111C17);
  static const inkMid = Color(0xFF1A2B24);
  static const inkBorder = Color(0xFF263D33);

  static const snowWhite = Color(0xFFF5FBF8);
  static const mist = Color(0xFF8BA898);
  static const ghost = Color(0xFF4D6B5E);

  static const urgent = Color(0xFFFF5252);
  static const moderate = Color(0xFFFFB74D);
  static const routine = Color(0xFF00C48C);
}

class KlinikaSpacing {
  KlinikaSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class KlinikaRadius {
  KlinikaRadius._();

  static const sm = BorderRadius.all(Radius.circular(10));
  static const md = BorderRadius.all(Radius.circular(18));
  static const lg = BorderRadius.all(Radius.circular(24));
  static const xl = BorderRadius.all(Radius.circular(32));
  static const pill = BorderRadius.all(Radius.circular(100));
}

class KlinikaShapes {
  KlinikaShapes._();

  static const sm = ContinuousRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(18)),
  );
  static const md = ContinuousRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(28)),
  );
  static const lg = ContinuousRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(38)),
  );
  static const xl = ContinuousRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(52)),
  );
}

ThemeData buildKlinikaTheme() {
  final base = ThemeData.dark(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: KlinikaPalette.ink,
    colorScheme: const ColorScheme.dark(
      primary: KlinikaPalette.emerald,
      onPrimary: KlinikaPalette.ink,
      secondary: KlinikaPalette.emeraldDim,
      onSecondary: KlinikaPalette.snowWhite,
      surface: KlinikaPalette.inkLight,
      onSurface: KlinikaPalette.snowWhite,
      outline: KlinikaPalette.inkBorder,
      error: KlinikaPalette.urgent,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: KlinikaPalette.snowWhite,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: KlinikaPalette.snowWhite,
        height: 1.15,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: KlinikaPalette.snowWhite,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: KlinikaPalette.snowWhite,
      ),
      headlineSmall: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: KlinikaPalette.snowWhite,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: KlinikaPalette.snowWhite,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: KlinikaPalette.mist,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: KlinikaPalette.ghost,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: KlinikaPalette.snowWhite,
      ),
      labelMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: KlinikaPalette.mist,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: KlinikaPalette.ghost,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: KlinikaPalette.inkLight,
      border: OutlineInputBorder(
        borderRadius: KlinikaRadius.md,
        borderSide: const BorderSide(color: KlinikaPalette.inkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: KlinikaRadius.md,
        borderSide: const BorderSide(color: KlinikaPalette.inkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: KlinikaRadius.md,
        borderSide: const BorderSide(color: KlinikaPalette.emerald, width: 1.5),
      ),
      hintStyle: const TextStyle(color: KlinikaPalette.ghost),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: KlinikaSpacing.md,
        vertical: KlinikaSpacing.md,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: KlinikaPalette.emerald,
        foregroundColor: KlinikaPalette.ink,
        minimumSize: const Size.fromHeight(52),
        shape: KlinikaShapes.md,
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: KlinikaPalette.emerald,
        side: const BorderSide(color: KlinikaPalette.emerald),
        minimumSize: const Size.fromHeight(52),
        shape: KlinikaShapes.md,
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: KlinikaPalette.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: KlinikaPalette.snowWhite,
      ),
      iconTheme: IconThemeData(color: KlinikaPalette.snowWhite),
    ),
    dividerTheme: const DividerThemeData(
      color: KlinikaPalette.inkBorder,
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: KlinikaPalette.inkMid,
      selectedColor: KlinikaPalette.emeraldSurface,
      labelStyle: const TextStyle(
        color: KlinikaPalette.snowWhite,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      side: const BorderSide(color: KlinikaPalette.inkBorder),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(
        horizontal: KlinikaSpacing.sm,
        vertical: KlinikaSpacing.xs,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: KlinikaPalette.inkMid,
      contentTextStyle: const TextStyle(color: KlinikaPalette.snowWhite),
      shape: KlinikaShapes.md,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
