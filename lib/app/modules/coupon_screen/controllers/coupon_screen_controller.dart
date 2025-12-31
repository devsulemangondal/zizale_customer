// ignore_for_file: depend_on_referenced_packages

import 'dart:developer' as developer;

import 'package:customer/app/models/coupon_model.dart';
import 'package:customer/app/modules/my_cart/controllers/my_cart_controller.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CouponScreenController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<CouponModel> couponList = <CouponModel>[].obs;
  Rx<TextEditingController> couponCodeController = TextEditingController().obs;
  Rx<CouponModel> couponModel = CouponModel().obs;

  @override
  void onInit() {
    getCouponList();
    super.onInit();
  }

  Future<void> getCouponList() async {
    await FireStoreUtils.getCoupon().then((value) {
      couponList.value = value;
      isLoading.value = false;
        });
  }
  Future<void> validateCoupon(String code) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(CollectionName.coupon)
          .where("code", isEqualTo: code)
          .where("active", isEqualTo: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ShowToastDialog.showToast("Coupon not found.".tr);
        return;
      }

      final data = querySnapshot.docs.first.data();
      final coupon = CouponModel.fromJson(data);

      if (coupon.expireAt != null && coupon.expireAt!.toDate().isBefore(DateTime.now())) {
        ShowToastDialog.showToast("This coupon is expired.".tr);
        throw Exception("This coupon is expired.");
      }

      couponModel.value = coupon;
      // ShowToastDialog.showToast("Coupon applied successfully!");
      MyCartController cartController = Get.put(MyCartController());
      if (double.parse(cartController.calculateItemTotal().toString()) < double.parse(couponModel.value.minAmount.toString())) {
        ShowToastDialog.showToast("minimum_amount".trParams({'amount': Constant.amountShow(amount: couponModel.value.minAmount)}));
        return;
      }
      cartController.selectedCoupon.value = couponModel.value;
      cartController.couponCode.value = cartController.selectedCoupon.value.code.toString();
      if (couponModel.value.isFix == true) {
        cartController.couponAmount.value = double.parse(couponModel.value.amount.toString());
      } else {
        cartController.couponAmount.value =
            double.parse(cartController.calculateItemTotal().toString()) * double.parse(couponModel.value.amount.toString()) / 100;
      }
      Get.back();
    } catch (e) {
      developer.log("Error validateCoupon : $e");
    }
  }

}

