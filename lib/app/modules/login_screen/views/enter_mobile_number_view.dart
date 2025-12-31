// ignore_for_file: deprecated_member_use, must_be_immutable, depend_on_referenced_packages

import 'package:customer/app/modules/login_screen/controllers/login_screen_controller.dart';
import 'package:customer/app/modules/login_screen/views/login_screen_view.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/text_field_widget.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/common_ui.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../constant/show_toast_dialog.dart';
import '../../../../themes/screen_size.dart';

class EnterMobileNumberScreenView extends GetView<LoginScreenController> {
  EnterMobileNumberScreenView({super.key});

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
      init: LoginScreenController(),
      builder: (controller) {
        controller.mobileNumberController.value.addListener(() => controller.checkFieldsFilled());

        return Scaffold(
          backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
          appBar: UiInterface.customAppBar(context, themeChange, "", backgroundColor: Colors.transparent),
          body: Form(
            key: formKey,
            child: SingleChildScrollView(
                child: Padding(
              padding: paddingEdgeInsets(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTopWidget(context),
                  buildMobileNumberWidget(context),
                  spaceH(height: 130.h),
                  Row(
                    children: [
                      Expanded(
                        child: RoundShapeButton(
                          title: "Get OTP".tr,
                          buttonColor: AppThemeData.orange300,
                          buttonTextColor: AppThemeData.primaryWhite,
                          onTap: () {
                            if (controller.mobileNumberController.value.text.isNotEmpty) {
                              controller.sendCode();
                            } else {
                              ShowToastDialog.showToast("Please enter a valid number".tr);
                            }
                          },
                          size: Size(358.w, ScreenSize.height(6, context)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                      text: "Already have an account? ".tr,
                      style: TextStyle(fontSize: 16, color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800, fontFamily: FontFamily.regular),
                      children: [
                        TextSpan(
                          text: "Log in".tr,
                          style: TextStyle(fontSize: 16, color: AppThemeData.orange300, fontFamily: FontFamily.medium, decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()..onTap = () => Get.to(LoginScreenView()),
                        )
                      ]),
                ),
              ],
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
          Text("Enter Your Mobile Number".tr,
              style: TextStyle(
                fontFamily: FontFamily.bold,
                fontSize: 28,
                color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
              )),
          Text("Provide your mobile number for order updates.".tr,
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

  MobileNumberTextField buildMobileNumberWidget(BuildContext context) {
    return MobileNumberTextField(controller: controller.mobileNumberController.value, countryCode: controller.countryCode.value!, onPress: () {}, title: "Mobile Number".tr);
  }
}
