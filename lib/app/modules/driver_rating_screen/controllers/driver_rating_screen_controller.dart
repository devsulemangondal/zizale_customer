import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/models/driver_user_model.dart';
import 'package:customer/app/models/review_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverRatingScreenController extends GetxController{
  RxBool isLoading = false.obs;
  RxBool isAlreadyAddReview = true.obs;

  Rx<TextEditingController> reviewController = TextEditingController().obs;

  Rx<OrderModel> bookingModel = OrderModel().obs;
  Rx<ReviewModel> reviewModel = ReviewModel().obs;
  Rx<DriverUserModel> driverModel = DriverUserModel().obs;

  RxDouble rating = 0.0.obs;

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  Future<void> getArguments() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      bookingModel.value = argumentData["bookingModel"];
    }
    await FireStoreUtils.getDriverUserProfile(bookingModel.value.driverId.toString()).then((value) {
      if (value != null) {
        driverModel.value = value;
      }
    });
    await FireStoreUtils.getDriverReview(bookingModel.value.id.toString()).then((value) {
      if (value != null) {
        isAlreadyAddReview.value = true;
        reviewModel.value = value;
        rating.value = double.parse(reviewModel.value.rating.toString());
        reviewController.value.text = reviewModel.value.comment.toString();
      }
    });

    isLoading.value = false;
  }
}