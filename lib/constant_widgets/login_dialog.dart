// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:customer/app/modules/landing_screen/views/landing_screen_view.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class LoginDialog extends StatelessWidget {
  const LoginDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Container(
      width: 466,
      decoration: BoxDecoration(color: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lottie.asset("assets/login_required.json",height: 100),
          // // Image.asset("assets/login_required.gif"),
          TextCustom(
            title: "Login Required".tr,
            fontSize: 18,
            fontFamily: FontFamily.bold,
            color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
          ),
          const SizedBox(height: 16),
          TextCustom(
            title: "Please log in to place orders, save your cart, and enjoy a personalized experience with order tracking and exclusive offers.".tr,
            fontSize: 14,
            maxLine: 5,
            fontFamily: FontFamily.medium,
            color: AppThemeData.grey500,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Get.back();
                    },
                    child: TextCustom(
                      title: "Cancel".tr,
                      fontFamily: FontFamily.medium,
                      color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800,
                    )),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: RoundShapeButton(
                      title: "Login".tr,
                      buttonColor: AppThemeData.orange300,
                      buttonTextColor: AppThemeData.primaryWhite,
                      onTap: () {
                        Get.to(LandingScreenView());
                      },
                      size: Size(0, 0))),
            ],
          )
        ],
      ),
    );
  }
}
