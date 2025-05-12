import 'package:flutter/material.dart';
import 'package:studymate/theme//bridge_theme.dart';
import 'package:studymate/theme/dark_app_theme.dart';
import 'package:studymate/theme/light_app_theme.dart';


class ThemeManager with ChangeNotifier {
 ThemeBridge _themeBridge;

ThemeManager(this._themeBridge);

ThemeData get theme => _themeBridge.themeData;

void toggleTheme() {
    if (_themeBridge.themeData.brightness == Brightness.dark) {
      _themeBridge.changeTheme(LightAppTheme());
    } else {
      _themeBridge.changeTheme(DarkAppTheme());
    }
    _themeBridge = _themeBridge; // update current bridge reference
    notifyListeners();
  }

  
  /*ThemeMode themeMode = ThemeMode.light;


  get themeData => themeMode;



  toggleTheme(bool isDark) {
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }*/
}
