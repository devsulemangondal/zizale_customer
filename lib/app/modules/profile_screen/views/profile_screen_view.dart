// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, deprecated_member_use, depend_on_referenced_packages, use_build_context_synchronously

import 'package:customer/app/modules/edit_profile_screen/views/edit_profile_screen_view.dart';
import 'package:customer/app/modules/favourites_screen/views/favourites_screen_view.dart';
import 'package:customer/app/modules/landing_screen/views/landing_screen_view.dart';
import 'package:customer/app/modules/language_screen/views/language_screen_view.dart';
import 'package:customer/app/modules/my_address/views/my_address_view.dart';
import 'package:customer/app/modules/notification_screen/views/notification_screen_view.dart';
import 'package:customer/app/modules/privacy_policy_screen/views/privacy_policy_screen_view.dart';
import 'package:customer/app/modules/profile_screen/controllers/profile_screen_controller.dart';
import 'package:customer/app/modules/referral_screen/views/referral_screen_view.dart';
import 'package:customer/app/routes/app_pages.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/network_image_widget.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/constant_widgets/custom_dialog_box.dart';
import 'package:customer/constant_widgets/login_dialog.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/constant_widgets/top_widget.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../statement_screen/views/statement_view.dart';

class ProfileScreenView extends StatelessWidget {
  const ProfileScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<ProfileScreenController>(
        autoRemove: false,
        init: ProfileScreenController(),
        builder: (controller) {
          return Container(
            width: Responsive.width(100, context),
            height: Responsive.height(100, context),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    stops: const [0.1, 0.3],
                    colors: themeChange.isDarkTheme() ? [const Color(0xff1A0B00), const Color(0xff1C1C22)] : [const Color(0xffFFF1E5), const Color(0xffFFFFFF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                forceMaterialTransparency: true,
                title: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/images/logo.svg",
                      color: AppThemeData.orange300,
                      width: 32,
                      height: 32,
                    ),
                    spaceW(width: 4),
                    TextCustom(
                      title: Constant.appName.value.tr,
                      fontSize: 20,
                      color: AppThemeData.orange300,
                      fontFamily: FontFamily.bold,
                    ),
                  ],
                ),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: paddingEdgeInsets(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTopWidget(context, "My Profile".tr, "Manage your personal information and settings here.".tr),
                      spaceH(height: 32),
                      if (FireStoreUtils.getCurrentUid() != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NetworkImageWidget(
                              imageUrl: controller.userModel.value.profilePic.toString(),
                              height: 116.w,
                              width: 116.w,
                              borderRadius: 200,
                              fit: BoxFit.cover,
                              isProfile: true,
                            ),
                            spaceW(width: 28.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (controller.userModel.value.firstName != null || controller.userModel.value.firstName!.isNotEmpty)
                                  Obx(
                                    () => TextCustom(
                                      title: controller.userModel.value.fullNameString(),
                                      fontFamily: FontFamily.bold,
                                      fontSize: 18,
                                      color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                    ),
                                  ),
                                if (controller.userModel.value.phoneNumber != null ||
                                    controller.userModel.value.phoneNumber!.isNotEmpty ||
                                    controller.userModel.value.countryCode!.isNotEmpty ||
                                    controller.userModel.value.countryCode != null)
                                  Obx(
                                    () => TextCustom(
                                      title: controller.userModel.value.countryCode.toString() + controller.userModel.value.phoneNumber.toString(),
                                      fontSize: 14,
                                      fontFamily: FontFamily.light,
                                      color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                    ),
                                  ),
                                spaceH(height: 24.h),
                                RoundShapeButton(
                                  titleWidget: TextCustom(
                                    title: "Edit Profile".tr,
                                    fontSize: 14,
                                    color: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                  ),
                                  title: "",
                                  buttonColor: AppThemeData.orange300,
                                  buttonTextColor: AppThemeData.primaryWhite,
                                  onTap: () {
                                    Get.to(EditProfileScreenView());
                                  },
                                  size: Size(140.w, 42.h),
                                ),
                              ],
                            ),
                          ],
                        ),
                      labelWidget(name: "Services".tr),
                      InkWell(
                        onTap: () {
                          if (FireStoreUtils.getCurrentUid() == null) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: LoginDialog(),
                                );
                              },
                            );
                          } else {
                            Get.to(FavouritesScreenView());
                          }
                        },
                        child: rowWidget(name: "Favourites".tr, icon: "assets/icons/ic_fill_favourite.svg"),
                      ),
                      InkWell(
                        onTap: () {
                          if (FireStoreUtils.getCurrentUid() == null) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: LoginDialog(),
                                );
                              },
                            );
                          } else {
                            Get.to(MyAddressView());
                          }
                        },
                        child: rowWidget(name: "My Address".tr, icon: "assets/icons/ic_map.svg"),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (FireStoreUtils.getCurrentUid() == null) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: LoginDialog(),
                                );
                              },
                            );
                          } else {
                            Get.to(NotificationScreenView());
                          }
                        },
                        child: rowWidget(name: "Notifications".tr, icon: "assets/icons/ic_bell_2.svg"),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(StatementView());
                        },
                        child: rowWidget(name: "Order Statement".tr, icon: "assets/icons/ic_downlod.svg", iconColor: AppThemeData.accent300),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(ReferralScreenView());
                        },
                        child: rowWidget(name: "Refer & Earn".tr, icon: "assets/icons/ic_refer.svg", iconColor: AppThemeData.orange300),
                      ),
                      labelWidget(name: "About".tr),
                      GestureDetector(
                        onTap: () {
                          Get.to(PrivacyPolicyScreenView(title: "Privacy & Policy".tr, htmlData: Constant.privacyPolicy));
                        },
                        child: rowWidget(name: "Privacy & Policy", icon: "assets/icons/ic_privacy_policy.svg"),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(PrivacyPolicyScreenView(title: "AboutApp".tr, htmlData: Constant.aboutApp));
                        },
                        child: rowWidget(name: "AboutApp".tr, icon: "assets/icons/ic_about_app.svg"),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(PrivacyPolicyScreenView(title: "Terms & Condition".tr, htmlData: Constant.termsAndConditions));
                        },
                        child: rowWidget(name: "Terms & Condition".tr, icon: "assets/icons/ic_support.svg"),
                      ),
                      labelWidget(name: "App Settings".tr),
                      Padding(
                        padding: paddingEdgeInsets(horizontal: 0, vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(shape: BoxShape.circle, color: themeChange.isDarkTheme() ? AppThemeData.surface1000 : AppThemeData.surface50),
                              height: 46.h,
                              width: 46.w,
                              child: Center(
                                child: SizedBox(
                                  height: 18.h,
                                  width: 18.w,
                                  child: SvgPicture.asset(
                                    "assets/icons/ic_theme.svg",
                                    color: AppThemeData.orange300,
                                  ),
                                ),
                              ),
                            ),
                            spaceW(),
                            TextCustom(
                              title: "Dark Mode".tr,
                              fontSize: 16,
                              fontFamily: FontFamily.bold,
                              color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                            ),
                            Spacer(),
                            SizedBox(
                              height: 26.h,
                              child: FittedBox(
                                child: CupertinoSwitch(
                                  activeColor: AppThemeData.orange300,
                                  value: themeChange.isDarkTheme(),
                                  onChanged: (value) {
                                    themeChange.darkTheme = value ? 0 : 1;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(LanguageScreenView());
                        },
                        child: rowWidget(name: "Language".tr, icon: "assets/icons/ic_language.svg"),
                      ),
                      FireStoreUtils.getCurrentUid() != null
                          ? GestureDetector(
                              onTap: () {
                                Get.back();
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CustomDialogBox(
                                          themeChange: themeChange,
                                          title: "Delete Account".tr,
                                          descriptions: "Your account will be deleted permanently. Your Data will not be Restored Again.".tr,
                                          positiveString: "Delete".tr,
                                          negativeString: "Cancel".tr,
                                          positiveClick: () async {
                                            controller.deleteUserAccount().then((value) async {
                                              Navigator.pop(context);
                                              await FirebaseAuth.instance.signOut();
                                              Get.offAllNamed(Routes.LANDING_SCREEN);
                                              ShowToastDialog.showToast("Account Deleted Successfully..".tr);
                                            });
                                          },
                                          positiveButtonColor: AppThemeData.orange300,
                                          positiveButtonTextColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                          negativeButtonColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                          negativeButtonTextColor: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                          negativeButtonBorderColor: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400,
                                          negativeClick: () {
                                            Navigator.pop(context);
                                          },
                                          img: Image.asset(
                                            "assets/animation/am_delete.gif",
                                            height: 64.h,
                                            width: 64.w,
                                          ));
                                    });
                              },
                              child: rowWidget(name: "Delete Account".tr, icon: "assets/icons/ic_delete.svg", textColor: AppThemeData.danger300),
                            )
                          : SizedBox(),
                      FireStoreUtils.getCurrentUid() != null
                          ? GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CustomDialogBox(
                                        themeChange: themeChange,
                                        title: "Logout".tr,
                                        descriptions: "Logging out will require you to sign in again to access your account.".tr,
                                        positiveString: "Log out".tr,
                                        negativeString: "Cancel".tr,
                                        positiveClick: () async {
                                          await FirebaseAuth.instance.signOut();
                                          Navigator.pop(context);
                                          Constant.userModel!.fcmToken = "";
                                          await FireStoreUtils.updateUser(Constant.userModel!);
                                          Get.offAll(LandingScreenView());
                                        },
                                        negativeClick: () {
                                          Navigator.pop(context);
                                        },
                                        img: Image.asset(
                                          "assets/animation/exit.gif",
                                          height: 64.h,
                                          width: 64.w,
                                        ),
                                        positiveButtonColor: AppThemeData.orange300,
                                        positiveButtonTextColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                        negativeButtonColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                        negativeButtonTextColor: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                        negativeButtonBorderColor: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400,
                                      );
                                    });
                              },
                              child: rowWidget(name: "Logout".tr, icon: "assets/icons/ic_exit.svg", textColor: AppThemeData.danger300),
                            )
                          : GestureDetector(
                              onTap: () {
                                Get.to(LandingScreenView());
                              },
                              child: rowWidget(name: "LogIn".tr, icon: "assets/icons/ic_exit.svg", textColor: AppThemeData.danger300)),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}

Padding labelWidget({required String name}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 12, top: 20),
    child: TextCustom(
      title: name.tr,
      fontSize: 16,
      fontFamily: FontFamily.medium,
    ),
  );
}

Padding rowWidget({required String name, required String icon, Color? iconColor, Color? textColor}) {
  final themeChange = Provider.of<DarkThemeProvider>(Get.context!);
  return Padding(
    padding: paddingEdgeInsets(horizontal: 0, vertical: 4),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(shape: BoxShape.circle, color: themeChange.isDarkTheme() ? AppThemeData.surface1000 : AppThemeData.grey100),
          height: 46.h,
          width: 46.w,
          child: Center(
            child: SvgPicture.asset(
              icon,
              color: iconColor,
            ),
          ),
        ),
        spaceW(width: 12),
        TextCustom(
          title: name.tr,
          fontSize: 16,
          fontFamily: FontFamily.bold,
          color: textColor ?? (themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000),
        ),
        Spacer(),
        Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppThemeData.grey500,
          size: 15,
        )
      ],
    ),
  );
}
