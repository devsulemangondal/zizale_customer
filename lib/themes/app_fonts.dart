import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FontFamily {
  static const String black = "Satoshi-Black";
  static const String blackItalic = "Satoshi-BlackItalic";
  static const String bold = "Satoshi-Bold";
  static const String boldItalic = "Satoshi-BoldItalic";
  static const String italic = "Satoshi-Italic";
  static const String light = "Satoshi-Light";
  static const String lightItalic = "Satoshi-LightItalic";
  static const String medium = "Satoshi-Medium";
  static const String mediumItalic = "Satoshi-MediumItalic";
  static const String regular = "Satoshi-Regular";

  static Text regularText(BuildContext context, {String? title}) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Text(title!, style: TextStyle(color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey1000, fontSize: 14, fontFamily: regular));
  }
}
