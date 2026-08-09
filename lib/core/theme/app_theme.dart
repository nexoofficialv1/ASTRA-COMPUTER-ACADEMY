import 'package:flutter/material.dart';

class AppTheme {
  static const navy = Color(0xFF071A55);
  static const royalBlue = Color(0xFF1769E8);
  static const skyBlue = Color(0xFF21A7FF);
  static const canvas = Color(0xFFF5F7FB);
  static const ink = Color(0xFF172033);
  static const muted = Color(0xFF697386);
  static const success = Color(0xFF13A463);

  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: royalBlue,
      onPrimary: Colors.white,
      secondary: skyBlue,
      onSecondary: Colors.white,
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      surface: Colors.white,
      onSurface: ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      fontFamilyFallback: const ['Noto Sans Bengali', 'Noto Sans', 'sans-serif'],
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: navy,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: Color(0xFFE7EBF3)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 66,
        backgroundColor: navy,
        indicatorColor: royalBlue,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? Colors.white : Colors.white70);
        }),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Color(0xFFDDE3EE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Color(0xFFDDE3EE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: royalBlue, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: royalBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      linearProgressIndicatorTheme: const LinearProgressIndicatorThemeData(
        color: royalBlue,
        linearTrackColor: Color(0xFFE6ECF6),
        minHeight: 7,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      dividerColor: const Color(0xFFE7EBF3),
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: royalBlue,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0A1020),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF06133E),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: light.navigationBarTheme.copyWith(
        backgroundColor: const Color(0xFF06133E),
      ),
    );
  }
}
