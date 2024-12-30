import 'package:flutter/material.dart';
import 'package:studymate/Theme/Custom_themes/text_field_theme.dart';
import 'package:studymate/theme/Custom_Themes/Text_Theme.dart';
import 'package:studymate/theme/Custom_themes/checkbox_theme.dart';



class TAppTheme {
  TAppTheme._();
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'League Spartan',
    brightness: Brightness.light,
    primaryColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
       colorScheme: ColorScheme.light(
          primary: Color(0xFFF6F5FB),
          secondary: Colors.black,
        ),
    textTheme: TTextTheme.lightTextTheme,
    inputDecorationTheme: TTextFormFieldTheme.lightInputDecoration,
    checkboxTheme: TcheckboxTheme.lightCheckboxTheme,
  );
  static ThemeData darkTheme = ThemeData(
     useMaterial3: true,
    fontFamily: 'League Spartan',
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.dark(
         primary: Color(0xFFF6F5FB), 
         secondary: Colors.white,
        ),
    textTheme: TTextTheme.darkTextTheme,
    inputDecorationTheme: TTextFormFieldTheme.darkInputDecoration,
    checkboxTheme: TcheckboxTheme.darkCheckboxTheme,
  );
  
}

