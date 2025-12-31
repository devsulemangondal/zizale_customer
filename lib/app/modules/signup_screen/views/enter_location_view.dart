// ignore_for_file: must_be_immutable

import 'package:customer/app/modules/login_screen/controllers/login_screen_controller.dart';
import 'package:customer/app/modules/signup_screen/views/enter_location_manually.dart';
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

class EnterLocationView extends GetView<LoginScreenController> {
  EnterLocationView({super.key});

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
      init: LoginScreenController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
          body: Container(
            height: ScreenSize.height(100, context),
            width: ScreenSize.width(100, context),
            decoration: BoxDecoration(
                image:
                    DecorationImage(image: AssetImage(themeChange.isDarkTheme() ? "assets/images/map-container-dark.png" : "assets/images/map-container.png"), fit: BoxFit.fill)),
            child: Padding(
              padding: paddingEdgeInsets(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey100,
                        ),
                        height: 42.h,
                        width: 42.w,
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  buildTopWidget(context),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: RoundShapeButton(
                          title: "Continue".tr,
                          buttonColor: AppThemeData.orange300,
                          buttonTextColor: AppThemeData.primaryWhite,
                          onTap: () {
                            controller.getUserLocation();
                          },
                          size: Size(358.w, ScreenSize.height(6, context)),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(EnterLocationManuallyView());
                    },
                    child: Padding(
                      padding: paddingEdgeInsets(horizontal: 16, vertical: 16),
                      child: Align(
                          alignment: Alignment.center,
                          child: TextCustom(
                            fontFamily: FontFamily.medium,
                            title: "Enter Manually".tr,
                            isUnderLine: true,
                            fontSize: 16,
                            color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                          )),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  SizedBox buildTopWidget(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Enter Your Location".tr,
              style: TextStyle(
                fontFamily: FontFamily.bold,
                fontSize: 28,
                color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
              )),
          Text("Please provide your current location to find nearby drivers.".tr,
              style: TextStyle(
                fontSize: 16,
                fontFamily: FontFamily.regular,
                color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
              ),
              textAlign: TextAlign.start),
        ],
      ),
    );
  }
}
