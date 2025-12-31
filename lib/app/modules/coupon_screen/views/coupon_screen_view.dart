import 'dart:developer' as developer;

import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:customer/app/models/coupon_model.dart';
import 'package:customer/app/modules/coupon_screen/controllers/coupon_screen_controller.dart';
import 'package:customer/app/modules/my_cart/controllers/my_cart_controller.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/text_field_widget.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/constant_widgets/top_widget.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/common_ui.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CouponScreenView extends GetView {
  const CouponScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<CouponScreenController>(
      init: CouponScreenController(),
      builder: (controller) {
        return Scaffold(
          appBar: UiInterface.customAppBar(context, themeChange, "", backgroundColor: Colors.transparent),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTopWidget(context, "Coupons", "Apply your coupons here to enjoy exclusive discounts and savings on your favorite meals!"),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextFieldWidget(
                          title: "Add Your Coupon Code".tr,
                          controller: controller.couponCodeController.value,
                          onPress: () {},
                          hintText: "Add Your Coupon Code".tr,
                        ),
                      ),
                      spaceW(),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: RoundShapeButton(
                              title: "Apply".tr,
                              buttonColor: AppThemeData.orange300,
                              buttonTextColor: AppThemeData.primaryWhite,
                              onTap: () async {
                                final code = controller.couponCodeController.value.text.trim();

                                if (code.isEmpty) {
                                  ShowToastDialog.showToast("Please enter a coupon code.".tr);
                                  return;
                                }

                                try {
                                  await controller.validateCoupon(code);
                                } catch (e) {
                                  developer.log("Error CouponScreenView : $e");
                                }
                              },
                              size: const Size(0, 52)),
                        ),
                      ),
                    ],
                  ),
                  spaceH(height: 32),
                  controller.isLoading.value
                      ? Constant.loader()
                      : controller.couponList.isEmpty
                          ? Constant.showEmptyView(context, message: "No Coupons Available".tr)
                          : ListView.builder(
                              shrinkWrap: true,
                              reverse: true,
                              itemCount: controller.couponList.length,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                CouponModel couponModel = controller.couponList[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: CouponCard(
                                      height: 152.h,
                                      curveAxis: Axis.vertical,
                                      firstChild: Container(
                                        width: 93.w,
                                        decoration: BoxDecoration(color: themeChange.isDarkTheme() ? AppThemeData.success500 : AppThemeData.success100),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              child: Column(
                                                children: [
                                                  TextCustom(
                                                    title: couponModel.isFix == true ? Constant.amountShow(amount: couponModel.amount) : "${couponModel.amount}%",
                                                    fontSize: 20,
                                                    fontFamily: FontFamily.bold,
                                                    color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                  ),
                                                  TextCustom(
                                                    title: "Discount".tr,
                                                    fontSize: 14,
                                                    fontFamily: FontFamily.light,
                                                    color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      secondChild: Container(
                                        width: double.maxFinite,
                                        decoration: BoxDecoration(color: themeChange.isDarkTheme() ? AppThemeData.surface1000 : AppThemeData.surface50),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: TextCustom(
                                                      title: couponModel.code.toString(),
                                                      fontSize: 16,
                                                      fontFamily: FontFamily.bold,
                                                      textAlign: TextAlign.start,
                                                      color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      MyCartController cartController = Get.put(MyCartController());
                                                      if (double.parse(cartController.calculateItemTotal().toString()) < double.parse(couponModel.minAmount.toString())) {
                                                        ShowToastDialog.showToast("minimum_amount".trParams({'amount': Constant.amountShow(amount: couponModel.minAmount)}));
                                                        return;
                                                      }
                                                      cartController.selectedCoupon.value = couponModel;
                                                      cartController.couponCode.value = cartController.selectedCoupon.value.code.toString();
                                                      if (couponModel.isFix == true) {
                                                        cartController.couponAmount.value = double.parse(couponModel.amount.toString());
                                                      } else {
                                                        cartController.couponAmount.value =
                                                            double.parse(cartController.calculateItemTotal().toString()) * double.parse(couponModel.amount.toString()) / 100;
                                                      }
                                                      Get.back();
                                                    },
                                                    child: TextCustom(
                                                      title: "Apply".tr,
                                                      fontSize: 16,
                                                      fontFamily: FontFamily.bold,
                                                      color: AppThemeData.orange300,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              spaceH(height: 4),
                                              TextCustom(
                                                title: couponModel.title.toString(),
                                                fontSize: 14,
                                                fontFamily: FontFamily.light,
                                                maxLine: 3,
                                                textAlign: TextAlign.start,
                                                color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                                );
                              },
                            )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
