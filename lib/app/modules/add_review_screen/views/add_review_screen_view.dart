// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/models/product_model.dart';
import 'package:customer/app/models/vendor_model.dart';
import 'package:customer/app/modules/add_review_screen/controllers/add_review_screen_controller.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/network_image_widget.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/constant_widgets/login_dialog.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../themes/common_ui.dart';

class AddReviewScreenView extends GetView<AddReviewScreenController> {
  const AddReviewScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<AddReviewScreenController>(
        init: AddReviewScreenController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
            appBar: UiInterface.customAppBar(context, themeChange, "", backgroundColor: Colors.transparent),
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: Column(
                    children: [
                      FutureBuilder(
                          future: FireStoreUtils.getRestaurant(controller.bookingModel.value.vendorId.toString()),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }
                            VendorModel restaurantModel = snapshot.data ?? VendorModel();
                            return NetworkImageWidget(
                              imageUrl: restaurantModel.coverImage.toString(),
                              height: 70.h,
                              width: 70.w,
                              borderRadius: 50,
                            );
                          }),
                      spaceH(height: 16),
                      TextCustom(
                        title: "Rate Your Experience".tr,
                        fontSize: 18,
                        fontFamily: FontFamily.bold,
                        color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                      ),
                      spaceH(height: 4),
                      TextCustom(
                        title: "Rate the restaurant, dish, and driver to help others make informed decisions.".tr,
                        fontSize: 14,
                        maxLine: 3,
                        fontFamily: FontFamily.light,
                        color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                      ),
                      spaceH(height: 24),
                      RatingBar.builder(
                          glow: true,
                          initialRating: controller.rating.value,
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemSize: 40,
                          itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                          itemBuilder: (context, _) => const Icon(Icons.star, color: AppThemeData.pending300),
                          onRatingUpdate: (rating) {
                            controller.rating(rating);
                          }),
                      spaceH(height: 24),
                      TextFormField(
                        textAlign: TextAlign.start,
                        cursorColor: AppThemeData.orange300,
                        controller: controller.reviewController.value,
                        style: TextStyle(
                            //color: AppColors.grey800,
                            color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800,
                            fontFamily: FontFamily.regular,
                            fontSize: 16),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppThemeData.orange300)),
                            enabledBorder:
                                OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400)),
                            hintText: "Leave Review".tr,
                            hintStyle: TextStyle(fontSize: 16, fontFamily: FontFamily.light, color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: RoundShapeButton(
                  title: "Submit".tr,
                  buttonColor: AppThemeData.orange300,
                  buttonTextColor: AppThemeData.primaryWhite,
                  onTap: () async {
                    if (FireStoreUtils.getCurrentUid() != null) {
                      ShowToastDialog.showLoader("Please Wait..".tr);
                      await FireStoreUtils.getRestaurant(controller.bookingModel.value.vendorId.toString()).then((value) async {
                        if (value != null) {
                          VendorModel restaurantModel = value;
                          if (controller.reviewModel.value.id != null) {
                            restaurantModel.reviewSum = (double.parse(restaurantModel.reviewSum.toString()) - double.parse(controller.reviewModel.value.rating.toString())).toString();

                            restaurantModel.reviewCount = (double.parse(restaurantModel.reviewCount.toString()) - 1).toString();
                          }
                          restaurantModel.reviewSum = (double.parse(restaurantModel.reviewSum.toString()) + double.parse(controller.rating.value.toString())).toString();
                          restaurantModel.reviewCount = (double.parse(restaurantModel.reviewCount.toString()) + 1).toString();
                          await FireStoreUtils.updateRestaurant(restaurantModel);
                        }
                      });
                      if (controller.reviewModel.value.id != null) {
                        for (var product in controller.productList) {
                          product.reviewSum = (double.parse(product.reviewSum.toString()) + double.parse(controller.rating.value.toString())).toString();
                          product.reviewCount = (double.parse(product.reviewCount.toString()) - 1).toString();
                          bool success = await FireStoreUtils.updateProduct(product);
                          if (!success) {}
                        }
                      } else {
                        for (var product in controller.productList) {
                          ProductModel productModel;
                          productModel = product;

                          productModel.reviewSum = (double.parse(productModel.reviewSum.toString()) + double.parse(controller.rating.value.toString())).toString();
                          productModel.reviewCount = (double.parse(productModel.reviewCount.toString()) + 1).toString();
                          bool success = await FireStoreUtils.updateProduct(product);
                          if (!success) {}
                        }
                      }

                      controller.reviewModel.value.id = controller.bookingModel.value.id;
                      controller.reviewModel.value.rating = controller.rating.value.toString();
                      controller.reviewModel.value.customerId = FireStoreUtils.getCurrentUid();
                      controller.reviewModel.value.vendorId = controller.bookingModel.value.vendorId;
                      controller.reviewModel.value.comment = controller.reviewController.value.text;
                      controller.reviewModel.value.orderId = controller.bookingModel.value.id;
                      controller.reviewModel.value.type = Constant.restaurant;
                      controller.reviewModel.value.date = Timestamp.now();

                      await FireStoreUtils.setReview(controller.reviewModel.value).then((value) {
                        if (value == true) {
                          ShowToastDialog.closeLoader();
                          ShowToastDialog.showToast("Review submit successfully".tr);
                          Get.back();
                        }
                      });
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
                  size: const Size(0, 58)),
            ),
          );
        });
  }
}
