import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

Column buildTopWidget(
  BuildContext context,
  String title,
  String description,
) {
  final themeChange = Provider.of<DarkThemeProvider>(context);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextCustom(
        title: title.tr,
        fontSize: 28,
        maxLine: 2,
        textAlign: TextAlign.start,
        fontFamily: FontFamily.bold,
        color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
      ),
      spaceH(height: 4),
      TextCustom(
        title: description.tr,
        fontSize: 16,
        maxLine: 3,
        fontFamily: FontFamily.regular,
        textAlign: TextAlign.start,
        color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
      ),
    ],
  );
}
