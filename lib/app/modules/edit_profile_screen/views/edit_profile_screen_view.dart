// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, deprecated_member_use, depend_on_referenced_packages

import 'dart:io';

import 'package:customer/app/modules/edit_profile_screen/controllers/edit_profile_screen_controller.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/network_image_widget.dart';
import 'package:customer/app/widget/text_field_widget.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/constant_widgets/top_widget.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/common_ui.dart';
import 'package:customer/themes/screen_size.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfileScreenView extends StatelessWidget {
  const EditProfileScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<EditProfileScreenController>(
        init: EditProfileScreenController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
            appBar: UiInterface.customAppBar(context, themeChange, "",backgroundColor: Colors.transparent),
            body: SingleChildScrollView(
              child: Form(
                key: controller.formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTopWidget(context, "Edit Profile", "Update your personal details and preferences here."),
                      spaceH(height: 32),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              height: 86.h,
                              width: 86.h,
                              decoration: BoxDecoration(shape: BoxShape.circle),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: controller.isLoading.value
                                    ? Constant.loader()
                                    : controller.profileImage.isEmpty
                                        ? Image.asset(
                                            Constant.userPlaceHolder,
                                            height: 56.h,
                                            width: 56.h,
                                            fit: BoxFit.cover,
                                          )
                                        : (Constant.hasValidUrl(controller.profileImage.value))
                                            ? NetworkImageWidget(
                                                imageUrl: controller.profileImage.value,
                                                height: 56.h,
                                                width: 56.h,
                                                borderRadius: 0,
                                                fit: BoxFit.cover,
                                                isProfile: true,
                                              )
                                            : Image.file(
                                                File(controller.profileImage.value),
                                                height: 56.h,
                                                width: 56.h,
                                                fit: BoxFit.cover,
                                              ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                buildBottomSheet(context, controller, themeChange);
                              },
                              child: Container(
                                height: 28.h,
                                width: 28.w,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppThemeData.orange300,
                                    border: Border.all(
                                        width: 2, color: themeChange.isDarkTheme() ? AppThemeData.primaryBlack : AppThemeData.primaryWhite)),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: SvgPicture.asset(
                                    "assets/icons/ic_camera.svg",
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
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
                      TextFieldWidget(
                        title: "Email".tr,
                        hintText: "Enter Email".tr,
                        validator: (value) => Constant.validateEmail(value),
                        controller: controller.emailController.value,
                        onPress: () {},
                        readOnly: Constant.userModel!.loginType != Constant.phoneLoginType
                            ? true
                            : false,
                      ),
                      spaceH(height: 8),
                      MobileNumberTextField(
                        controller: controller.mobileNumberController.value,
                        countryCode: "+91",
                        onPress: () {},
                        title: "Mobile Number",
                        readOnly: Constant.userModel!.loginType == Constant.phoneLoginType ? true : false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: paddingEdgeInsets(vertical: 8),
              child: RoundShapeButton(
                title: "Save".tr,
                buttonColor: AppThemeData.orange300,
                buttonTextColor: AppThemeData.primaryWhite,
                onTap: () {
                  if (controller.formKey.currentState!.validate()) {
                    controller.updateProfile();
                  }
                },
                size: const Size(350, 55),
              ),
            ),
          );
        });
  }
}

Future buildBottomSheet(BuildContext context, EditProfileScreenController controller, DarkThemeProvider themeChange) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: themeChange.isDarkTheme() ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return SizedBox(
            height: ScreenSize.height(22, context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: paddingEdgeInsets(),
                  child: TextCustom(
                    title: "Please Select".tr,
                    fontSize: 18,
                    fontFamily: FontFamily.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: paddingEdgeInsets(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () => controller.pickFile(source: ImageSource.camera),
                              icon: Icon(
                                Icons.camera_alt,
                                size: 32,
                                color: AppThemeData.orange300,
                              )),
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: TextCustom(
                              title: "Camera".tr,
                            ),
                          ),
                        ],
                      ),
                    ),
                    spaceW(width: 36),
                    Padding(
                      padding: paddingEdgeInsets(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () => controller.pickFile(source: ImageSource.gallery),
                              icon: Icon(
                                Icons.photo,
                                size: 32,
                                color: AppThemeData.orange300,
                              )),
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: TextCustom(
                              title: "Gallery".tr,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
