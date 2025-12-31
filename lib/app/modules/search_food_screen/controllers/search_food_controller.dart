import 'dart:developer' as developer;
import 'package:customer/app/models/cart_model.dart';
import 'package:customer/app/models/product_model.dart';
import 'package:customer/app/models/vendor_model.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/extension/string_extensions.dart';
import 'package:customer/services/database_helper.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchFoodScreenController extends GetxController {
  CartDatabaseHelper cartDatabaseHelper = CartDatabaseHelper();
  RxList<CartModel> cartItemsList = <CartModel>[].obs;
  Rx<TextEditingController> searchController = TextEditingController().obs;

  RxBool isLoading = false.obs;
  RxList<VendorModel> restaurants = <VendorModel>[].obs;

  RxInt selectedType = 0.obs;

  RxList<ProductModel> searchProductList = <ProductModel>[].obs;
  RxList<VendorModel> searchRestaurantList = <VendorModel>[].obs;

  @override
  void onInit() {
    getCartItems();
    super.onInit();
  }

  Future<void> getCartItems() async {
    if (FireStoreUtils.getCurrentUid() != null) {
      cartItemsList.value = await cartDatabaseHelper.getAllCartItems(FireStoreUtils.getCurrentUid().toString());
    }
  }

  Future<void> searchRestaurant({required double latitude, required double longitude, required double radius}) async {
    final query = searchController.value.text.trim().toLowerCase();
    if (query.isEmpty) {
      searchRestaurantList.clear();
      return;
    }

    isLoading.value = true;

    try {
      restaurants.value = await FireStoreUtils.getAllRestaurant(latitude: latitude, longitude: longitude, radiusKm: Constant.restaurantRadius.toDouble());

      List<VendorModel> filteredRestaurant = restaurants.where((restaurant) {
        final keyWords = (restaurant.searchKeywords ?? []).map((e) => e.toString().toLowerCase()).toList();
        return keyWords.any((keyword) => keyword.contains(query));
      }).toList();

      searchRestaurantList.assignAll(filteredRestaurant);

      List<String> vendorIds = restaurants.map((e) => e.id ?? "").where((id) => id.isNotEmpty).toList();

      List<ProductModel> productList = await FireStoreUtils.getProductsFromVendorsWithSearch(
        vendorIds: vendorIds,
        query: query,
      );

      searchProductList.assignAll(productList);
    } catch (e, stack) {
      developer.log("Error searching food nearby: $e", error: e, stackTrace: stack);
    } finally {
      isLoading.value = false;
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
