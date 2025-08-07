import 'package:flutter/material.dart';

/// Custom color palette for the Reality Anchor app
class GloopColors {
  // Core brand colors
  static const Color deepTeal = Color(0xFF157C84);
  static const Color mustardYellow = Color(0xFFE1B94A);
  static const Color warmBeige = Color(0xFFFDF3DE);
  static const Color gloopTeal = Color(0xFF38B3AC);
  static const Color darkTeal = Color(0xFF0F4C4D);

  // Additional utility colors
  static const Color lightTeal = Color(0xFF4ECDC4);
  static const Color darkBeige = Color(0xFFE6D5B8);
  static const Color softWhite = Color(0xFFFFFEFC);
  static const Color charcoal = Color(0xFF2C3E50);
}

class AppTheme {
  /// Light theme configuration
  static ThemeData get lightTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: GloopColors.gloopTeal,
      brightness: Brightness.light,
      primary: GloopColors.gloopTeal,
      onPrimary: GloopColors.softWhite,
      secondary: GloopColors.mustardYellow,
      onSecondary: GloopColors.darkTeal,
      surface: GloopColors.warmBeige,
      onSurface: GloopColors.darkTeal,
      background: GloopColors.warmBeige,
      onBackground: GloopColors.darkTeal,
      error: const Color(0xFFE57373),
      onError: GloopColors.softWhite,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      
      // Core colors
      primaryColor: GloopColors.deepTeal,
      scaffoldBackgroundColor: GloopColors.warmBeige,
      
      // Typography
      fontFamily: 'Comic',
      textTheme: _buildTextTheme(GloopColors.darkTeal),
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: GloopColors.deepTeal,
        foregroundColor: GloopColors.softWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'Comic',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: GloopColors.softWhite,
        ),
        iconTheme: const IconThemeData(
          color: GloopColors.softWhite,
          size: 24,
        ),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: GloopColors.warmBeige,
        elevation: 4,
        shadowColor: GloopColors.deepTeal.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: GloopColors.deepTeal.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      
      // Elevated Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GloopColors.mustardYellow,
          foregroundColor: GloopColors.darkTeal,
          elevation: 6,
          shadowColor: GloopColors.deepTeal.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Comic',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Text Button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GloopColors.gloopTeal,
          textStyle: const TextStyle(
            fontFamily: 'Comic',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GloopColors.deepTeal,
          side: const BorderSide(color: GloopColors.deepTeal, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Comic',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GloopColors.softWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: GloopColors.deepTeal, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: GloopColors.deepTeal.withOpacity(0.3), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: GloopColors.gloopTeal, width: 2),
        ),
        labelStyle: const TextStyle(
          color: GloopColors.darkTeal,
          fontFamily: 'Comic',
        ),
        hintStyle: TextStyle(
          color: GloopColors.darkTeal.withOpacity(0.6),
          fontFamily: 'Comic',
        ),
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: GloopColors.darkTeal,
        size: 24,
      ),
      
      // Floating Action Button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: GloopColors.mustardYellow,
        foregroundColor: GloopColors.darkTeal,
        elevation: 8,
      ),
      
      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: GloopColors.deepTeal,
        contentTextStyle: const TextStyle(
          color: GloopColors.softWhite,
          fontFamily: 'Comic',
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Bottom Navigation Bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: GloopColors.warmBeige,
        selectedItemColor: GloopColors.gloopTeal,
        unselectedItemColor: GloopColors.darkTeal,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: GloopColors.deepTeal.withOpacity(0.2),
        thickness: 1,
        space: 16,
      ),
    );
  }
  
  /// Dark theme configuration
  static ThemeData get darkTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: GloopColors.gloopTeal,
      brightness: Brightness.dark,
      primary: GloopColors.gloopTeal,
      onPrimary: GloopColors.darkTeal,
      secondary: GloopColors.mustardYellow,
      onSecondary: GloopColors.darkTeal,
      surface: GloopColors.charcoal,
      onSurface: GloopColors.softWhite,
      background: GloopColors.darkTeal,
      onBackground: GloopColors.softWhite,
      error: const Color(0xFFEF5350),
      onError: GloopColors.softWhite,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      
      // Core colors
      primaryColor: GloopColors.gloopTeal,
      scaffoldBackgroundColor: GloopColors.darkTeal,
      
      // Typography
      fontFamily: 'Comic',
      textTheme: _buildTextTheme(GloopColors.softWhite),
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: GloopColors.charcoal,
        foregroundColor: GloopColors.softWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'Comic',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: GloopColors.softWhite,
        ),
        iconTheme: const IconThemeData(
          color: GloopColors.softWhite,
          size: 24,
        ),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: GloopColors.charcoal,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: GloopColors.gloopTeal.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      
      // Elevated Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GloopColors.mustardYellow,
          foregroundColor: GloopColors.darkTeal,
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Comic',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Text Button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GloopColors.gloopTeal,
          textStyle: const TextStyle(
            fontFamily: 'Comic',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GloopColors.charcoal,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: GloopColors.gloopTeal, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: GloopColors.gloopTeal.withOpacity(0.5), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: GloopColors.gloopTeal, width: 2),
        ),
        labelStyle: const TextStyle(
          color: GloopColors.softWhite,
          fontFamily: 'Comic',
        ),
        hintStyle: TextStyle(
          color: GloopColors.softWhite.withOpacity(0.6),
          fontFamily: 'Comic',
        ),
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: GloopColors.softWhite,
        size: 24,
      ),
      
      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: GloopColors.gloopTeal,
        contentTextStyle: const TextStyle(
          color: GloopColors.darkTeal,
          fontFamily: 'Comic',
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// Build text theme with specified color
  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Comic',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Comic',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Comic',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Comic',
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Comic',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Comic',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Comic',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Comic',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Comic',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Comic',
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Comic',
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Comic',
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Comic',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Comic',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Comic',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }

  // Legacy support - keep old method names for backward compatibility
  static ThemeData get appTheme => lightTheme;
  static const List<Color> gameColors = [
    GloopColors.gloopTeal,
    GloopColors.mustardYellow,
    GloopColors.lightTeal,
    GloopColors.deepTeal,
    GloopColors.darkBeige,
  ];

  static Color getRandomGameColor(int seed) {
    return gameColors[seed % gameColors.length];
  }
}

/*
USAGE EXAMPLE:

In your main.dart:

import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reality Anchor',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follows system setting
      home: MyHomePage(),
    );
  }
}

// Or to force light mode:
// themeMode: ThemeMode.light,

// Or to force dark mode:
// themeMode: ThemeMode.dark,

// Access colors in widgets:
Container(
  color: GloopColors.warmBeige,
  child: Text(
    'Hello Gloop!',
    style: TextStyle(color: GloopColors.darkTeal),
  ),
)

// Use theme colors:
Container(
  color: Theme.of(context).colorScheme.primary,
  child: Text(
    'Themed text',
    style: Theme.of(context).textTheme.headlineLarge,
  ),
)
*/