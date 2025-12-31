// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/app/models/banner_model.dart';
import 'package:customer/app/models/category_model.dart';
import 'package:customer/app/models/cuisine_model.dart';
import 'package:customer/app/models/product_model.dart';
import 'package:customer/app/models/vendor_model.dart';
import 'package:customer/app/modules/all_restaurant_screen/views/all_restaurant_screen_view.dart';
import 'package:customer/app/modules/cuisine_screen/views/cuisine_screen_view.dart';
import 'package:customer/app/modules/restaurant_by_cuisine/views/restaurant_by_cuisine_view.dart';
import 'package:customer/app/modules/restaurant_detail_screen/views/restaurant_detail_screen_view.dart';
import 'package:customer/app/modules/search_food_screen/views/search_food_view.dart';
import 'package:customer/app/modules/select_address/views/select_address_view.dart';
import 'package:customer/app/modules/service_unavailable_screen.dart';
import 'package:customer/app/modules/signup_screen/views/enter_location_view.dart';
import 'package:customer/app/modules/top_rated_food/views/top_rated_food_view.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/network_image_widget.dart';
import 'package:customer/app/widget/search_field.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/login_dialog.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../my_cart/views/my_cart_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<HomeController>(
      init: HomeController(),
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
          child: RefreshIndicator(
            onRefresh: () => controller.getData(),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                title: InkWell(
                  onTap: () {
                    if (FireStoreUtils.getCurrentUid() != null) {
                      Get.to(() => SelectAddressView(
                            isFromCart: false,
                          ));
                    } else {
                      Get.to(EnterLocationView());
                    }
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        height: 42,
                        width: 31,
                        child: SvgPicture.asset(
                          "assets/icons/ic_map_pin_2.svg",
                        ),
                      ),
                      spaceW(),
                      SizedBox(
                        width: 250.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                TextCustom(
                                  title: "Deliver to".tr,
                                  fontSize: 14,
                                  color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey1000,
                                  fontFamily: FontFamily.light,
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  color: AppThemeData.orange300,
                                )
                              ],
                            ),
                            TextCustom(
                              title: controller.selectedAddress.value.getFullAddress().toString(),
                              fontFamily: FontFamily.medium,
                              fontSize: 16,
                              maxLine: 1,
                              textOverflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () {
                      Get.to(const MyCartView());
                    },
                    child: Obx(
                      () => Container(
                        height: 36.h,
                        width: 36.w,
                        decoration: BoxDecoration(color: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey100, shape: BoxShape.circle),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: (controller.getCartItemCount() > 0)
                              ? Badge(
                                  offset: const Offset(6, -8),
                                  largeSize: 18,
                                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                                  backgroundColor: AppThemeData.orange300,
                                  label: TextCustom(
                                    title: controller.getCartItemCount().toString(),
                                    fontSize: 12,
                                    fontFamily: FontFamily.regular,
                                    color: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                  ),
                                  child: SvgPicture.asset(
                                    "assets/icons/ic_cart.svg",
                                    color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800,
                                  ),
                                )
                              : SvgPicture.asset(
                                  "assets/icons/ic_cart.svg",
                                  color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800,
                                ),
                        ),
                      ),
                    ),
                  ),
                  spaceW(width: 16)
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    spaceH(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextCustom(
                            title: "${"Hey,".tr} ${FireStoreUtils.getCurrentUid() == null ? "" : Constant.userModel!.firstName} 👋",
                            fontSize: 20,
                            fontFamily: FontFamily.bold,
                          ),
                          spaceH(height: 16),
                          !Constant.isZoneAvailable
                              ? SizedBox()
                              : GestureDetector(
                                  onTap: () {},
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(const SearchFoodScreenView());
                                    },
                                    child: IgnorePointer(
                                      ignoring: true,
                                      child: SearchField(
                                        controller: controller.searchController.value,
                                        onChanged: (value) {},
                                        onPress: () {},
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    spaceH(height: 24),
                    !Constant.isZoneAvailable
                        ? ServiceUnavailableScreen()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextCustom(
                                      title: "Cuisine".tr,
                                      fontSize: 18,
                                      fontFamily: FontFamily.bold,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Get.to(const CuisineScreenView());
                                      },
                                      child: TextCustom(
                                        title: "View all".tr,
                                        fontSize: 16,
                                        color: AppThemeData.orange300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              spaceH(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: controller.isLoading.value
                                    ? Constant.loader()
                                    : SizedBox(
                                        height: 130,
                                        child: GridView.builder(
                                          shrinkWrap: true,
                                          primary: false,
                                          scrollDirection: Axis.horizontal,
                                          physics: const BouncingScrollPhysics(),
                                          itemCount: controller.cuisineList.length,
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            mainAxisSpacing: 8,
                                            crossAxisSpacing: 12,
                                            mainAxisExtent: 160,
                                          ),
                                          itemBuilder: (context, index) {
                                            CuisineModel cuisine = controller.cuisineList[index];
                                            return GestureDetector(
                                              onTap: () {
                                                Get.to(const RestaurantByCuisineView(), arguments: {'cuisineModel': cuisine});
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(100),
                                                  border: Border.all(
                                                    color: themeChange.isDarkTheme() ? AppThemeData.grey700 : AppThemeData.grey300,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  child: Row(
                                                    children: [
                                                      NetworkImageWidget(
                                                        imageUrl: cuisine.image.toString(),
                                                        height: 42.h,
                                                        width: 42.h,
                                                        borderRadius: 200,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      spaceW(width: 10),
                                                      Expanded(
                                                        child: TextCustom(
                                                          title: cuisine.cuisineName.toString(),
                                                          fontSize: 14,
                                                          fontFamily: FontFamily.regular,
                                                          textAlign: TextAlign.start,
                                                          color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                              ),
                              spaceH(height: 24),
                              controller.bannerList.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: BannerView(),
                                    )
                                  : SizedBox(),
                              if (controller.top5RestaurantList.isNotEmpty)
                                Column(
                                  children: [
                                    spaceH(height: 24),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextCustom(
                                            title: "Popular Restaurant".tr,
                                            fontSize: 18,
                                            fontFamily: FontFamily.bold,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Get.to(const AllRestaurantScreenView());
                                            },
                                            child: TextCustom(
                                              title: "View all".tr,
                                              fontSize: 16,
                                              color: AppThemeData.orange300,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    spaceH(height: 16),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: SizedBox(
                                        height: 262.h,
                                        child: Align(
                                          alignment: AlignmentDirectional.centerStart,
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: controller.top5RestaurantList.length,
                                              itemBuilder: (context, index) {
                                                VendorModel restaurant = controller.top5RestaurantList[index];
                                                bool isLiked = restaurant.likedUser?.contains(FireStoreUtils.getCurrentUid()) ?? false;
                                                return restaurant.isOnline == true
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          Get.to(() => RestaurantDetailScreenView(), arguments: {"restaurantModel": restaurant});
                                                        },
                                                        child: Container(
                                                          margin: const EdgeInsets.only(right: 16),
                                                          alignment: AlignmentDirectional.centerStart,
                                                          width: 229.w,
                                                          decoration: BoxDecoration(
                                                              color: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey100,
                                                              borderRadius: BorderRadius.circular(12)),
                                                          child: Column(
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius: const BorderRadius.only(
                                                                  topLeft: Radius.circular(12),
                                                                  topRight: Radius.circular(12),
                                                                ),
                                                                child: Stack(
                                                                  children: [
                                                                    // 🔥 IMAGE WITHOUT COLORFILTER WHEN OPEN
                                                                    if (Constant.isRestaurantOpen(restaurant))
                                                                      CachedNetworkImage(
                                                                        imageUrl: restaurant.coverImage.toString(),
                                                                        height: 150.h,
                                                                        width: 229.w,
                                                                        fit: BoxFit.fill,
                                                                        progressIndicatorBuilder: (context, url, downloadProgress) => Shimmer.fromColors(
                                                                          baseColor: AppThemeData.grey300,
                                                                          highlightColor: AppThemeData.grey200,
                                                                          child: Container(
                                                                            width: 229.w,
                                                                            color: AppThemeData.grey300,
                                                                          ),
                                                                        ),
                                                                      ),

                                                                    if (!Constant.isRestaurantOpen(restaurant))
                                                                      ColorFiltered(
                                                                        colorFilter: const ColorFilter.matrix(<double>[
                                                                          0.2126,
                                                                          0.7152,
                                                                          0.0722,
                                                                          0,
                                                                          0,
                                                                          0.2126,
                                                                          0.7152,
                                                                          0.0722,
                                                                          0,
                                                                          0,
                                                                          0.2126,
                                                                          0.7152,
                                                                          0.0722,
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          1,
                                                                          0
                                                                        ]),
                                                                        child: CachedNetworkImage(
                                                                          imageUrl: restaurant.coverImage.toString(),
                                                                          height: 150.h,
                                                                          width: 229.w,
                                                                          fit: BoxFit.fill,
                                                                          progressIndicatorBuilder: (context, url, downloadProgress) => Shimmer.fromColors(
                                                                            baseColor: AppThemeData.grey300,
                                                                            highlightColor: AppThemeData.grey200,
                                                                            child: Container(
                                                                              width: 229.w,
                                                                              color: AppThemeData.grey300,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),

                                                                    // ❤️ Favourite Icon
                                                                    Positioned(
                                                                      right: 8,
                                                                      top: 8,
                                                                      child: GestureDetector(
                                                                        onTap: () async {
                                                                          if (FireStoreUtils.getCurrentUid() != null) {
                                                                            if (isLiked) {
                                                                              restaurant.likedUser!.remove(FireStoreUtils.getCurrentUid());
                                                                            } else {
                                                                              restaurant.likedUser!.add(FireStoreUtils.getCurrentUid());
                                                                            }
                                                                            await FireStoreUtils.updateRestaurant(restaurant);
                                                                            controller.top5RestaurantList.refresh();
                                                                          } else {
                                                                            showDialog(
                                                                              context: context,
                                                                              builder: (context) => Dialog(child: LoginDialog()),
                                                                            );
                                                                          }
                                                                        },
                                                                        child: isLiked
                                                                            ? SvgPicture.asset("assets/icons/ic_fill_favourite.svg")
                                                                            : SvgPicture.asset(
                                                                                "assets/icons/ic_favorite.svg",
                                                                                color: AppThemeData.primaryWhite,
                                                                              ),
                                                                      ),
                                                                    ),

                                                                    if (!Constant.isRestaurantOpen(restaurant))
                                                                      ClipRRect(
                                                                        borderRadius: BorderRadius.circular(10),
                                                                        child: Container(
                                                                          height: 153.h,
                                                                          // width: 232.w,
                                                                          color: Colors.black.withOpacity(0.45),
                                                                          child: Center(
                                                                            child: Transform.rotate(
                                                                              angle: -0.30,
                                                                              child: Image.asset(
                                                                                "assets/icons/ic_close.png",
                                                                                width: 70,
                                                                                height: 70,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.all(12.0),
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child: TextCustom(
                                                                            title: restaurant.vendorName.toString(),
                                                                            textOverflow: TextOverflow.ellipsis,
                                                                            fontSize: 16,
                                                                            fontFamily: FontFamily.medium,
                                                                            textAlign: TextAlign.start,
                                                                            color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                                          ),
                                                                        ),
                                                                        spaceW(width: 8),
                                                                        SvgPicture.asset("assets/icons/ic_star.svg"),
                                                                        spaceW(width: 4),
                                                                        TextCustom(
                                                                          title: Constant.calculateReview(
                                                                            Constant.safeParse(restaurant.reviewSum),
                                                                            Constant.safeParse(restaurant.reviewCount),
                                                                          ).toStringAsFixed(1),
                                                                          fontSize: 16,
                                                                          fontFamily: FontFamily.medium,
                                                                          color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        SvgPicture.asset(
                                                                          "assets/icons/ic_map_pin.svg",
                                                                          color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                                                        ),
                                                                        spaceW(width: 4),
                                                                        Expanded(
                                                                            child: TextCustom(
                                                                          title: restaurant.address!.address.toString(),
                                                                          maxLine: 1,
                                                                          fontSize: 14,
                                                                          fontFamily: FontFamily.light,
                                                                          textAlign: TextAlign.start,
                                                                          color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        TextCustom(
                                                                          title: restaurant.cuisineName.toString(),
                                                                          maxLine: 1,
                                                                          fontSize: 14,
                                                                          fontFamily: FontFamily.light,
                                                                          color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                          child: TextCustom(
                                                                            title: "|",
                                                                            maxLine: 1,
                                                                            fontSize: 14,
                                                                            fontFamily: FontFamily.light,
                                                                            color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                                                          ),
                                                                        ),
                                                                        TextCustom(
                                                                          title: FireStoreUtils.getCurrentUid() == null
                                                                              ? "${Constant.calculateDistanceInKm(Constant.currentLocation!.location!.latitude!, Constant.currentLocation!.location!.longitude!, restaurant.address!.location!.latitude!, restaurant.address!.location!.longitude!)} km"
                                                                              : "${Constant.calculateDistanceInKm(Constant.userModel!.addAddresses!.first.location!.latitude!, Constant.userModel!.addAddresses!.first.location!.longitude!, restaurant.address!.location!.latitude!, restaurant.address!.location!.longitude!)} km",
                                                                          maxLine: 1,
                                                                          fontSize: 14,
                                                                          fontFamily: FontFamily.light,
                                                                          color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                                                        ),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox();
                                              }),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              if (controller.productList.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    spaceH(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextCustom(
                                            title: "Top-Rated Food".tr,
                                            fontSize: 18,
                                            fontFamily: FontFamily.bold,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Get.to(TopRatedFoodView());
                                            },
                                            child: TextCustom(
                                              title: "View all".tr,
                                              fontSize: 16,
                                              color: AppThemeData.orange300,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    spaceH(height: 16),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: SizedBox(
                                        height: 197.h,
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemCount: controller.productList.length,
                                            itemBuilder: (context, index) {
                                              ProductModel product = controller.productList[index];
                                              bool isLiked = product.likedUser?.contains(FireStoreUtils.getCurrentUid()) ?? false;
                                              return GestureDetector(
                                                onTap: () {
                                                  FireStoreUtils.getRestaurant(product.vendorId.toString()).then((value) {
                                                    if (value != null) {
                                                      Get.to(const RestaurantDetailScreenView(), arguments: {"restaurantModel": value});
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                    margin: const EdgeInsets.only(right: 16),
                                                    height: 197.h,
                                                    width: 139.w,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Stack(
                                                      alignment: Alignment.topRight,
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(12),
                                                              image: DecorationImage(image: NetworkImage(product.productImage.toString()), fit: BoxFit.fill)),
                                                        ),
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(12),
                                                            gradient: LinearGradient(
                                                              begin: Alignment.topCenter,
                                                              end: Alignment.bottomCenter,
                                                              colors: [
                                                                AppThemeData.primaryBlack.withOpacity(0),
                                                                AppThemeData.primaryBlack,
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment.topLeft,
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                TextCustom(
                                                                    title: product.productName.toString(), fontSize: 16, fontFamily: FontFamily.bold, color: AppThemeData.grey50),
                                                                FutureBuilder(
                                                                    future: FireStoreUtils.getRestaurant(product.vendorId.toString()),
                                                                    builder: (context, snapshot) {
                                                                      if (!snapshot.hasData) {
                                                                        return Container();
                                                                      }
                                                                      VendorModel restaurantModel = snapshot.data ?? VendorModel();
                                                                      return TextCustom(
                                                                        title: restaurantModel.vendorName ?? "",
                                                                        color: AppThemeData.grey50,
                                                                        fontSize: 14,
                                                                        fontFamily: FontFamily.light,
                                                                      );
                                                                    }),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: GestureDetector(
                                                              onTap: () async {
                                                                if (FireStoreUtils.getCurrentUid() != null) {
                                                                  if (isLiked) {
                                                                    product.likedUser!.remove(FireStoreUtils.getCurrentUid());
                                                                  } else {
                                                                    product.likedUser!.add(FireStoreUtils.getCurrentUid());
                                                                  }
                                                                  await FireStoreUtils.updateProduct(product);
                                                                  controller.productList.refresh();
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
                                                                      color: AppThemeData.primaryWhite,
                                                                    )),
                                                        ),
                                                      ],
                                                    )),
                                              );
                                            }),
                                      ),
                                    )
                                  ],
                                ),
                              spaceH(height: 24),
                              if (controller.restaurantList.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextCustom(
                                            title: "All Restaurant".tr,
                                            fontSize: 18,
                                            fontFamily: FontFamily.bold,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Get.to(const AllRestaurantScreenView());
                                            },
                                            child: TextCustom(
                                              title: "View all".tr,
                                              fontSize: 16,
                                              color: AppThemeData.orange300,
                                            ),
                                          ),
                                        ],
                                      ),
                                      spaceH(height: 8),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: controller.restaurantList.length < 10 ? controller.restaurantList.length : 10,
                                        itemBuilder: (context, index) {
                                          VendorModel restaurant = controller.restaurantList[index];
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
                                                            Stack(
                                                              children: [
                                                                if (Constant.isRestaurantOpen(restaurant))
                                                                  ClipRRect(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                    child: NetworkImageWidget(
                                                                      imageUrl: restaurant.coverImage.toString(),
                                                                      width: 104.w,
                                                                      height: 116.h,
                                                                      borderRadius: 10,
                                                                      fit: BoxFit.fill,
                                                                    ),
                                                                  ),
                                                                if (!Constant.isRestaurantOpen(restaurant))
                                                                  ClipRRect(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                    child: ColorFiltered(
                                                                      colorFilter: const ColorFilter.matrix([
                                                                        0.2126,
                                                                        0.7152,
                                                                        0.0722,
                                                                        0,
                                                                        0,
                                                                        0.2126,
                                                                        0.7152,
                                                                        0.0722,
                                                                        0,
                                                                        0,
                                                                        0.2126,
                                                                        0.7152,
                                                                        0.0722,
                                                                        0,
                                                                        0,
                                                                        0,
                                                                        0,
                                                                        0,
                                                                        1,
                                                                        0,
                                                                      ]),
                                                                      child: NetworkImageWidget(
                                                                        imageUrl: restaurant.coverImage.toString(),
                                                                        width: 104.w,
                                                                        height: 116.h,
                                                                        borderRadius: 10,
                                                                        fit: BoxFit.fill,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                if (!Constant.isRestaurantOpen(restaurant))
                                                                  ClipRRect(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                    child: Container(
                                                                      width: 104.w,
                                                                      height: 116.h,
                                                                      color: Colors.black.withOpacity(0.45),
                                                                      child: Center(
                                                                        child: Transform.rotate(
                                                                          angle: -0.30,
                                                                          child: Image.asset(
                                                                            "assets/icons/ic_close.png",
                                                                            width: 70,
                                                                            height: 70,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                            spaceW(width: 12),
                                                            SizedBox(
                                                              width: 230.w,
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
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
                                                                        "assets/icons/ic_map_pin.svg",
                                                                        height: 14.h,
                                                                        width: 11.w,
                                                                      ),
                                                                      spaceW(width: 4),
                                                                      Expanded(
                                                                        child: TextCustom(
                                                                          title: restaurant.address!.address.toString(),
                                                                          fontFamily: FontFamily.light,
                                                                          textAlign: TextAlign.start,
                                                                          color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  TextCustom(
                                                                    title: restaurant.cuisineName.toString(),
                                                                    fontFamily: FontFamily.light,
                                                                    color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      SvgPicture.asset("assets/icons/ic_star.svg"),
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
                                                                  )
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
                                                                if (isLiked) {
                                                                  restaurant.likedUser!.remove(FireStoreUtils.getCurrentUid());
                                                                } else {
                                                                  restaurant.likedUser!.add(FireStoreUtils.getCurrentUid());
                                                                }
                                                                await FireStoreUtils.updateRestaurant(restaurant);
                                                                controller.restaurantList.refresh();
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
                                    ],
                                  ),
                                ),
                              Container(
                                  padding: const EdgeInsets.fromLTRB(16, 59, 16, 35),
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors:
                                              themeChange.isDarkTheme() ? [const Color(0xff1B1B21), const Color(0xff1A0B00)] : [const Color(0xffFFFFFF), const Color(0xffFFF1E5)])),
                                  child: TextCustom(
                                    title: "Food You Love, Delivered to You...".tr,
                                    maxLine: 3,
                                    color: themeChange.isDarkTheme() ? AppThemeData.orange500 : AppThemeData.orange100,
                                    fontSize: 32,
                                    textAlign: TextAlign.start,
                                    fontFamily: FontFamily.bold,
                                  ))
                            ],
                          )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final DarkThemeProvider themeChange;

  const CategoryItem({super.key, required this.category, required this.themeChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
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
              imageUrl: category.image.toString(),
              height: 42.h,
              width: 42.h,
              borderRadius: 200,
              fit: BoxFit.cover,
            ),
            spaceW(width: 8),
            TextCustom(
              title: category.categoryName.toString(),
              fontFamily: FontFamily.light,
              color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
            )
          ],
        ),
      ),
    );
  }
}

class BannerView extends StatelessWidget {
  const BannerView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    HomeController controller = Get.put(HomeController());

    return SizedBox(
      height: Responsive.height(22, context),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.bannerList.length,
        itemBuilder: (context, index) {
          BannerModel bannerModel = controller.bannerList[index];
          return Padding(
            padding: EdgeInsets.only(right: index != controller.bannerList.length - 1 ? 16 : 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                fit: BoxFit.fill,
                imageUrl: bannerModel.image.toString(),
                width: Responsive.width(80, context),
                errorWidget: (context, url, error) => Container(
                  height: Responsive.height(22, context),
                  width: Responsive.width(100, context),
                  color: themeChange.isDarkTheme() ? AppThemeData.grey800 : AppThemeData.grey200,
                  child: Image.asset(
                    Constant.placeLogo,
                    height: Responsive.height(22, context),
                    width: Responsive.width(100, context),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
