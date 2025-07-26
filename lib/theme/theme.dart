import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: const Color(0xFFE5E2E7),
    primary: Colors.black,
    secondary: Colors.red.shade600,
    onSecondary: Colors.white,
    tertiary: Colors.grey.shade600,
    onSurface: Colors.black,
    onPrimary: Colors.white,
    outline: Colors.grey.shade400,
    shadow: Colors.black,
  ),
  textTheme: TextTheme(
    // Display styles - largest text
    displayLarge: GoogleFonts.oswald(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
    ),
    displayMedium: GoogleFonts.oswald(
      fontSize: 45,
      fontWeight: FontWeight.w400,
    ),
    displaySmall: GoogleFonts.oswald(
      fontSize: 36,
      fontWeight: FontWeight.w400,
    ),
    
    // Headline styles - prominent text
    headlineLarge: GoogleFonts.oswald(
      fontSize: 32,
      fontWeight: FontWeight.w400,
    ),
    headlineMedium: GoogleFonts.oswald(
      fontSize: 28,
      fontWeight: FontWeight.w400,
    ),
    headlineSmall: GoogleFonts.oswald(
      fontSize: 24,
      fontWeight: FontWeight.w400,
    ),
    
    // Title styles - medium prominence
    titleLarge: GoogleFonts.oswald(
      fontSize: 22,
      fontWeight: FontWeight.w400,
    ),
    titleMedium: GoogleFonts.oswald(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    titleSmall: GoogleFonts.oswald(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    
    // Body styles - readable text
    bodyLarge: GoogleFonts.merriweather(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
    bodyMedium: GoogleFonts.merriweather(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: GoogleFonts.merriweather(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
    
    // Label styles - UI elements
    labelLarge: GoogleFonts.merriweather(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: GoogleFonts.merriweather(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.merriweather(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Colors.white,
    secondary: Colors.red.shade600,
    onSecondary: Colors.white,
    tertiary: Colors.grey.shade100,
    onSurface: Colors.white,
    onPrimary: Colors.black,
    outline: Colors.grey.shade600,
    shadow: Colors.black,
  ),
  textTheme: TextTheme(
    // Display styles - largest text
    displayLarge: GoogleFonts.oswald(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      color: Colors.white,
    ),
    displayMedium: GoogleFonts.oswald(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    displaySmall: GoogleFonts.oswald(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    
    // Headline styles - prominent text
    headlineLarge: GoogleFonts.oswald(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    headlineMedium: GoogleFonts.oswald(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    headlineSmall: GoogleFonts.oswald(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    
    // Title styles - medium prominence
    titleLarge: GoogleFonts.oswald(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    titleMedium: GoogleFonts.oswald(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: Colors.white,
    ),
    titleSmall: GoogleFonts.oswald(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: Colors.white,
    ),
    
    // Body styles - readable text
    bodyLarge: GoogleFonts.merriweather(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: Colors.white,
    ),
    bodyMedium: GoogleFonts.merriweather(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: Colors.white,
    ),
    bodySmall: GoogleFonts.merriweather(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: Colors.white,
    ),
    
    // Label styles - UI elements
    labelLarge: GoogleFonts.merriweather(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: Colors.white,
    ),
    labelMedium: GoogleFonts.merriweather(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: Colors.white,
    ),
    labelSmall: GoogleFonts.merriweather(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: Colors.white,
    ),
  ),
);
