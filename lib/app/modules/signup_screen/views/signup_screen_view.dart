// ignore_for_file: must_be_immutable, depend_on_referenced_packages, deprecated_member_use

import 'package:customer/app/modules/login_screen/views/login_screen_view.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/text_field_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/common_ui.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constant/show_toast_dialog.dart';
import '../../../../themes/screen_size.dart';
import '../controllers/signup_screen_controller.dart';

class SignupScreenView extends GetView<SignupScreenController> {
  SignupScreenView({super.key});

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
      init: SignupScreenController(),
      builder: (controller) {
        controller.firstNameController.value.addListener(() => controller.checkFieldsFilled());
        controller.lastNameController.value.addListener(() => controller.checkFieldsFilled());
        controller.mobileNumberController.value.addListener(() => controller.checkFieldsFilled());
        controller.emailController.value.addListener(() => controller.checkFieldsFilled());
        controller.passwordController.value.addListener(() => controller.checkFieldsFilled());
        controller.confirmPasswordController.value.addListener(() => controller.checkFieldsFilled());

        return Scaffold(
          appBar: UiInterface.customAppBar(context, themeChange, "", backgroundColor: Colors.transparent),
          backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
          body: Form(
            key: formKey,
            child: SingleChildScrollView(
                child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTopWidget(context),
                      buildEmailPasswordWidget(context),
                      24.height,
                      Obx(
                        () => Row(
                          children: [
                            Expanded(
                              child: RoundShapeButton(
                                title: "Save and Continue".tr,
                                buttonColor: controller.isFirstButtonEnabled.value
                                    ? AppThemeData.orange300
                                    : themeChange.isDarkTheme()
                                        ? AppThemeData.grey800
                                        : AppThemeData.grey200,
                                buttonTextColor: controller.isFirstButtonEnabled.value
                                    ? themeChange.isDarkTheme()
                                        ? AppThemeData.grey1000
                                        : AppThemeData.grey50
                                    : AppThemeData.grey500,
                                onTap: () async {
                                  if (formKey.currentState!.validate()) {
                                    if (controller.loginType.value == Constant.emailLoginType) {
                                      if (controller.passwordController.value.text == controller.confirmPasswordController.value.text) {
                                        await controller.signUp();
                                      } else {
                                        ShowToastDialog.showToast("Please enter valid password".tr);
                                      }
                                    } else {
                                      controller.saveData();
                                    }
                                  } else {
                                    ShowToastDialog.showToast("Please fill in all required fields.".tr);
                                  }
                                },
                                size: Size(358.w, ScreenSize.height(6, context)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("Enter Basic Details".tr,
              style: TextStyle(
                fontFamily: FontFamily.bold,
                fontSize: 24,
                color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey900,
              )),
          Text("Please enter your basic details to set up your profile.".tr,
              style: TextStyle(
                fontSize: 14,
                fontFamily: FontFamily.regular,
                color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey900,
              ),
              textAlign: TextAlign.start),
          spaceH(height: 24.h)
        ],
      ),
    );
  }

  Column buildEmailPasswordWidget(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Column(
      children: [
        TextFieldWidget(
          title: "First Name".tr,
          hintText: "Enter First Name".tr,
          validator: (value) => value != null && value.isNotEmpty ? null : "This field required".tr,
          controller: controller.firstNameController.value,
          onPress: () {},
        ),
        TextFieldWidget(
          title: "Last Name".tr,
          hintText: "Enter Last Name".tr,
          validator: (value) => value != null && value.isNotEmpty ? null : "This field required".tr,
          controller: controller.lastNameController.value,
          onPress: () {},
        ),
        MobileNumberTextField(
          controller: controller.mobileNumberController.value,
          countryCode: controller.countryCode.value!,
          onPress: () {},
          title: "Mobile Number".tr,
          readOnly: controller.userModel.value.loginType == Constant.phoneLoginType ? true : false,
        ),
        Obx(
          () => Column(
            children: [
              TextFieldWidget(
                title: "Email".tr,
                hintText: "Enter Email".tr,
                validator: (value) => Constant.validateEmail(value),
                controller: controller.emailController.value,
                onPress: () {},
                readOnly: (controller.userModel.value.loginType == Constant.googleLoginType || controller.userModel.value.loginType == Constant.appleLoginType) ? true : false,
              ),
            ],
          ),
        ),
        if (controller.loginType.value == Constant.emailLoginType)
          Obx(() => Column(
                children: [
                  TextFieldWidget(
                    title: "password".tr,
                    hintText: "Enter Password".tr,
                    validator: (value) => Constant.validatePassword(value),
                    controller: controller.passwordController.value,
                    obscureText: controller.isPasswordVisible.value,
                    suffix: SvgPicture.asset(
                      controller.isPasswordVisible.value ? "assets/icons/ic_hide_password.svg" : "assets/icons/ic_show_password.svg",
                      color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800,
                    ).onTap(() {
                      controller.isPasswordVisible.value = !controller.isPasswordVisible.value;
                    }),
                    onPress: () {},
                  ),
                  Obx(() => TextFieldWidget(
                        title: "Confirm Password".tr,
                        hintText: "Enter Confirm Password".tr,
                        validator: (value) => Constant.validatePassword(value),
                        controller: controller.confirmPasswordController.value,
                        obscureText: controller.isPasswordVisible.value,
                        suffix: SvgPicture.asset(
                          controller.isPasswordVisible.value ? "assets/icons/ic_hide_password.svg" : "assets/icons/ic_show_password.svg",
                          color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800,
                        ).onTap(() {
                          controller.isPasswordVisible.value = !controller.isPasswordVisible.value;
                        }),
                        onPress: () {},
                      ))
                ],
              )),
        TextFieldWidget(
          title: "Refer Code".tr,
          hintText: "Enter Refer Code".tr,
          controller: controller.referralCodeController.value,
          onPress: () {},
          validator: (value) {
            return null;
          },
        ),
      ],
    );
  }
}
