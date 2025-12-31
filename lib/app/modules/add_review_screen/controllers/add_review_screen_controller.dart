
import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/models/product_model.dart';
import 'package:customer/app/models/vendor_model.dart';
import 'package:customer/app/models/review_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddReviewScreenController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isAlreadyAddReview = true.obs;
  RxDouble rating = 0.0.obs;
  Rx<TextEditingController> reviewController = TextEditingController().obs;

  Rx<OrderModel> bookingModel = OrderModel().obs;
  Rx<ReviewModel> reviewModel = ReviewModel().obs;
  Rx<VendorModel> restaurantModel = VendorModel().obs;
  RxList<ProductModel> productList = <ProductModel>[].obs;

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
    await FireStoreUtils.getRestaurant(bookingModel.value.vendorId.toString()).then((value) {
      if (value != null) {
        restaurantModel.value = value;
      }
    });
    await FireStoreUtils.getRestaurantReview(bookingModel.value.id.toString()).then((value) {
      if (value != null) {
        isAlreadyAddReview.value = true;
        reviewModel.value = value;
        rating.value = double.parse(reviewModel.value.rating.toString());
        reviewController.value.text = reviewModel.value.comment.toString();
      }
    });

    for (var item in bookingModel.value.items!) {
      final product = await FireStoreUtils.getProductByID(item.productId.toString());

      if (product != null) {
        productList.add(product);
      }
    }

    isLoading.value = false;
  }
}
