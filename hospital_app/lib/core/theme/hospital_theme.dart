import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Unified Hospital Theme System
/// Ensures consistent design language across login, developer mode, and main app
class HospitalTheme {
  HospitalTheme._();

  // Base theme configuration
  static const double _borderRadius = 12.0;
  static const double _cardBorderRadius = 16.0;
  static const double _buttonHeight = 48.0;

  /// Light theme for main application
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  /// Dark theme for main application (matches login/developer screens)
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  /// Build unified theme with consistent styling
  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme colorScheme = _getColorScheme(brightness);

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      // Card theme
      cardTheme: CardTheme(
        elevation: isDark ? 8 : 4,
        color: colorScheme.surface,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardBorderRadius),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          minimumSize: const Size(double.infinity, _buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark 
            ? colorScheme.surface.withOpacity(0.8)
            : colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.inter(
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
        labelStyle: GoogleFonts.inter(
          color: colorScheme.onSurface.withOpacity(0.8),
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: colorScheme.surface,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 16,
          color: colorScheme.onSurface,
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
      ),
    );
  }

  /// Get color scheme for theme
  static ColorScheme _getColorScheme(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.dark,
        surface: const Color(0xFF1E293B), // Dark slate background
        onSurface: Colors.white,
      );
    } else {
      return ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.light,
        surface: Colors.white,
        onSurface: Colors.black87,
      );
    }
  }

  /// Consistent gradient backgrounds for special screens
  static LinearGradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1E293B), // Dark slate
          Color(0xFF0F172A), // Darker slate
          Color(0xFF020617), // Almost black
        ],
        stops: [0.0, 0.6, 1.0],
      );

  /// Status colors for consistent feedback
  static const Color successColor = AppColors.success;
  static const Color warningColor = AppColors.warning;
  static const Color errorColor = AppColors.error;
  static const Color infoColor = AppColors.info;

  /// Role-based colors for character cards
  static const Map<String, Color> roleColors = {
    'admin': Color(0xFFEF4444), // Red
    'doctor': Color(0xFF3B82F6), // Blue
    'nurse': Color(0xFF14B8A6), // Teal
    'patient': Color(0xFFEC4899), // Pink
    'receptionist': Color(0xFF8B5CF6), // Purple
    'laboratory': Color(0xFFF59E0B), // Orange
    'pharmacist': Color(0xFF10B981), // Green
  };

  /// Get role color safely
  static Color getRoleColor(String role) {
    return roleColors[role] ?? const Color(0xFF6B7280); // Default gray
  }

  /// Developer mode specific colors
  static const Color developerModeColor = AppColors.warning;
  static const Color actionLogColor = Color(0xFF06B6D4); // Cyan
  static const Color undoActionColor = Color(0xFFF59E0B); // Orange

  /// Consistent spacing values
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  /// Consistent border radius values
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXl = 24.0;
}