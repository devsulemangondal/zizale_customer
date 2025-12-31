// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'dart:developer';

import 'package:customer/app/models/product_model.dart';
import 'package:customer/app/models/vendor_model.dart';
import 'package:customer/app/modules/home/controllers/home_controller.dart';
import 'package:customer/app/modules/restaurant_detail_screen/views/restaurant_detail_screen_view.dart';
import 'package:customer/app/modules/search_food_screen/controllers/search_food_controller.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/network_image_widget.dart';
import 'package:customer/app/widget/search_field.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/item_tag.dart';
import 'package:customer/constant_widgets/login_dialog.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/extension/string_extensions.dart';
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

class SearchFoodScreenView extends GetView<SearchFoodScreenController> {
  const SearchFoodScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<SearchFoodScreenController>(
        init: SearchFoodScreenController(),
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
              resizeToAvoidBottomInset: true,
              appBar: UiInterface.customAppBar(context, themeChange, "", backgroundColor: Colors.transparent, showCartButton: true, controller: controller),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Column(
                      children: [
                        SearchField(
                          controller: controller.searchController.value,
                          onChanged: (value) {
                            HomeController homeController = Get.put(HomeController());
                            controller.searchRestaurant(
                                latitude: homeController.selectedAddress.value.location!.latitude!.toDouble(),
                                longitude: homeController.selectedAddress.value.location!.longitude!.toDouble(),
                                radius: Constant.restaurantRadius.toDouble());
                          },
                          onPress: () {},
                        ),
                        spaceH(height: 20.h),
                        Row(
                          children: [
                            Expanded(
                              child: RoundShapeButton(
                                title: "Restaurant".tr,
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
                                size: Size(0.w, 38.h),
                                textSize: 14,
                              ),
                            ),
                            spaceW(width: 12),
                            Expanded(
                              child: RoundShapeButton(
                                title: "Dishes".tr,
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
                                size: Size(0.w, 38.h),
                                textSize: 14,
                              ),
                            ),
                          ],
                        ),
                        spaceH(height: 20),
                      ],
                    ),
                    (controller.searchRestaurantList.isEmpty || controller.searchProductList.isEmpty) && controller.searchController.value.text.isEmpty
                        ? Expanded(
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 40, color: Colors.grey),
                                  SizedBox(height: 10),
                                  Text(
                                    "No results found".tr,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : controller.selectedType.value == 0
                            ? Expanded(child: Obx(
                                () {
                                  if (controller.isLoading.value) {
                                    return Constant.loader();
                                  } else if (controller.searchRestaurantList.isEmpty) {
                                    return Center(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.search_off, size: 40, color: Colors.grey),
                                          SizedBox(height: 10),
                                          Text(
                                            "No results found".tr,
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return SizedBox(
                                      height: MediaQuery.of(context).size.height - 200,
                                      child: ListView.builder(
                                        itemCount: controller.searchRestaurantList.length,
                                        itemBuilder: (context, index) {
                                          VendorModel restaurant = controller.searchRestaurantList[index];

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
                                                                  controller.searchRestaurantList.refresh();
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
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        physics: const AlwaysScrollableScrollPhysics(),
                                      ),
                                    );
                                  }
                                },
                              ))
                            : Expanded(
                                flex: 4,
                                child: Obx(() {
                                  if (controller.isLoading.value) {
                                    return Constant.loader(); // Loading indicator
                                  } else if (controller.searchProductList.isEmpty) {
                                    return Center(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.search_off, size: 40, color: Colors.grey),
                                          SizedBox(height: 10),
                                          Text(
                                            "No results found".tr,
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return SizedBox(
                                      height: MediaQuery.of(context).size.height - 200,
                                      // margin: EdgeInsets.only(bottom: 20),
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: controller.searchProductList.length,
                                        itemBuilder: (context, index) {
                                          ProductModel product = controller.searchProductList[index];
                                          bool isLiked = product.likedUser?.contains(FireStoreUtils.getCurrentUid()) ?? false;
                                          return GestureDetector(
                                            onTap: () async {
                                              log("++++++++++++ ${product.vendorId}");
                                              FireStoreUtils.getRestaurant(product.vendorId.toString()).then((value) {
                                                if (value != null) {
                                                  log("++++++++++++ ${value.toJson()}");
                                                  Get.to(const RestaurantDetailScreenView(), arguments: {"restaurantModel": value});
                                                }
                                              });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 8, bottom: 10),
                                              child: FittedBox(
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        NetworkImageWidget(
                                                          imageUrl: product.productImage.toString(),
                                                          height: 150.h,
                                                          width: 140.w,
                                                          borderRadius: 8,
                                                        ),
                                                        Positioned(
                                                          top: 8,
                                                          left: 8,
                                                          child: Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                            decoration: BoxDecoration(
                                                                color: ItemTag.getItemTagBackgroundColor(product.itemTag.toString(), context),
                                                                borderRadius: BorderRadius.circular(4)),
                                                            child: TextCustom(
                                                              title: ItemTag.getItemTagTitle(product.itemTag.toString()),
                                                              fontSize: 12,
                                                              fontFamily: FontFamily.medium,
                                                              color: ItemTag.getItemTagTitleColor(product.itemTag.toString(), context),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    spaceW(width: 12),
                                                    SizedBox(
                                                      width: 202.w,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              SvgPicture.asset(
                                                                "assets/icons/ic_star.svg",
                                                              ),
                                                              spaceW(width: 5),
                                                              TextCustom(
                                                                title: Constant.calculateReview(
                                                                  Constant.safeParse(product.reviewSum),
                                                                  Constant.safeParse(product.reviewCount),
                                                                ).toStringAsFixed(1),
                                                                fontSize: 14,
                                                                fontFamily: FontFamily.regular,
                                                                color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                              ),
                                                              const Spacer(),
                                                              GestureDetector(
                                                                  onTap: () async {
                                                                    if (isLiked) {
                                                                      product.likedUser!.remove(FireStoreUtils.getCurrentUid());
                                                                    } else {
                                                                      product.likedUser!.add(FireStoreUtils.getCurrentUid());
                                                                    }
                                                                    await FireStoreUtils.updateProduct(product);
                                                                    controller.searchProductList.refresh();
                                                                  },
                                                                  child: isLiked
                                                                      ? SvgPicture.asset("assets/icons/ic_fill_favourite.svg")
                                                                      : SvgPicture.asset("assets/icons/ic_favorite.svg")),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              SvgPicture.asset(
                                                                "assets/icons/ic_food_type.svg",
                                                                color: product.foodType == "Veg"
                                                                    ? themeChange.isDarkTheme()
                                                                        ? AppThemeData.success200
                                                                        : AppThemeData.success400
                                                                    : themeChange.isDarkTheme()
                                                                        ? AppThemeData.danger200
                                                                        : AppThemeData.danger400,
                                                                height: 18.h,
                                                                width: 18.w,
                                                              ),
                                                              spaceW(width: 4),
                                                              Expanded(
                                                                  child: TextCustom(
                                                                title: product.productName.toString(),
                                                                fontSize: 16,
                                                                fontFamily: FontFamily.medium,
                                                                textAlign: TextAlign.start,
                                                                color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                              ))
                                                            ],
                                                          ),
                                                          TextCustom(
                                                            title: Constant.amountShow(amount: product.price.toString()),
                                                            fontSize: 16,
                                                            fontFamily: FontFamily.bold,
                                                            color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                          ),
                                                          TextCustom(
                                                            title: product.description.toString(),
                                                            fontSize: 14,
                                                            fontFamily: FontFamily.regular,
                                                            color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                                          ),
                                                          spaceH(height: 10),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }
                                }),
                              )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
