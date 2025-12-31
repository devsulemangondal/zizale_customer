import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextCustom extends StatelessWidget {
  final int? maxLine;
  final String title;
  final double? fontSize;
  final Color? color;
  final bool islineThrough;
  final bool isUnderLine;
  final String? fontFamily;
  final TextAlign? textAlign;
  final TextOverflow? textOverflow;
  const TextCustom(
      {super.key,
        this.isUnderLine = false,
        required this.title,
        this.islineThrough = false,
        this.maxLine,
        this.fontSize = 14,
        this.fontFamily = FontFamily.regular,
        this.color,
        this.textAlign = TextAlign.center,
        this.textOverflow});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Text(title,
        maxLines: maxLine,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
        style: TextStyle(
            overflow: textOverflow,
            fontSize: fontSize,
            color: color ?? (themeChange.isDarkTheme() ? AppThemeData.primaryWhite : AppThemeData.primaryBlack),
            decorationColor: color ?? (themeChange.isDarkTheme() ? AppThemeData.primaryWhite : AppThemeData.primaryBlack),
            decoration: islineThrough
                ? TextDecoration.lineThrough
                : isUnderLine
                ? TextDecoration.underline
                : null,
            fontFamily: fontFamily));
  }
}

class TitleTextCustom extends StatelessWidget {
  final int? maxLine;
  final String title;
  final double? fontSize;
  final Color? color;
  final bool islineThrough;
  final bool isUnderLine;
  final String? fontFamily;

  const TitleTextCustom(
      {super.key, this.isUnderLine = false, required this.title, this.islineThrough = false, this.maxLine, this.fontSize = 12, this.fontFamily = FontFamily.bold, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        maxLines: maxLine,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: fontSize,
            color: color ?? AppThemeData.grey700,
            decorationColor: color ?? AppThemeData.grey700,
            decoration: islineThrough
                ? TextDecoration.lineThrough
                : isUnderLine
                ? TextDecoration.underline
                : null,
            fontFamily: fontFamily));
  }
}
