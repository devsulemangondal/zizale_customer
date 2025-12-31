// ignore_for_file: deprecated_member_use

import 'package:customer/app/models/product_model.dart';
import 'package:customer/app/models/vendor_model.dart';
import 'package:customer/app/modules/restaurant_detail_screen/views/restaurant_detail_screen_view.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/login_dialog.dart';
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

import '../controllers/top_rated_food_controller.dart';

class TopRatedFoodView extends GetView<TopRatedFoodController> {
  const TopRatedFoodView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: TopRatedFoodController(),
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
                      buildTopWidget(context, "Top Rated Dishes".tr, "Discover the most loved dishes, rated highly by our foodies.".tr),
                      spaceH(height: 32),
                      controller.isLoading.value
                          ? Constant.loader()
                          : GridView.builder(
                              shrinkWrap: true,
                              primary: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.productList.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, mainAxisExtent: 180),
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
                                      height: 197.h,
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
                                                  TextCustom(title: product.productName.toString(), fontSize: 16, fontFamily: FontFamily.bold, color: AppThemeData.grey50),
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
                              })
                    ],
                  ),
                ),
              )),
        );
      },
    );
  }
}
