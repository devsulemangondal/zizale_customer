import 'dart:developer' as developer;

import 'package:customer/app/models/cart_model.dart';
import 'package:customer/app/models/cuisine_model.dart';
import 'package:customer/services/database_helper.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class CuisineScreenController extends GetxController {
  RxList<CuisineModel> cuisineList = <CuisineModel>[].obs;
  CartDatabaseHelper cartDatabaseHelper = CartDatabaseHelper();
  RxList<CartModel> cartItemsList = <CartModel>[].obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    await FireStoreUtils.getCuisineList().then((value) {
      cuisineList.addAll(value);
    });

    if (FireStoreUtils.getCurrentUid() != null) {
      cartItemsList.value = await cartDatabaseHelper.getAllCartItems(FireStoreUtils.getCurrentUid().toString());
    }
  }

  int getCartItemCount() {
    try {
      return cartItemsList.length;
    } catch (e, stack) {
      developer.log("Error getting cart item count: $e", stackTrace: stack);
      return 0;
    }
  }
}
