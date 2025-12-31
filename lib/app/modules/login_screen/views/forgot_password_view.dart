// ignore_for_file: deprecated_member_use, must_be_immutable, depend_on_referenced_packages

import 'package:customer/app/modules/login_screen/controllers/login_screen_controller.dart';
import 'package:customer/app/modules/login_screen/views/login_screen_view.dart';
import 'package:customer/app/modules/signup_screen/views/signup_screen_view.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/text_field_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../themes/common_ui.dart';

class ForgotPassword extends GetView<LoginScreenController> {
  ForgotPassword({super.key});

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: UiInterface.customAppBar(context, themeChange, "", backgroundColor: Colors.transparent),
      backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
            child: Padding(
          padding: paddingEdgeInsets(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTopWidget(context),
              buildEmailPasswordWidget(context),
              34.height,
              Row(
                children: [
                  Expanded(
                    child: RoundShapeButton(
                      title: "Send".tr,
                      buttonColor: AppThemeData.orange300,
                      buttonTextColor: AppThemeData.primaryWhite,
                      onTap: () async {
                        if (controller.resetEmailController.value.text.isNotEmpty) {
                          await controller.resetPassword(controller.resetEmailController.value.text).then((value) {
                            ShowToastDialog.closeLoader();
                            ShowToastDialog.showToast("Password reset link sent successfully.".tr);
                            Get.offAll(LoginScreenView());
                          }).catchError((e) {
                            ShowToastDialog.showToast("Error".tr);
                            ShowToastDialog.closeLoader();
                          });
                        } else {
                          ShowToastDialog.showToast("Please enter a valid email".tr);
                        }
                      },
                      size: const Size(350, 55),
                    ),
                  ),
                ],
              ),
              spaceH(height: 20),
              GestureDetector(
                onTap: () => Get.offAll(LoginScreenView()),
                child: Text(
                  "Back to Sign In".tr,
                  style: TextStyle(fontFamily: FontFamily.regular, color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey1000, decoration: TextDecoration.underline),
                  textAlign: TextAlign.right,
                ).center(),
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
                  text: "Didn’t have an account? ".tr,
                  style: TextStyle(fontSize: 14, color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800, fontFamily: FontFamily.light),
                  children: [
                    TextSpan(
                      text: "Sign Up".tr,
                      style: TextStyle(fontSize: 14, color: themeChange.isDarkTheme() ? AppThemeData.primary200 : AppThemeData.primary500, fontFamily: FontFamily.medium),
                      recognizer: TapGestureRecognizer()..onTap = () => Get.to(SignupScreenView()),
                    )
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox buildTopWidget(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Forgot Your Password?".tr,
              style: TextStyle(
                fontFamily: FontFamily.bold,
                fontSize: 24,
                color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey900,
              )),
          Text("Enter the email to recover the password".tr,
              style: TextStyle(
                fontSize: 14,
                fontFamily: FontFamily.regular,
                color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey900,
              ),
              textAlign: TextAlign.start),
          24.height
        ],
      ),
    );
  }

  TextFieldWidget buildEmailPasswordWidget(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return TextFieldWidget(
      title: "Email".tr,
      hintText: "Enter Email".tr,
      validator: (value) => Constant.validateEmail(value),
      controller: controller.resetEmailController.value,
      prefix: SvgPicture.asset(
        "assets/icons/ic_mail.svg",
        color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400,
      ),
      onPress: () {},
    );
  }
}
