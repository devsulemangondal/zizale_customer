// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final Function() onPress;
  final String? hintText;
  const SearchField({super.key, required this.controller, required this.onChanged,required this.onPress,this.hintText});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return TextFormField(
      onTap: onPress,
      onChanged: onChanged,
      validator: (value) => value != null && value.isNotEmpty ? null : 'This field required'.tr,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      controller: controller,
      textAlign: TextAlign.start,
      textAlignVertical: TextAlignVertical.top,
      cursorColor: AppThemeData.orange300,
      style: TextStyle(
          color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800,
          fontFamily: FontFamily.regular,
          fontSize: 14),
      decoration: InputDecoration(
          errorStyle: const TextStyle(fontFamily: FontFamily.regular),
          isDense: true,
          filled: true,
          fillColor: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey50,
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              spaceW(width: 16),
              SvgPicture.asset(
                "assets/icons/ic_search.svg",
                color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800,
                height: 19.h,
                width: 19.w,
              ),
              spaceW(width: 16)
            ],
          ),
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
            borderSide:  BorderSide(color: AppThemeData.orange300, width: 1),
          ),
          hintText: hintText ?? "Search Food".tr,
          hintStyle: TextStyle(fontSize: 14, color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600, fontFamily: FontFamily.regular)),
    );
  }
}
