import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/widget/text_widget.dart';
import '../themes/app_theme_data.dart';

class NoOrderView extends StatelessWidget {
  final double? height;

  const NoOrderView({
    super.key,
    required this.themeChange,
    this.height,
  });

  final DarkThemeProvider themeChange;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? Responsive.height(75, context),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                "assets/animation/no_order.gif",
                height: 100.0,
                width: 100.0,
              ),
            ),
            spaceH(height: 16),
            TextCustom(
              title: "No Order Found".tr,
              fontSize: 18,
              fontFamily: FontFamily.bold,
              color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800,
            ),
            spaceH(height: 4),
            TextCustom(
              title: "currently waiting for new orders.".tr,
              fontSize: 14,
              fontFamily: FontFamily.regular,
              color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
            ),
          ],
        ),
      ),
    );
  }
}
