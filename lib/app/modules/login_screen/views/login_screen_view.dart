// ignore_for_file: deprecated_member_use, must_be_immutable, depend_on_referenced_packages, use_super_parameters

import 'package:customer/app/modules/login_screen/controllers/login_screen_controller.dart';
import 'package:customer/app/modules/login_screen/views/enter_mobile_number_view.dart';
import 'package:customer/app/modules/login_screen/views/forgot_password_view.dart';
import 'package:customer/app/modules/signup_screen/views/enter_location_view.dart';
import 'package:customer/app/modules/signup_screen/views/signup_screen_view.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/text_field_widget.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/common_ui.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../themes/screen_size.dart';

class LoginScreenView extends GetView<LoginScreenController> {
  LoginScreenView({Key? key}) : super(key: key);

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
      init: LoginScreenController(),
      builder: (controller) {
        controller.emailController.value.addListener(() => controller.checkFieldsFilled());
        controller.passwordController.value.addListener(() => controller.checkFieldsFilled());
        return Scaffold(
          backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
          appBar: UiInterface.customAppBar(
            context,
            themeChange,
            "",
            backgroundColor: Colors.transparent,
            actions: [
              TextButton(
                onPressed: () {
                  Get.to(EnterLocationView());
                },
                child: Text(
                  "Skip".tr,
                  style: TextStyle(
                    color: AppThemeData.primaryWhite,
                    fontFamily: FontFamily.medium,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: const ButtonStyle(padding: MaterialStatePropertyAll(EdgeInsets.zero)),
                            onPressed: () {
                              Get.to(ForgotPassword());
                            },
                            child: TextCustom(
                              title: "forgot password?".tr,
                              color: AppThemeData.accent300,
                              fontFamily: FontFamily.medium,
                              isUnderLine: true,
                              textAlign: TextAlign.right,
                            ),
                          ).flexible(),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RoundShapeButton(
                              title: "Log in".tr,
                              buttonColor: AppThemeData.orange300,
                              buttonTextColor: AppThemeData.primaryWhite,
                              onTap: () {
                                if (formKey.currentState!.validate()) {
                                  controller.emailSignIn();
                                } else {
                                  ShowToastDialog.showToast("Please enter valid information.".tr);
                                }
                              },
                              size: Size(358.w, ScreenSize.height(5, context)),
                            ),
                          ),
                        ],
                      ),
                      spaceH(height: 20),
                      Row(
                        children: [
                          const Expanded(child: SizedBox()),
                          Expanded(child: Divider(color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400)),
                          spaceW(),
                          Text(
                            "Or".tr,
                            style: TextStyle(fontFamily: FontFamily.regular, color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400),
                            textAlign: TextAlign.right,
                          ),
                          spaceW(),
                          Expanded(child: Divider(color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400)),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                      spaceH(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: RoundShapeButton(
                              titleWidget: Text(
                                "Continue with mobile number".tr,
                                style: TextStyle(fontFamily: FontFamily.medium, color: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50, fontSize: 18),
                              ),
                              buttonColor: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                              buttonTextColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                              onTap: () {
                                Get.to(() => EnterMobileNumberScreenView());
                              },
                              size: Size(358.w, ScreenSize.height(6, context)),
                              title: '',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                      text: 'new_in'.trParams({'appName': Constant.appName.value}),
                      style: TextStyle(fontSize: 14, color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900, fontFamily: FontFamily.regular),
                      children: [
                        TextSpan(
                          text: "Create account".tr,
                          style: TextStyle(fontSize: 14, color: AppThemeData.orange300, fontFamily: FontFamily.medium, decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()..onTap = () => Get.to(SignupScreenView(), arguments: {"type": Constant.emailLoginType}),
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
          Text('welcome_back'.trParams({'appName': Constant.appName.value}),
              style: TextStyle(
                fontFamily: FontFamily.bold,
                fontSize: 28,
                color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
              )),
          Text("Login to manage your account.".tr,
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

  Column buildEmailPasswordWidget(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Column(
      children: [
        TextFieldWidget(
          title: "Email".tr,
          hintText: "Enter Email".tr,
          validator: (value) => Constant.validateEmail(value),
          controller: controller.emailController.value,
          onPress: () {},
        ),
        Obx(() => TextFieldWidget(
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
            ))
      ],
    );
  }
}
