// // ignore_for_file: deprecated_member_use, must_be_immutable, depend_on_referenced_packages
//
// import 'package:customer/app/modules/login_screen/views/login_screen_view.dart';
// import 'package:customer/app/modules/signup_screen/controllers/signup_screen_controller.dart';
// import 'package:customer/app/routes/app_pages.dart';
// import 'package:customer/app/widget/global_widgets.dart';
// import 'package:customer/app/widget/text_field_widget.dart';
// import 'package:customer/constant/constant.dart';
// import 'package:customer/constant/show_toast_dialog.dart';
// import 'package:customer/constant_widgets/round_shape_button.dart';
// import 'package:customer/themes/app_fonts.dart';
// import 'package:customer/themes/app_theme_data.dart';
// import 'package:customer/utils/dark_theme_provider.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:nb_utils/nb_utils.dart';
// import 'package:provider/provider.dart';
//
// class EnterPasswordScreenView extends GetView<SignupScreenController> {
//   EnterPasswordScreenView({super.key});
//
//   GlobalKey<FormState> formKey = GlobalKey<FormState>();
//
//   @override
//   Widget build(BuildContext context) {
//     final themeChange = Provider.of<DarkThemeProvider>(context);
//     controller.passwordController.value.addListener(() => controller.checkFieldsFilled());
//     controller.confirmPasswordController.value.addListener(() => controller.checkFieldsFilled());
//
//     return GetBuilder(
//       init: SignupScreenController(),
//       builder: (controller) {
//         return Scaffold(
//           appBar: AppBar(
//             backgroundColor: Colors.transparent,
//             leading: GestureDetector(
//               onTap: () {
//                 Get.back();
//               },
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey100,
//                   ),
//                   height: 34.h,
//                   width: 34.w,
//                   child: Padding(
//                     padding: const EdgeInsets.all(6.0),
//                     child: Icon(
//                       Icons.arrow_back_ios_new,
//                       size: 18,
//                       color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
//           body: Form(
//             key: formKey,
//             child: SingleChildScrollView(
//                 child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Padding(
//                   //   padding: paddingEdgeInsets(horizontal: 0, vertical: 34),
//                   //   child: GestureDetector(
//                   //     onTap: () {
//                   //       Get.back();
//                   //     },
//                   //     child: Container(
//                   //       decoration: BoxDecoration(
//                   //         shape: BoxShape.circle,
//                   //         color: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey100,
//                   //       ),
//                   //       height: 34.h,
//                   //       width: 34.w,
//                   //       child: Icon(
//                   //         Icons.arrow_back_ios_new,
//                   //         size: 20,
//                   //         color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
//                   //       ),
//                   //     ),
//                   //   ),
//                   // ),
//                   buildTopWidget(context),
//                   buildEmailPasswordWidget(context),
//                   spaceH(height: 130.h),
//                   Obx(
//                     () => Row(
//                       children: [
//                         Expanded(
//                           child: RoundShapeButton(
//                             title: "Save and Continue".tr,
//                             buttonColor: controller.isFourthButtonEnabled.value
//                                 ? AppThemeData.orange300
//                                 : themeChange.isDarkTheme()
//                                     ? AppThemeData.grey800
//                                     : AppThemeData.grey200,
//                             buttonTextColor: controller.isFourthButtonEnabled.value
//                                 ? themeChange.isDarkTheme()
//                                     ? AppThemeData.grey1000
//                                     : AppThemeData.grey50
//                                 : AppThemeData.grey500,
//                             onTap: () {
//                               if (formKey.currentState!.validate()) {
//                                 if (controller.passwordController.value.text == controller.confirmPasswordController.value.text) {
//                                   controller.signUp();
//                                 } else {
//                                   ShowToastDialog.showToast('Please enter valid password'.tr);
//                                 }
//                               } else {
//                                 ShowToastDialog.showToast('Please enter a valid email'.tr);
//                               }
//                             },
//                             size: Size(358.w, 58.h),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             )),
//           ),
//           bottomNavigationBar: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 RichText(
//                   text: TextSpan(
//                       text: 'Already have an account? '.tr,
//                       style: TextStyle(fontSize: 16, color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800, fontFamily: FontFamily.regular),
//                       children: [
//                         TextSpan(
//                           text: 'Log in'.tr,
//                           style: TextStyle(fontSize: 16, color: AppThemeData.orange300, fontFamily: FontFamily.medium, decoration: TextDecoration.underline),
//                           recognizer: TapGestureRecognizer()..onTap = () => Get.to(LoginScreenView()),
//                         )
//                       ]),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   buildTopWidget(BuildContext context) {
//     final themeChange = Provider.of<DarkThemeProvider>(context);
//     return SizedBox(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("Create a Password".tr,
//               style: TextStyle(
//                 fontFamily: FontFamily.bold,
//                 fontSize: 28,
//                 color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
//               )),
//           Text("Choose a strong password to secure your account.".tr,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontFamily: FontFamily.regular,
//                 color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
//               ),
//               textAlign: TextAlign.start),
//         ],
//       ),
//     );
//   }
//
//   buildEmailPasswordWidget(BuildContext context) {
//     final themeChange = Provider.of<DarkThemeProvider>(context);
//
//     return Column(
//       children: [
//         Obx(() => TextFieldWidget(
//               title: "Password".tr,
//               hintText: "Enter Password".tr,
//               validator: (value) => Constant.validatePassword(value),
//               controller: controller.passwordController.value,
//               obscureText: controller.isPasswordVisible.value,
//               suffix: SvgPicture.asset(
//                 controller.isPasswordVisible.value ? "assets/icons/ic_hide_password.svg" : "assets/icons/ic_show_password.svg",
//                 color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800,
//               ).onTap(() {
//                 controller.isPasswordVisible.value = !controller.isPasswordVisible.value;
//               }),
//               onPress: () {},
//             )),
//         Obx(() => TextFieldWidget(
//               title: "Confirm Password".tr,
//               hintText: "Enter Confirm Password".tr,
//               validator: (value) => Constant.validatePassword(value),
//               controller: controller.confirmPasswordController.value,
//               obscureText: controller.isPasswordVisible.value,
//               suffix: SvgPicture.asset(
//                 controller.isPasswordVisible.value ? "assets/icons/ic_hide_password.svg" : "assets/icons/ic_show_password.svg",
//                 color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800,
//               ).onTap(() {
//                 controller.isPasswordVisible.value = !controller.isPasswordVisible.value;
//               }),
//               onPress: () {},
//             )),
//       ],
//     );
//   }
// }
