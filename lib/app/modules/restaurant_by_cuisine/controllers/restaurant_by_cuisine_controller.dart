import 'dart:developer';

import 'package:customer/app/models/cart_model.dart';
import 'package:customer/app/models/cuisine_model.dart';
import 'package:customer/app/models/vendor_model.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/extension/string_extensions.dart';
import 'package:customer/services/database_helper.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class RestaurantByCuisineController extends GetxController {
  RxBool isLoading = true.obs;

  CartDatabaseHelper cartDatabaseHelper = CartDatabaseHelper();
  RxList<CartModel> cartItemsList = <CartModel>[].obs;

  Rx<CuisineModel> cuisineModel = CuisineModel().obs;
  RxList<VendorModel> restaurantList = <VendorModel>[].obs;
  RxList<VendorModel> vegRestaurantList = <VendorModel>[].obs;
  RxList<VendorModel> nonVegRestaurantList = <VendorModel>[].obs;

  var selectedType = 0.obs;

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  Future<void> getArguments() async {
    dynamic arguments = Get.arguments;
    if (arguments != null) {
      cuisineModel.value = arguments['cuisineModel'];
      restaurantList.value = await FireStoreUtils.getRestaurantByCuisine(
        cuisineModel.value.id.toString(),
        latitude: Constant.currentLocation!.location!.latitude!.toDouble(),
        longitude: Constant.currentLocation!.location!.longitude!.toDouble(),
        radiusKm: Constant.restaurantRadius.toDouble(),
      );
      filterRestaurants();
    } else {
      log("Error in fetching restaurant by cuisine");
    }
    getData();
    isLoading.value = false;
  }

  Future<void> getData() async {
    if (FireStoreUtils.getCurrentUid() != null) {
      cartItemsList.value = await cartDatabaseHelper.getAllCartItems(FireStoreUtils.getCurrentUid().toString());
    }
  }

  void filterRestaurants() {
    isLoading.value = true;
    vegRestaurantList.value = restaurantList.where((restaurant) => restaurant.vendorType?.toLowerCase() == "veg" || restaurant.vendorType?.toLowerCase() == "both").toList();

    nonVegRestaurantList.value = restaurantList.where((restaurant) => restaurant.vendorType?.toLowerCase() == "non veg" || restaurant.vendorType?.toLowerCase() == "both").toList();
    isLoading.value = false;
  }

  List<VendorModel> get currentRestaurantList {
    switch (selectedType.value) {
      case 1:
        return vegRestaurantList;
      case 2:
        return nonVegRestaurantList;
      default:
        return restaurantList;
    }
  }

  int getCartItemCount() {
    try {
      return cartItemsList.length;
    } catch (e, stack) {
      log("Error getting cart item count: $e", stackTrace: stack);
      return 0;
    }
  }
}
