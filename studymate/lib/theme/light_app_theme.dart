// lib/theme/light_app_theme.dart
import 'package:flutter/material.dart';
import 'theme.dart';
import 'app_colors.dart';
import 'Custom_themes/text_field_theme.dart';
import 'Custom_themes/checkbox_theme.dart';
import 'text_theme.dart';
import 'package:studymate/theme//bridge_theme.dart';

class LightAppTheme implements ThemeBridge {

  late ThemeBridge _currentTheme;


 LightAppTheme() {
    _currentTheme = this;
  }

 

  @override
  ThemeData get themeData => ThemeData(
        useMaterial3: true,
        fontFamily: 'League Spartan',
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.white,
        primaryColor: AppColors.blue1,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.cyan1,
          onPrimary: AppColors.white,
          primaryContainer: AppColors.cyan2,
          onPrimaryContainer: AppColors.white,
          secondary: AppColors.blue1,
          onSecondary: AppColors.white,
          secondaryContainer: AppColors.blue2,
          onSecondaryContainer: AppColors.white,
          surface: AppColors.white,
          onSurface: AppColors.black,
          error: Colors.red,
          onError: AppColors.white,
        ),
        textTheme: TTextTheme.lightTextTheme,
        inputDecorationTheme: TTextFormFieldTheme.lightInputDecoration,
        checkboxTheme: TcheckboxTheme.lightCheckboxTheme,
      );

  
}
