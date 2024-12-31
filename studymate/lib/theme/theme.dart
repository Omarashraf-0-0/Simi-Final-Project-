import 'package:flutter/material.dart';
import 'package:studymate/Theme/Custom_themes/text_field_theme.dart';
import 'package:studymate/theme/Custom_themes/checkbox_theme.dart';
import 'package:studymate/theme/text_theme.dart';

class TAppTheme {
  TAppTheme._();

  // Define the branding colors
  static const Color cyan1 = Color(0xFF18bebc); // Cyan 1
  static const Color cyan2 = Color(0xFF139896); // Cyan 2
  static const Color blue1 = Color(0xFF1c74bb); // Blue 1
  static const Color blue2 = Color(0xFF165d96); // Blue 2
  static const Color black = Color(0xFF000000); // Black
  static const Color white = Color(0xFFFFFFFF); // White

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'League Spartan',
    brightness: Brightness.light,
    scaffoldBackgroundColor: white,
    primaryColor: blue1,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: cyan1,
      onPrimary: white,
      primaryContainer: cyan2,
      onPrimaryContainer: white,
      secondary: blue1,
      onSecondary: white,
      secondaryContainer: blue2,
      onSecondaryContainer: white,
      background: white,
      onBackground: black,
      surface: white,
      onSurface: black,
      error: Colors.red,
      onError: white,
    ),
    textTheme: TTextTheme.lightTextTheme,
    inputDecorationTheme: TTextFormFieldTheme.lightInputDecoration,
    checkboxTheme: TcheckboxTheme.lightCheckboxTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'League Spartan',
    brightness: Brightness.dark,
    primaryColor: blue1,
    scaffoldBackgroundColor: black,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: blue1,
      onPrimary: black,
      primaryContainer: blue2,
      onPrimaryContainer: black,
      secondary: cyan1,
      onSecondary: cyan1,
      secondaryContainer: cyan2,
      onSecondaryContainer: cyan2,
      // background: black,
      // onBackground: white,
      surface: black,
      onSurface: white,
      error: Colors.red,
      onError: black,
    ),
    textTheme: TTextTheme.darkTextTheme,
    inputDecorationTheme: TTextFormFieldTheme.darkInputDecoration,
    checkboxTheme: TcheckboxTheme.darkCheckboxTheme,
  );
}