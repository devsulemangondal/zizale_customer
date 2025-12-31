// ignore_for_file: depend_on_referenced_packages

import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AccountDisabledScreen extends StatelessWidget {
  const AccountDisabledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 42),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset("assets/icons/ic_account_disabled.svg"),
            const SizedBox(
              height: 28,
            ),
            Text(
              "Your Account Has Been Disabled".tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontFamily: FontFamily.medium, color: themeChange.isDarkTheme() ? AppThemeData.primaryWhite : AppThemeData.primaryBlack),
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              "Access to your account has been disabled. please contact to the admin.".tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontFamily: FontFamily.regular, color: themeChange.isDarkTheme() ? AppThemeData.primaryWhite : AppThemeData.primaryBlack),
            )
          ],
        ),
      ),
    );
  }
}
