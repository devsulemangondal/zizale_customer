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

class CompleteAddMoneyView extends StatelessWidget {
  const CompleteAddMoneyView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        Get.offAll(const DashboardScreenView());
        return false;
      },
      child: GetBuilder(
          init: MyWalletController(),
          builder: (controller) {
            return Container(
              height: ScreenSize.height(100, context),
              width: ScreenSize.width(100, context),
              decoration: BoxDecoration(
                  gradient: themeChange.isDarkTheme()
                      ? const LinearGradient(colors: [
                          Color(0xffFF790F),
                          Color(0xffB2530A),
                        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)
                      : const LinearGradient(colors: [
                          Color(0xffFF780E),
                          Color(0xffFFA056),
                        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              child: Column(
                children: [
                  spaceH(height: 240.h),
                  SizedBox(
                    height: 140.h,
                    width: 140.w,
                    child: Image.asset(
                      "assets/animation/add_money_successfulliy.gif",
                    ),
                  ),
                  spaceH(height: 42.h),
                  Padding(
                    padding: paddingEdgeInsets(horizontal: 27, vertical: 0),
                    child: TextCustom(
                      title: "Money Added Successfully!".tr,
                      maxLine: 2,
                      color: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey100,
                      fontSize: 28,
                      fontFamily: FontFamily.bold,
                    ),
                  ),
                  Padding(
                    padding: paddingEdgeInsets(horizontal: 27, vertical: 0),
                    child: TextCustom(
                      title: "Your wallet has been successfully topped up with the added funds.".tr,
                      maxLine: 3,
                      color: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey100,
                      fontSize: 16,
                      fontFamily: FontFamily.regular,
                    ),
                  ),
                  spaceH(height: 52),
                  RoundShapeButton(
                      size: Size(358.w, ScreenSize.height(6, context)),
                      title: "Continue".tr,
                      buttonColor: themeChange.isDarkTheme() ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
                      buttonTextColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey100,
                      onTap: () {
                        DashboardScreenController dashBoardController = Get.put(DashboardScreenController());
                        dashBoardController.selectedIndex.value = 2;
                        Get.offAll(const DashboardScreenView());
                      }),
                ],
              ),
            );
          }),
    );
  }
}
