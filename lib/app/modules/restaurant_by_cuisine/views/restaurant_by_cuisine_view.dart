// ignore_for_file: deprecated_member_use

import 'package:customer/app/models/vendor_model.dart';
import 'package:customer/app/modules/restaurant_detail_screen/views/restaurant_detail_screen_view.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/network_image_widget.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/login_dialog.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/constant_widgets/top_widget.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/common_ui.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../controllers/restaurant_by_cuisine_controller.dart';

class RestaurantByCuisineView extends GetView<RestaurantByCuisineController> {
  const RestaurantByCuisineView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: RestaurantByCuisineController(),
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
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTopWidget(context, 'cuisine_restaurant_title'.trParams({'cuisineName': controller.cuisineModel.value.cuisineName.toString()}),
                        'cuisine_restaurant_subtitle'.trParams({'cuisineName': controller.cuisineModel.value.cuisineName.toString()})),
                    spaceH(height: 32),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: SizedBox(
                        height: 45.h,
                        child: ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: [
                            RoundShapeButton(
                              title: "All".tr,
                              borderRadius: 50,
                              buttonColor: controller.selectedType.value == 0
                                  ? AppThemeData.secondary300
                                  : themeChange.isDarkTheme()
                                      ? AppThemeData.grey800
                                      : AppThemeData.grey200,
                              buttonTextColor: controller.selectedType.value == 0
                                  ? AppThemeData.primaryWhite
                                  : themeChange.isDarkTheme()
                                      ? AppThemeData.grey400
                                      : AppThemeData.grey600,
                              onTap: () {
                                controller.selectedType.value = 0;
                              },
                              size: Size(70.w, 38.h),
                              textSize: 14,
                            ),
                            spaceW(width: 8),
                            RoundShapeButton(
                              title: "Veg".tr,
                              borderRadius: 50,
                              buttonColor: controller.selectedType.value == 1
                                  ? AppThemeData.secondary300
                                  : themeChange.isDarkTheme()
                                      ? AppThemeData.grey800
                                      : AppThemeData.grey200,
                              buttonTextColor: controller.selectedType.value == 1
                                  ? AppThemeData.primaryWhite
                                  : themeChange.isDarkTheme()
                                      ? AppThemeData.grey400
                                      : AppThemeData.grey600,
                              onTap: () {
                                controller.selectedType.value = 1;
                              },
                              size: Size(80.w, 38.h),
                              textSize: 14,
                            ),
                            spaceW(width: 8),
                            RoundShapeButton(
                              title: "Non Veg".tr,
                              borderRadius: 50,
                              buttonColor: controller.selectedType.value == 2
                                  ? AppThemeData.secondary300
                                  : themeChange.isDarkTheme()
                                      ? AppThemeData.grey800
                                      : AppThemeData.grey200,
                              buttonTextColor: controller.selectedType.value == 2
                                  ? AppThemeData.primaryWhite
                                  : themeChange.isDarkTheme()
                                      ? AppThemeData.grey400
                                      : AppThemeData.grey600,
                              onTap: () {
                                controller.selectedType.value = 2;
                              },
                              size: Size(120.w, 38.h),
                              textSize: 14,
                            ),
                            spaceW(width: 16),
                          ],
                        ),
                      ),
                    ),
                    spaceH(height: 18),
                    Expanded(
                      child: controller.isLoading.value
                          ? Constant.loader()
                          : (controller.selectedType.value == 0
                                  ? controller.restaurantList.isEmpty
                                  : controller.selectedType.value == 1
                                      ? controller.vegRestaurantList.isEmpty
                                      : controller.nonVegRestaurantList.isEmpty)
                              ? Center(
                                  child: TextCustom(
                                    title: "No Restaurant Found..".tr,
                                    color: themeChange.isDarkTheme() ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemCount: controller.selectedType.value == 0
                                      ? controller.restaurantList.length
                                      : controller.selectedType.value == 1
                                          ? controller.vegRestaurantList.length
                                          : controller.nonVegRestaurantList.length,
                                  itemBuilder: (context, index) {
                                    VendorModel restaurant = controller.selectedType.value == 0
                                        ? controller.restaurantList[index]
                                        : controller.selectedType.value == 1
                                            ? controller.vegRestaurantList[index]
                                            : controller.nonVegRestaurantList[index];

                                    bool isLiked = restaurant.likedUser?.contains(FireStoreUtils.getCurrentUid()) ?? false;
                                    return restaurant.isOnline == true
                                        ? Padding(
                                            padding: paddingEdgeInsets(horizontal: 0, vertical: 8),
                                            child: Stack(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Get.to(const RestaurantDetailScreenView(), arguments: {"restaurantModel": restaurant});
                                                  },
                                                  child: Row(
                                                    children: [
                                                      NetworkImageWidget(
                                                        imageUrl: restaurant.coverImage.toString(),
                                                        width: 104.w,
                                                        height: 116.h,
                                                        borderRadius: 10,
                                                        fit: BoxFit.fill,
                                                      ),
                                                      spaceW(width: 12),
                                                      SizedBox(
                                                        // height: 88.h,
                                                        width: 230.w,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            spaceH(height: 6),
                                                            Padding(
                                                              padding: const EdgeInsets.only(right: 16),
                                                              child: TextCustom(
                                                                title: restaurant.vendorName.toString(),
                                                                fontSize: 16,
                                                                fontFamily: FontFamily.medium,
                                                                color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                SvgPicture.asset(
                                                                  "assets/icons/ic_location.svg",
                                                                  height: 14.h,
                                                                  width: 11.w,
                                                                  color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                                ),
                                                                spaceW(width: 4),
                                                                Expanded(
                                                                  child: TextCustom(
                                                                    title: restaurant.address!.address.toString(),
                                                                    fontSize: 12,
                                                                    fontFamily: FontFamily.regular,
                                                                    textAlign: TextAlign.start,
                                                                    color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            TextCustom(
                                                              title: restaurant.cuisineName.toString(),
                                                              fontSize: 12,
                                                              fontFamily: FontFamily.regular,
                                                              color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                            ),
                                                            Row(
                                                              children: [
                                                                SvgPicture.asset(
                                                                  "assets/icons/ic_star.svg",
                                                                  height: 18.h,
                                                                  width: 18.w,
                                                                ),
                                                                spaceW(width: 4),
                                                                TextCustom(
                                                                  title: Constant.calculateReview(
                                                                    Constant.safeParse(restaurant.reviewSum),
                                                                    Constant.safeParse(restaurant.reviewCount),
                                                                  ).toStringAsFixed(1),
                                                                  fontSize: 14,
                                                                  fontFamily: FontFamily.regular,
                                                                  color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                                                  child: TextCustom(
                                                                    title: "|",
                                                                    color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400,
                                                                  ),
                                                                ),
                                                                TextCustom(
                                                                  title: FireStoreUtils.getCurrentUid() == null
                                                                      ? "${Constant.calculateDistanceInKm(Constant.currentLocation!.location!.latitude!, Constant.currentLocation!.location!.longitude!, restaurant.address!.location!.latitude!, restaurant.address!.location!.longitude!)} km"
                                                                      : "${Constant.calculateDistanceInKm(Constant.userModel!.addAddresses!.first.location!.latitude!, Constant.userModel!.addAddresses!.first.location!.longitude!, restaurant.address!.location!.latitude!, restaurant.address!.location!.longitude!)} km",
                                                                  fontSize: 14,
                                                                  fontFamily: FontFamily.light,
                                                                  color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                                                ),
                                                              ],
                                                            ),
                                                            spaceH(height: 6)
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        if (FireStoreUtils.getCurrentUid() != null) {
                                                          if (Constant.isRestaurantOpen(restaurant)) {
                                                            if (isLiked) {
                                                              restaurant.likedUser!.remove(FireStoreUtils.getCurrentUid());
                                                            } else {
                                                              restaurant.likedUser!.add(FireStoreUtils.getCurrentUid());
                                                            }
                                                            await FireStoreUtils.updateRestaurant(restaurant);
                                                            controller.restaurantList.refresh();
                                                          } else {
                                                            return;
                                                          }
                                                        } else {
                                                          showDialog(
                                                              context: context,
                                                              builder: (context) {
                                                                return Dialog(
                                                                  child: LoginDialog(),
                                                                );
                                                              });
                                                        }
                                                      },
                                                      child: isLiked
                                                          ? SvgPicture.asset("assets/icons/ic_fill_favourite.svg")
                                                          : SvgPicture.asset(
                                                              "assets/icons/ic_favorite.svg",
                                                            ),
                                                    ))
                                              ],
                                            ),
                                          )
                                        : const SizedBox();
                                  },
                                ),
                    )
                  ],
                ),
              )),
        );
      },
    );
  }
}
