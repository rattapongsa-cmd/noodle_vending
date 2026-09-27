import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Emerald & Mint Cyber Green Theme
class AppColors {
  static const Color primaryDark = Color(0xFF0F3E36);
  static const Color primaryGreen = Color(0xFF135D4F);
  static const Color brightGreen = Color(0xFF10B981);
  static const Color mintAccent = Color(0xFF34D399);
  static const Color lightMintBg = Color(0xFFE6F4F1);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color white = Colors.white;
}

class AppTheme {
  static ThemeData get theme {
    final base = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightMintBg,
      primaryColor: AppColors.primaryGreen,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brightGreen,
        primary: AppColors.primaryGreen,
        secondary: AppColors.mintAccent,
        error: AppColors.dangerRed,
      ),
      useMaterial3: true,
    );

    final textTheme = GoogleFonts.kanitTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.kanit(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brightGreen,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.kanit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 3,
        shadowColor: AppColors.primaryDark.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
