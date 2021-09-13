import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/styles/colors.dart';

enum AppTheme { Light, Dark }

final appThemeData = {
  AppTheme.Light: ThemeData(
      shadowColor: primaryColor.withOpacity(0.25),
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: pageBackgroundColor,
      backgroundColor: backgroundColor,
      canvasColor: canvasColor,
      colorScheme: ThemeData().colorScheme.copyWith(
            secondary: secondaryColor,
          )),
  AppTheme.Dark: ThemeData(
    shadowColor: primaryColor.withOpacity(0.25),
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    backgroundColor: backgroundColor,
  ),
};
/*

    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
        color: accentColor,
      )),
      errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
        color: accentColor,
      )),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
        color: accentColor,
      )),
      border: UnderlineInputBorder(
          borderSide: BorderSide(
        color: accentColor,
      )),
    ),
 */