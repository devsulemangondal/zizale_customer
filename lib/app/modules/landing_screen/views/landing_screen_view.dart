// ignore_for_file: deprecated_member_use, depend_on_referenced_packages
import 'dart:io';

import 'package:customer/app/modules/login_screen/controllers/login_screen_controller.dart';
import 'package:customer/app/modules/login_screen/views/login_screen_view.dart';
import 'package:customer/app/modules/signup_screen/views/enter_location_view.dart';
import 'package:customer/app/modules/signup_screen/views/signup_screen_view.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/screen_size.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class LandingScreenView extends StatelessWidget {
  const LandingScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
        init: LoginScreenController(),
        builder: (controller) {
          return Container(
            height: ScreenSize.height(100, context),
            width: ScreenSize.width(100, context),
            decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/landing_page.png"), fit: BoxFit.fill)),
            child: Stack(children: [
              Padding(
                padding: paddingEdgeInsets(),
                child: Column(
                  children: [
                    spaceH(height: 412.h),
                    TextCustom(
                      title: 'join_app'.trParams({'appName': Constant.appName.value}),
                      color: AppThemeData.grey50,
                      fontSize: 28,
                      fontFamily: FontFamily.bold,
                    ),
                    TextCustom(
                      title: "Create an account to explore food".tr,
                      maxLine: 2,
                      color: AppThemeData.grey50,
                      fontSize: 16,
                      fontFamily: FontFamily.light,
                    ),
                    spaceH(height: 32),
                    RoundShapeButton(
                        size: Size(358.w, ScreenSize.height(6, context)),
                        title: "Sign Up".tr,
                        buttonColor: AppThemeData.orange300,
                        buttonTextColor: AppThemeData.primaryWhite,
                        onTap: () {
                          Get.to(SignupScreenView(), arguments: {"type": Constant.emailLoginType});
                        }),
                    spaceH(height: 12),
                    RoundShapeButton(
                      titleWidget: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/icons/ic_google.svg",
                          ),
                          const Spacer(),
                          Text(
                            "Continue with Google".tr,
                            style: TextStyle(fontFamily: FontFamily.medium, color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey1000, fontSize: 16),
                          ),
                          const Spacer(),
                        ],
                      ),
                      buttonColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                      buttonTextColor: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey100,
                      onTap: () {
                        controller.loginWithGoogle();
                      },
                      size: Size(358.w, ScreenSize.height(6, context)),
                      title: '',
                    ),
                    spaceH(height: 12),
                    if (Platform.isIOS) ...{
                      RoundShapeButton(
                        titleWidget: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/ic_apple.svg",
                              color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey1000,
                            ),
                            const Spacer(),
                            Text(
                              "Continue with Apple".tr,
                              style: TextStyle(fontFamily: FontFamily.medium, color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey1000, fontSize: 16),
                            ),
                            const Spacer(),
                          ],
                        ),
                        buttonColor: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey50,
                        buttonTextColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey100,
                        onTap: () {
                          controller.loginWithApple();
                        },
                        size: Size(358.w, ScreenSize.height(6, context)),
                        title: '',
                      ),
                    },
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(text: "Already have an account? ".tr, style: const TextStyle(fontSize: 14, color: AppThemeData.grey50, fontFamily: FontFamily.regular), children: [
                              TextSpan(
                                text: "Log in".tr,
                                style: TextStyle(fontSize: 14, color: AppThemeData.orange300, fontFamily: FontFamily.medium, decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()..onTap = () => Get.to(LoginScreenView()),
                              )
                            ]),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                top: 40.h,
                right: 20.w,
                child: GestureDetector(
                  onTap: () {
                    Get.to(EnterLocationView());
                  },
                  child: Text(
                    "Skip".tr,
                    style: TextStyle(
                      color: AppThemeData.primaryWhite,
                      fontSize: 16,
                      fontFamily: FontFamily.medium,
                    ),
                  ),
                ),
              ),
            ]),
          );
        });
  }
}
