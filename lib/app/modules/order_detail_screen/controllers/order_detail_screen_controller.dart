import 'dart:developer' as developer;
import 'dart:developer';

import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/models/driver_user_model.dart';
import 'package:customer/app/models/review_model.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class OrderDetailScreenController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<OrderModel> bookingModel = OrderModel().obs;
  Rx<ReviewModel> reviewModel = ReviewModel().obs;
  Rx<DriverUserModel> driverModel = DriverUserModel().obs;

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  Future<void> getArguments() async {
    try {
      dynamic argumentData = Get.arguments;
      if (argumentData != null) {
        bookingModel.value = argumentData["bookingModel"];
        await getDriver();
        await getReview();
      }
    } catch (e, stack) {
      developer.log("Error getting arguments: ", error: e, stackTrace: stack);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getReview() async {
    try {
      final value = await FireStoreUtils.getRestaurantReview(bookingModel.value.id.toString());
      if (value != null) {
        reviewModel.value = value;
      }
    } catch (e, stack) {
      developer.log("Error getting review: ", error: e, stackTrace: stack);
    }
  }

  Future<void> getDriver() async {
    try {
      final value = await FireStoreUtils.getDriverUserProfile(bookingModel.value.driverId.toString());
      if (value != null) {
        driverModel.value = value;
      }
    } catch (e, stack) {
      developer.log("Error getting driver info: ", error: e, stackTrace: stack);
    }
  }

  RxDouble restaurantTaxAmount = 0.0.obs;
  RxDouble packagingTaxAmount = 0.0.obs;
  RxDouble deliveryTaxAmount = 0.0.obs;

  double getTotalTax() {
    // RESTAURANT TAX
    for (var element in (bookingModel.value.taxList ?? [])) {
      restaurantTaxAmount.value += Constant.calculateTax(
        amount: ((double.parse(bookingModel.value.subTotal ?? '0.0')) - double.parse((bookingModel.value.discount ?? '0.0').toString())).toString(),
        taxModel: element,
      );
    }

    // DELIVERY TAX
    for (var element in (bookingModel.value.deliveryTaxList ?? [])) {
      deliveryTaxAmount.value += Constant.calculateTax(
        amount: bookingModel.value.deliveryCharge.toString(),
        taxModel: element,
      );
    }

    // PACKAGING TAX
    for (var element in (bookingModel.value.packagingTaxList ?? [])) {
      packagingTaxAmount.value += Constant.calculateTax(
        amount: bookingModel.value.packagingFee.toString(),
        taxModel: element,
      );
    }
    log("Restaurant Tax: ${restaurantTaxAmount.value}");
    log("Packaging Tax: ${packagingTaxAmount.value}");
    log("Delivery Tax: ${deliveryTaxAmount.value}");


    return restaurantTaxAmount.value + packagingTaxAmount.value + deliveryTaxAmount.value;
  }
}
