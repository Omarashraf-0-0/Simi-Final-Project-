import 'package:flutter/material.dart';

abstract class ThemeBridge {
  ThemeData get themeData;
  void changeTheme(ThemeBridge newTheme);
}