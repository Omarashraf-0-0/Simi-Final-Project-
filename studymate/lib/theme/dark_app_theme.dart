import 'package:flutter/material.dart';
import 'theme.dart';
import 'app_colors.dart';
import 'Custom_themes/text_field_theme.dart';
import 'Custom_themes/checkbox_theme.dart';
import 'text_theme.dart';
import 'package:studymate/theme//bridge_theme.dart';


class DarkAppTheme implements ThemeBridge {

  late ThemeBridge _currentTheme;

  DarkAppTheme() {
    _currentTheme = this;
  }
  @override
  void changeTheme(ThemeBridge newTheme) {
    _currentTheme = newTheme;
  }
  @override
  ThemeData get themeData => ThemeData(
        useMaterial3: true,
        fontFamily: 'League Spartan',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.black,
        primaryColor: AppColors.blue1,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.blue1,
          onPrimary: AppColors.black,
          primaryContainer: AppColors.blue2,
          onPrimaryContainer: AppColors.black,
          secondary: AppColors.cyan1,
          onSecondary: AppColors.cyan1,
          secondaryContainer: AppColors.cyan2,
          onSecondaryContainer: AppColors.cyan2,
          surface: AppColors.black,
          onSurface: AppColors.white,
          error: Colors.red,
          onError: AppColors.black,
        ),
        textTheme: TTextTheme.darkTextTheme,
        inputDecorationTheme: TTextFormFieldTheme.darkInputDecoration,
        checkboxTheme: TcheckboxTheme.darkCheckboxTheme,
      );
}
