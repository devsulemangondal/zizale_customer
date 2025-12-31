import 'package:customer/app/modules/track_order/controllers/track_order_controller.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../themes/screen_size.dart';

class CancelReasonBottomSheet extends StatelessWidget {
  final VoidCallback onConfirm;

  const CancelReasonBottomSheet({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<TrackOrderController>(
        init: TrackOrderController(),
        builder: (controller) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 8.h,
                      width: 72.w,
                      decoration: BoxDecoration(color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400, borderRadius: BorderRadius.circular(100)),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          spaceH(height: 16),
                          GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey100,
                              ),
                              height: 34.h,
                              width: 34.w,
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                size: 20,
                                color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                              ),
                            ),
                          ),
                          spaceH(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextCustom(
                                    title: "Cancel Order".tr,
                                    fontSize: 20,
                                    fontFamily: FontFamily.bold,
                                    color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000),
                                spaceH(height: 4),
                                TextCustom(
                                    title: "Choose a reason for canceling your order.".tr,
                                    fontSize: 16,
                                    maxLine: 2,
                                    fontFamily: FontFamily.regular,
                                    textAlign: TextAlign.start,
                                    color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600),
                              ],
                            ),
                          ),
                          spaceH(height: 24),
                          ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.cancelReason.length,
                              itemBuilder: (context, index) {
                                return Obx(() => RadioGroup<int>(
                                      groupValue: controller.selectedIndex.value,
                                      onChanged: (index) {
                                        controller.selectedIndex.value = index ?? 0;
                                      },
                                      child: RadioListTile(
                                        dense: true,
                                        value: index,
                                        controlAffinity: ListTileControlAffinity.trailing,
                                        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                                          if (states.contains(WidgetState.selected)) {
                                            return AppThemeData.orange300;
                                          } else {
                                            return themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600;
                                          }
                                        }),
                                        title: TextCustom(
                                          title: controller.cancelReason[index],
                                          fontSize: 16,
                                          fontFamily: FontFamily.regular,
                                          textAlign: TextAlign.start,
                                          color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                        ),
                                      ),
                                    ));
                              }),
                          Obx(
                            () => Visibility(
                              visible: controller.cancelReason[controller.selectedIndex.value] == "Other",
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: TextFormField(
                                  enabled: controller.cancelReason[controller.selectedIndex.value] == "Other",
                                  validator: (value) => value != null && value.isNotEmpty ? null : "This field required".tr,
                                  keyboardType: TextInputType.text,
                                  textCapitalization: TextCapitalization.sentences,
                                  controller: controller.otherReasonController.value,
                                  textAlign: TextAlign.start,
                                  textAlignVertical: TextAlignVertical.top,
                                  style: TextStyle(
                                      //color: AppColors.grey800,
                                      color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800,
                                      fontFamily: FontFamily.regular,
                                      fontSize: 14),
                                  decoration: InputDecoration(
                                      errorStyle: const TextStyle(fontFamily: FontFamily.regular),
                                      isDense: true,
                                      filled: true,
                                      fillColor: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey50,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400, width: 1),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400, width: 1),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400, width: 1),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: AppThemeData.danger300, width: 1),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400, width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: AppThemeData.orange300, width: 1),
                                      ),
                                      hintText: "Enter other reason".tr,
                                      hintStyle:
                                          TextStyle(fontSize: 14, color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600, fontFamily: FontFamily.regular)),
                                ),
                              ),
                            ),
                          ),
                          spaceH(height: 40),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: RoundShapeButton(
                                      title: "Keep Order".tr,
                                      buttonColor: themeChange.isDarkTheme() ? AppThemeData.grey800 : AppThemeData.grey200,
                                      buttonTextColor: AppThemeData.grey500,
                                      onTap: () {
                                        Get.back();
                                      },
                                      size: Size(0, ScreenSize.height(6, context))),
                                ),
                                spaceW(width: 12),
                                Expanded(
                                  child: RoundShapeButton(
                                      title: "Cancel Order".tr,
                                      buttonColor: AppThemeData.orange300,
                                      buttonTextColor: AppThemeData.primaryWhite,
                                      onTap: onConfirm,
                                      size: Size(0, ScreenSize.height(6, context))),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
