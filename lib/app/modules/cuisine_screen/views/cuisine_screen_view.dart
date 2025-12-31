// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:customer/app/models/cuisine_model.dart';
import 'package:customer/app/modules/cuisine_screen/controllers/cuisine_screen_controller.dart';
import 'package:customer/app/modules/restaurant_by_cuisine/views/restaurant_by_cuisine_view.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/network_image_widget.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant_widgets/top_widget.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/common_ui.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CuisineScreenView extends GetView<CuisineScreenController> {
  const CuisineScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<CuisineScreenController>(
        init: CuisineScreenController(),
        builder: (controller) {
          return Container(
            width: Responsive.width(100, context),
            height: Responsive.height(100, context),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    stops: const [0.2, 0.4],
                    colors: themeChange.isDarkTheme() ? [const Color(0xff1A0B00), const Color(0xff1C1C22)] : [const Color(0xffFFF1E5), const Color(0xffFFFFFF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: UiInterface.customAppBar(context, themeChange, "", backgroundColor: Colors.transparent, showCartButton: true, controller: controller),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      buildTopWidget(context, "Choose Your Cuisine", "Discover delicious dishes from a variety of cuisines and find your next favorite meal."),
                      spaceH(height: 32),
                      GridView.builder(
                          shrinkWrap: true,
                          primary: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.cuisineList.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, mainAxisExtent: 58),
                          itemBuilder: (context, index) {
                            CuisineModel cuisine = controller.cuisineList[index];
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Get.to(const RestaurantByCuisineView(), arguments: {'cuisineModel': cuisine});
                                  },
                                  child: Container(
                                    height: 54.h,
                                    margin: const EdgeInsets.only(right: 0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        color: themeChange.isDarkTheme() ? AppThemeData.grey700 : AppThemeData.grey300,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        children: [
                                          NetworkImageWidget(
                                            imageUrl: cuisine.image.toString(),
                                            height: 42.h,
                                            width: 42.h,
                                            borderRadius: 200,
                                            fit: BoxFit.cover,
                                          ),
                                          spaceW(width: 8),
                                          Expanded(
                                            child: TextCustom(
                                              title: cuisine.cuisineName.toString(),
                                              textOverflow: TextOverflow.ellipsis,
                                              fontFamily: FontFamily.light,
                                              textAlign: TextAlign.start,
                                              color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          })
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
