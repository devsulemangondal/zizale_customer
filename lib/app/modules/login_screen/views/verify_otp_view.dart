import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/modules/account_disabled_screen.dart';
import 'package:customer/app/modules/dashboard_screen/views/dashboard_screen_view.dart';
import 'package:customer/app/modules/login_screen/controllers/login_screen_controller.dart';
import 'package:customer/app/modules/signup_screen/views/signup_screen_view.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/common_ui.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:customer/utils/preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../themes/screen_size.dart';

class VerifyOtpView extends GetView<LoginScreenController> {
  VerifyOtpView({super.key});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
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
                buildEmailPasswordWidget(context),
                34.height,
                Obx(
                  () => controller.enableResend.value
                      ? Center(
                          child: GestureDetector(
                            onTap: () {
                              controller.sendCode();
                            },
                            child: Text(
                              "Resend OTP".tr,
                              style: const TextStyle(
                                  fontSize: 16, color: AppThemeData.accent300, fontFamily: FontFamily.regular, decoration: TextDecoration.underline, decorationColor: AppThemeData.accent300),
                            ),
                          ),
                        )
                      : RichText(
                          text: TextSpan(
                            text: "Didn’t received it? Retry in ".tr,
                            style: TextStyle(
                              fontFamily: FontFamily.regular,
                              color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800,
                              fontSize: 16,
                            ),
                            children: [
                              TextSpan(
                                text: "00:${controller.secondsRemaining.value.toString().padLeft(2, '0')} sec".tr,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppThemeData.accent300,
                                  fontFamily: FontFamily.regular,
                                ),
                              ),
                            ],
                          ),
                        ).center(),
                ),
                spaceH(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => RoundShapeButton(
                          title: "Verify OTP".tr,
                          buttonColor: controller.isVerifyOTPButtonEnabled.value
                              ? AppThemeData.orange300
                              : themeChange.isDarkTheme()
                                  ? AppThemeData.grey800
                                  : AppThemeData.grey200,
                          buttonTextColor: controller.isVerifyOTPButtonEnabled.value ? AppThemeData.grey50 : AppThemeData.grey500,
                          onTap: () async {
                            if (controller.otpCode.value.length == 6) {
                              ShowToastDialog.showLoader("Verify".tr);
                              PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: controller.verificationId.value, smsCode: controller.otpCode.value);
                              String fcmToken = await NotificationService.getToken();
                              await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
                                if (value.additionalUserInfo!.isNewUser) {
                                  UserModel userModel = UserModel();
                                  userModel.id = value.user!.uid;
                                  userModel.countryCode = controller.countryCode.value;
                                  userModel.phoneNumber = controller.mobileNumberController.value.text;
                                  userModel.loginType = Constant.phoneLoginType;
                                  userModel.fcmToken = fcmToken;
                                  ShowToastDialog.closeLoader();
                                  // controller.signUp();
                                  Get.off(SignupScreenView(), arguments: {
                                    "userModel": userModel,
                                  });
                                } else {
                                  await FireStoreUtils.userExistOrNot(value.user!.uid).then((userExit) async {
                                    ShowToastDialog.closeLoader();
                                    if (userExit == true) {
                                      UserModel? userModel = await FireStoreUtils.getUserProfile(value.user!.uid);
                                      if (userModel != null) {
                                        userModel.fcmToken = fcmToken;
                                        await FireStoreUtils.updateUser(userModel);
                                        if (userModel.isActive == true) {
                                          Preferences.setBoolean(Preferences.isFinishOnBoardingKey, true);
                                          Get.offAll(const DashboardScreenView());
                                        } else {
                                          Get.offAll(const AccountDisabledScreen());
                                          // await FirebaseAuth.instance.signOut();
                                          // ShowToastDialog.showToast("Contact Administrator".tr);
                                        }
                                      }
                                    } else {
                                      UserModel userModel = UserModel();
                                      userModel.id = value.user!.uid;
                                      userModel.countryCode = controller.countryCode.value;
                                      userModel.phoneNumber = controller.mobileNumberController.value.text;
                                      userModel.loginType = Constant.phoneLoginType;
                                      userModel.fcmToken = fcmToken;
                                      // controller.signUp();
                                      Get.off(SignupScreenView(), arguments: {
                                        "userModel": userModel,
                                      });
                                    }
                                  });
                                }
                              }).catchError((error) {
                                ShowToastDialog.closeLoader();
                                ShowToastDialog.showToast("Invalid verification code.".tr);
                              });
                            } else {
                              ShowToastDialog.showToast("Please enter a valid OTP.".tr);
                            }
                          },
                          size: Size(358.w, ScreenSize.height(6, context)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
          Text("Verify Your Mobile Number".tr,
              style: TextStyle(
                fontFamily: FontFamily.bold,
                fontSize: 24,
                color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey900,
              )),
          RichText(
            text: TextSpan(
              text:
                  "${"Please enter the Verification code, we sent to".tr} \n${Constant.maskMobileNumber(countryCode: controller.countryCode.value, mobileNumber: controller.mobileNumberController.value.text)} ",
              style: TextStyle(
                fontFamily: FontFamily.regular,
                color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                fontSize: 16,
              ),
              children: [
                TextSpan(
                  text: "Change Number".tr,
                  style: TextStyle(fontSize: 16, color: AppThemeData.orange300, fontFamily: FontFamily.regular, decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()..onTap = () => Get.back(),
                ),
              ],
            ),
          ),
          24.height
        ],
      ),
    );
  }

  OtpTextField buildEmailPasswordWidget(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return OtpTextField(
      numberOfFields: 6,
      filled: true,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      cursorColor: AppThemeData.orange300,
      borderRadius: BorderRadius.circular(10),
      borderColor: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400,
      enabledBorderColor: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400,
      disabledBorderColor: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400,
      fillColor: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey50,
      focusedBorderColor: AppThemeData.orange300,
      showFieldAsBox: true,
      onSubmit: (value) {
        controller.otpCode.value = value;
        controller.isVerifyOTPButtonEnabled.value = true;
      },
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
    );
  }
}
