import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Color(0xFFE5E2E7),
    primary: Colors.black,
    secondary: Colors.red.shade600,
    tertiary: Colors.grey.shade600,
  ),
  textTheme: TextTheme(
    displayLarge: const TextStyle(
      fontSize: 72,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),

    titleLarge: GoogleFonts.oswald(fontSize: 30, color: Colors.black),
    bodyMedium: GoogleFonts.merriweather(color: Colors.grey.shade600),
    bodySmall: GoogleFonts.merriweather(color: Colors.grey.shade600),
    displaySmall: GoogleFonts.pacifico(color: Colors.grey.shade600),
  ),
);

// ThemeData darkMode = ThemeData(
//   brightness: Brightness.dark,
//   colorScheme: ColorScheme.light(
//     surface: Colors.grey.shade900,
//     primary: Colors.white,
//     secondary: Colors.red.shade600,
//     tertiary: Colors.grey.shade400,
//   ),
//   textTheme: TextTheme(
//     displayLarge: const TextStyle(
//       fontSize: 72,
//       fontWeight: FontWeight.bold,
//       color: Colors.black,
//     ),
//     titleLarge: GoogleFonts.oswald(
//       fontSize: 30,
//       // fontStyle: FontStyle.italic,
//       color: Colors.black,
//     ),
//     bodyMedium: GoogleFonts.merriweather(color: Colors.grey.shade600),
//     bodySmall: GoogleFonts.merriweather(color: Colors.grey.shade600),
//     displaySmall: GoogleFonts.pacifico(color: Colors.grey.shade600),
//   ),
// );

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Colors.white,
    secondary: Colors.black,
    tertiary: Colors.grey.shade200,
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.oswald(color: Colors.white),
    displaySmall: GoogleFonts.oswald(color: Colors.white),
    titleLarge: GoogleFonts.oswald(color: Colors.white),
    titleMedium: GoogleFonts.oswald(color: Colors.white),
    titleSmall: GoogleFonts.oswald(color: Colors.white),
    bodyLarge: GoogleFonts.merriweather(color: Colors.white),
    bodyMedium: GoogleFonts.merriweather(color: Colors.white),
    bodySmall: GoogleFonts.merriweather(color: Colors.white),
  ),
);
