// lib/utils/app_theme.dart

import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF07090D);
  static const surface = Color(0xFF0D1017);
  static const card = Color(0xFF111520);
  static const card2 = Color(0xFF161C28);
  static const border = Color(0xFF1C2333);
  static const border2 = Color(0xFF232D42);

  static const red = Color(0xFFF03A47);
  static const orange = Color(0xFFF5722A);
  static const amber = Color(0xFFF5B429);
  static const lime = Color(0xFF4ADE80);
  static const cyan = Color(0xFF22D3EE);
  static const violet = Color(0xFFA78BFA);
  static const pink = Color(0xFFFB7185);

  static const text = Color(0xFFCFD8EC);
  static const dim = Color(0xFF8897B4);
  static const mute = Color(0xFF4A566E);

  // Workout type colors
  static const push = Color(0xFFF87080);
  static const pull = Color(0xFFF5935A);
  static const legs = Color(0xFFF5B429);
  static const combat = Color(0xFF22D3EE);
  static const fullBody = Color(0xFFA78BFA);
  static const rest = Color(0xFF4A566E);
  static const deload = Color(0xFFFB7185);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.red,
        secondary: AppColors.amber,
        surface: AppColors.surface,
        error: AppColors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: AppColors.text,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'BebasNeue',
          fontSize: 24,
          letterSpacing: 2,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.red,
        unselectedItemColor: AppColors.mute,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'BebasNeue', color: Colors.white, letterSpacing: 2),
        displayMedium: TextStyle(fontFamily: 'BebasNeue', color: Colors.white, letterSpacing: 2),
        displaySmall: TextStyle(fontFamily: 'BebasNeue', color: Colors.white, letterSpacing: 2),
        headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.text),
        bodyMedium: TextStyle(color: AppColors.text),
        bodySmall: TextStyle(color: AppColors.dim),
        labelLarge: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(color: AppColors.mute, letterSpacing: 1.5),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        labelStyle: const TextStyle(color: AppColors.dim),
        hintStyle: const TextStyle(color: AppColors.mute),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return AppColors.lime;
          return AppColors.border2;
        }),
        checkColor: MaterialStateProperty.all(Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  // Workout type → color mapping
  static Color workoutTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'push': return AppColors.push;
      case 'pull': return AppColors.pull;
      case 'legs': return AppColors.legs;
      case 'combat': return AppColors.combat;
      case 'fullbody': return AppColors.fullBody;
      case 'rest': return AppColors.rest;
      case 'deload': return AppColors.deload;
      default: return AppColors.dim;
    }
  }
}

// Custom text styles
class AppText {
  static const bebasLarge = TextStyle(
    fontFamily: 'BebasNeue', fontSize: 48,
    color: Colors.white, letterSpacing: 3,
  );
  static const bebasMed = TextStyle(
    fontFamily: 'BebasNeue', fontSize: 28,
    color: Colors.white, letterSpacing: 2,
  );
  static const bebasSmall = TextStyle(
    fontFamily: 'BebasNeue', fontSize: 20,
    color: Colors.white, letterSpacing: 2,
  );
  static const mono = TextStyle(
    fontFamily: 'JetBrainsMono', fontSize: 12,
    color: AppColors.dim, letterSpacing: 1,
  );
  static const monoLabel = TextStyle(
    fontFamily: 'JetBrainsMono', fontSize: 9,
    color: AppColors.mute, letterSpacing: 2,
  );
  static const body = TextStyle(fontSize: 14, color: AppColors.text);
  static const bodySmall = TextStyle(fontSize: 12, color: AppColors.dim);
}
