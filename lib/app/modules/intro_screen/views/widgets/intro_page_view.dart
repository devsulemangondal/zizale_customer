// ignore_for_file: depend_on_referenced_packages

import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/app/modules/intro_screen/controllers/intro_screen_controller.dart';
import 'package:customer/app/modules/signup_screen/views/enter_location_view.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../../../themes/responsive.dart';
import '../../../../../themes/screen_size.dart';

class IntroScreenPage extends StatelessWidget {
  final String title;
  final String body;
  final Color textColor;
  final String image;
  final String imageDarkMode;

  const IntroScreenPage({
    super.key,
    required this.title,
    required this.body,
    required this.textColor,
    required this.image,
    required this.imageDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: IntroScreenController(),
        builder: (controller) {
          int index = controller.currentPage.value;

          return Container(
            width: Responsive.width(100, context),
            height: Responsive.height(100, context),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
                gradient: index == 0
                    ? LinearGradient(
                        colors: themeChange.isDarkTheme() ? [const Color(0xff1A0B00), const Color(0xff09090B)] : [const Color(0xffFFF1E5), const Color(0xffFAFAFA)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)
                    : index == 1
                        ? LinearGradient(
                            colors: themeChange.isDarkTheme() ? [const Color(0xff04150E), const Color(0xff09090B)] : [const Color(0xffEAFBF3), const Color(0xffFAFAFA)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter)
                        : index == 2
                            ? LinearGradient(
                                colors: themeChange.isDarkTheme() ? [const Color(0xff00171A), const Color(0xff09090B)] : [const Color(0xffE5FCFF), const Color(0xffFAFAFA)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter)
                            : const LinearGradient(colors: [Color(0xffFDE7E7), Color(0xffFAFAFA)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                index != 0
                    ? Padding(
                        padding: paddingEdgeInsets(horizontal: 0, vertical: 20),
                        child: GestureDetector(
                          onTap: () {
                            index = index - 1;
                            controller.pageController.jumpToPage(index);
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 12),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                            ),
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: 18,
                              color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: paddingEdgeInsets(horizontal: 0, vertical: 32),
                        child: SizedBox(),
                      ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 28, fontFamily: FontFamily.bold, color: textColor)),
                      const SizedBox(height: 7),
                      Text(
                        body,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: FontFamily.light,
                          fontSize: 16,
                          color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                        ),
                      ),
                      spaceH(height: 18),
                      Center(
                          child: CachedNetworkImage(
                        imageUrl: themeChange.isDarkTheme() ? imageDarkMode : image,
                        height: 456.h,
                        width: 276.w,
                        fit: BoxFit.fill,
                        placeholder: (context, url) => Constant.loader(),
                      )),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RoundShapeButton(
                              size: Size(166.w, ScreenSize.height(6, context)),
                              title: "Skip".tr,
                              buttonColor: themeChange.isDarkTheme() ? AppThemeData.grey700 : AppThemeData.grey300,
                              buttonTextColor: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                              onTap: () {
                                Preferences.setBoolean(Preferences.isFinishOnBoardingKey, true);
                                Get.offAll(EnterLocationView());
                              }),
                          RoundShapeButton(
                              size: Size(166.w, ScreenSize.height(6, context)),
                              title: "Next".tr,
                              buttonColor: AppThemeData.orange300,
                              buttonTextColor: AppThemeData.primaryWhite,
                              onTap: () {
                                if (index == controller.onboardingList.length - 1) {
                                  Preferences.setBoolean(Preferences.isFinishOnBoardingKey, true);
                                  Get.offAll(EnterLocationView());
                                } else {
                                  index = index + 1;
                                  controller.pageController.jumpToPage(index);
                                }
                              }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
