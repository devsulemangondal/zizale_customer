// ignore_for_file: deprecated_member_use

import 'package:customer/app/modules/dashboard_screen/controllers/dashboard_screen_controller.dart';
import 'package:customer/app/modules/dashboard_screen/views/dashboard_screen_view.dart';
import 'package:customer/app/modules/my_wallet/controllers/my_wallet_controller.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/screen_size.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class MoneyAddedSuccessfully extends StatelessWidget {
  const MoneyAddedSuccessfully({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<MyWalletController>(
        init: MyWalletController(),
        builder: (controller) {
          return WillPopScope(
            onWillPop: () async {
              Get.offAll(const DashboardScreenView());
              return false;
            },
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: themeChange.isDarkTheme() ? [const Color(0xffFF780E), const Color(0xffFFA056)] : [const Color(0xffFF790F), const Color(0xffB2530A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter)),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/animation/order_placed.gif",
                            height: 90.h,
                            width: 90.w,
                          ),
                          spaceH(height: 20),
                          TextCustom(
                            title: "Money Added Successfully!".tr,
                            fontSize: 28,
                            maxLine: 2,
                            fontFamily: FontFamily.bold,
                            color: themeChange.isDarkTheme() ? AppThemeData.surface1000 : AppThemeData.surface50,
                          ),
                          spaceH(height: 4),
                          TextCustom(
                            title: "Your wallet has been successfully topped up with the added funds.".tr,
                            fontSize: 14,
                            maxLine: 4,
                            fontFamily: FontFamily.light,
                            color: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey100,
                          ),
                          spaceH(height: 42),
                          RoundShapeButton(
                              title: "Continue".tr,
                              textSize: 18,
                              buttonColor: themeChange.isDarkTheme() ? AppThemeData.surface50 : AppThemeData.surface1000,
                              buttonTextColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                              onTap: () {
                                DashboardScreenController dashBoardController = Get.put(DashboardScreenController());
                                dashBoardController.selectedIndex.value = 2;
                                Get.offAll(const DashboardScreenView());
                              },
                              size: Size(358.w, ScreenSize.height(6, context)))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
