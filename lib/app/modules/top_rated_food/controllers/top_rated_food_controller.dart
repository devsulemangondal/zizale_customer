import 'dart:developer' as developer;

import 'package:customer/app/models/cart_model.dart';
import 'package:customer/app/models/product_model.dart';
import 'package:customer/app/models/vendor_model.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/extension/string_extensions.dart';
import 'package:customer/services/database_helper.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class TopRatedFoodController extends GetxController {
  Rx<bool> isLoading = false.obs;
  CartDatabaseHelper cartDatabaseHelper = CartDatabaseHelper();
  RxList<CartModel> cartItemsList = <CartModel>[].obs;
  RxList<ProductModel> productList = <ProductModel>[].obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    if (FireStoreUtils.getCurrentUid() != null) {
      cartItemsList.value = await cartDatabaseHelper.getAllCartItems(FireStoreUtils.getCurrentUid().toString());
    }
    fetchTopRatedProducts();
  }

  Future<void> fetchTopRatedProducts() async {
    isLoading.value = true;

    // Clear existing list if needed
    productList.clear();
    try {
      List<VendorModel> restaurantList = await FireStoreUtils.getAllRestaurant(
        latitude: Constant.currentLocation!.location!.latitude!.toDouble(),
        longitude: Constant.currentLocation!.location!.longitude!.toDouble(),
        radiusKm: Constant.restaurantRadius.toDouble(),
      );

      List<String> nearbyRestaurantIds = restaurantList.map((element) => element.id ?? '').where((id) => id.isNotEmpty).toList();

      // Get all products from Firestore
      List<ProductModel> allProducts = await FireStoreUtils.getProductList();

      List<ProductModel> nearbyProducts = allProducts.where(
        (product) {
          return nearbyRestaurantIds.contains(product.vendorId);
        },
      ).toList();

      // Filter only those with valid ratings
      List<ProductModel> ratedProducts = nearbyProducts.where((product) {
        double reviewCount = double.tryParse(product.reviewCount ?? '0') ?? 0;
        double reviewSum = double.tryParse(product.reviewSum ?? '0') ?? 0;
        return reviewCount > 0 && reviewSum > 0;
      }).toList();

      // Sort by average rating (high to low)
      ratedProducts.sort((a, b) {
        double ratingA = (double.tryParse(a.reviewSum ?? '0') ?? 0) / (double.tryParse(a.reviewCount ?? '1') ?? 1);
        double ratingB = (double.tryParse(b.reviewSum ?? '0') ?? 0) / (double.tryParse(b.reviewCount ?? '1') ?? 1);
        return ratingB.compareTo(ratingA);
      });

      // Get top 10 rated items (you can change the number)
      productList.assignAll(ratedProducts.take(10));
    } catch (e) {
      debugPrint("❌ Error fetching top-rated nearby products: $e");
    } finally {
      isLoading.value = false;
      update();
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
