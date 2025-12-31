import 'dart:convert';

import 'package:customer/app/models/language_model.dart';
import 'package:customer/app/modules/language_screen/controllers/language_screen_controller.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/network_image_widget.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/constant_widgets/top_widget.dart';
import 'package:customer/services/localization_service.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/common_ui.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class LanguageScreenView extends GetView {
  const LanguageScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<LanguageScreenController>(
        init: LanguageScreenController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface.customAppBar(context, themeChange, "", backgroundColor: Colors.transparent),
            bottomNavigationBar: Padding(
              padding: paddingEdgeInsets(vertical: 8, horizontal: 16),
              child: RoundShapeButton(
                title: "Save".tr,
                buttonColor: AppThemeData.orange300,
                buttonTextColor: AppThemeData.primaryWhite,
                onTap: () {
                  LocalizationService().changeLocale(controller.selectedLanguage.value.code.toString());
                  Preferences.setString(
                    Preferences.languageCodeKey,
                    jsonEncode(
                      controller.selectedLanguage.value,
                    ),
                  );
                  Get.back();
                },
                size: Size(Responsive.width(45, context), 52),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  buildTopWidget(context, "Select Language".tr, "Choose your preferred language for the app interface.".tr),
                  spaceH(height: 32),
                  controller.isLoading.value
                      ? Constant.loader()
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 2.5),
                          itemCount: controller.languageList.length,
                          itemBuilder: (context, index) {
                            final bgColor =
                                themeChange.isDarkTheme() ? controller.darkModeColors[index % controller.darkModeColors.length] : controller.lightModeColors[index % controller.lightModeColors.length];
                            return Obx(
                              () => Container(
                                padding: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                    child: RadioGroup<LanguageModel>(
                                  groupValue: controller.selectedLanguage.value,
                                  onChanged: (value) {
                                    controller.selectedLanguage.value = value!;
                                  },
                                  child: RadioListTile(
                                    dense: true,
                                    value: controller.languageList[index],
                                    contentPadding: EdgeInsets.zero,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    activeColor: controller.activeColor[index % controller.activeColor.length],
                                    title: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        NetworkImageWidget(
                                          imageUrl: controller.languageList[index].image.toString(),
                                          height: 40,
                                          width: 22,
                                          fit: BoxFit.contain,
                                          color: themeChange.isDarkTheme()
                                              ? controller.textColorDarkMode[index % controller.textColorDarkMode.length]
                                              : controller.textColorLightMode[index % controller.textColorLightMode.length],
                                        ),
                                        spaceW(width: 8),
                                        TextCustom(
                                          title: controller.languageList[index].name.toString(),
                                          fontSize: 16,
                                          color: themeChange.isDarkTheme()
                                              ? controller.textColorDarkMode[index % controller.textColorDarkMode.length]
                                              : controller.textColorLightMode[index % controller.textColorLightMode.length],
                                          fontFamily: FontFamily.medium,
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                              ),
                            );
                          })
                ],
              ),
            ),
          );
        });
  }
}
