import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static TextStyle _outfit(FontWeight weight, double size, {Color? color}) {
    return GoogleFonts.outfit(
      fontWeight: weight,
      fontSize: size,
      height: 1.2,
      letterSpacing: 0,
      color: color ?? AppColors.text,
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);

    final textTheme = base.textTheme.copyWith(
      displayLarge: _outfit(FontWeight.w700, 57),
      displayMedium: _outfit(FontWeight.w700, 45),
      displaySmall: _outfit(FontWeight.w700, 36),
      headlineLarge: _outfit(FontWeight.w700, 32),
      headlineMedium: _outfit(FontWeight.w600, 28),
      headlineSmall: _outfit(FontWeight.w600, 24),
      titleLarge: _outfit(FontWeight.w600, 22),
      titleMedium: _outfit(FontWeight.w500, 16),
      titleSmall: _outfit(FontWeight.w500, 14),
      bodyLarge: _outfit(FontWeight.w400, 16),
      bodyMedium: _outfit(FontWeight.w400, 16),
      bodySmall: _outfit(FontWeight.w400, 14),
      labelLarge: _outfit(FontWeight.w500, 16),
      labelMedium: _outfit(FontWeight.w500, 14),
      labelSmall: _outfit(FontWeight.w400, 12),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.success,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _outfit(FontWeight.w600, 18),
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: _outfit(FontWeight.w400, 16, color: AppColors.hintText),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: _outfit(FontWeight.w500, 16, color: Colors.white),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: _outfit(FontWeight.w500, 16, color: Colors.white),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: _outfit(FontWeight.w500, 16),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.subtle,
        labelStyle: _outfit(FontWeight.w500, 12),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.mutedText,
      ),
    );
  }
}
