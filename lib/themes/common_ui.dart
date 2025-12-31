// ignore_for_file: deprecated_member_use

import 'package:customer/app/modules/my_cart/views/my_cart_view.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class UiInterface {
  UiInterface({Key? key});

  static AppBar customAppBar(
    BuildContext context,
    themeChange,
    String title, {
    bool isBack = true,
    Color? backgroundColor,
    Color? iconColor,
    Color? textColor,
    List<Widget>? actions,
    Function()? onBackTap,
    bool showCartButton = false,
    dynamic controller,
  }) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    List<Widget> finalActions = actions ?? [];
    if (showCartButton && controller != null) {
      finalActions.add(buildCartButton(context, themeChange, controller));
      finalActions.add(spaceW(width: 16));
    }
    return AppBar(
      leading: isBack
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey100,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6, right: 10, bottom: 6, top: 6),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 20,
                      color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                    ),
                  ),
                ),
              ),
            )
          : SizedBox(),
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: TextCustom(color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900, fontFamily: FontFamily.bold, fontSize: 18, title: title.tr),
      ),
      backgroundColor: themeChange.isDarkTheme() ? backgroundColor ?? AppThemeData.primaryBlack : backgroundColor ?? AppThemeData.primaryWhite,
      automaticallyImplyLeading: false,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 10,
      surfaceTintColor: Colors.transparent,
      actions: finalActions,
    );
  }

  static Widget buildCartButton(BuildContext context, DarkThemeProvider themeChange, dynamic controller) {
    return GestureDetector(
      onTap: () {
        Get.to(const MyCartView());
      },
      child: Container(
        height: 36.h,
        width: 36.w,
        decoration: BoxDecoration(
          color: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey100,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Obx(() => (controller.getCartItemCount() > 0)
              ? Badge(
                  offset: const Offset(6, -8),
                  largeSize: 18,
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                  backgroundColor: AppThemeData.orange300,
                  label: TextCustom(
                    title: controller.getCartItemCount().toString(),
                    fontSize: 12,
                    fontFamily: FontFamily.regular,
                    color: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                  ),
                  child: SvgPicture.asset(
                    "assets/icons/ic_cart.svg",
                    color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800,
                  ),
                )
              : SvgPicture.asset(
                  "assets/icons/ic_cart.svg",
                  color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800,
                )),
        ),
      ),
    );
  }
}
