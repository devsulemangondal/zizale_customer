import 'dart:developer' as developer;

import 'package:customer/app/models/cart_model.dart';
import 'package:customer/app/models/vendor_model.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/extension/string_extensions.dart';
import 'package:customer/services/database_helper.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class AllRestaurantScreenController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<VendorModel> allRestaurantList = <VendorModel>[].obs;
  RxList<VendorModel> vegRestaurantList = <VendorModel>[].obs;
  RxList<VendorModel> nonVegRestaurantList = <VendorModel>[].obs;
  RxList<VendorModel> topRatedRestaurantList = <VendorModel>[].obs;
  Rx<VendorModel> restaurantModel = VendorModel().obs;
  var selectedType = 0.obs;

  CartDatabaseHelper cartDatabaseHelper = CartDatabaseHelper();
  RxList<CartModel> cartItemsList = <CartModel>[].obs;

  @override
  void onInit() {
    getData(isAllRestaurantFetch: true, isVegRestaurantFetch: true, isNonVegRestaurantFetch: true, isTopRatedRestaurantFetch: true);
    super.onInit();
  }

  Future<void> getData(
      {required bool isAllRestaurantFetch, required bool isVegRestaurantFetch, required bool isNonVegRestaurantFetch, required bool isTopRatedRestaurantFetch}) async {
    if (isAllRestaurantFetch) {
      allRestaurantList.value = await FireStoreUtils.getAllRestaurant(
        latitude: Constant.currentLocation!.location!.latitude!.toDouble(),
        longitude: Constant.currentLocation!.location!.longitude!.toDouble(),
        radiusKm: Constant.restaurantRadius.toDouble(),
      );
    }

    if (isVegRestaurantFetch) {
      vegRestaurantList.value = await FireStoreUtils.getVegRestaurant(
        latitude: Constant.currentLocation!.location!.latitude!.toDouble(),
        longitude: Constant.currentLocation!.location!.longitude!.toDouble(),
        radius: Constant.restaurantRadius.toDouble(),
      );
    }

    if (isNonVegRestaurantFetch) {
      nonVegRestaurantList.value = await FireStoreUtils.getNonVegRestaurant(
        latitude: Constant.currentLocation!.location!.latitude!.toDouble(),
        longitude: Constant.currentLocation!.location!.longitude!.toDouble(),
        radius: Constant.restaurantRadius.toDouble(),
      );
    }

    if (isTopRatedRestaurantFetch) {
      topRatedRestaurants();
    }
    sortRestaurantList(allRestaurantList);
    sortRestaurantList(vegRestaurantList);
    sortRestaurantList(nonVegRestaurantList);
    sortRestaurantList(topRatedRestaurantList);

    isLoading.value = false;
  }

  void sortRestaurantList(RxList<VendorModel> list) {
    list.sort((a, b) {
      bool aOpen = Constant.isRestaurantOpen(a);
      bool bOpen = Constant.isRestaurantOpen(b);

      if (aOpen && !bOpen) return -1; // a first
      if (!aOpen && bOpen) return 1; // b first
      return 0; // keep normal order
    });
  }

  Future<void> topRatedRestaurants() async {
    topRatedRestaurantList.clear();

    if (allRestaurantList.isEmpty) {
      return;
    }

    List<VendorModel> validRestaurants = allRestaurantList.where((restaurant) {
      final reviewCount = double.tryParse(restaurant.reviewCount?.toString() ?? '0') ?? 0;
      final reviewSum = double.tryParse(restaurant.reviewSum?.toString() ?? '0') ?? 0.0;
      return reviewCount > 0 && reviewSum > 0;
    }).toList();

    validRestaurants.sort((a, b) {
      final aCount = double.tryParse(a.reviewCount?.toString() ?? '0') ?? 0;
      final bCount = double.tryParse(b.reviewCount?.toString() ?? '0') ?? 0;

      final aSum = double.tryParse(a.reviewSum?.toString() ?? '0') ?? 0.0;
      final bSum = double.tryParse(b.reviewSum?.toString() ?? '0') ?? 0.0;

      final aAvg = aCount > 0 ? (aSum / aCount) : 0.0;
      final bAvg = bCount > 0 ? (bSum / bCount) : 0.0;

      return bAvg.compareTo(aAvg);
    });

    topRatedRestaurantList.value = validRestaurants;

    /// ⭐ sort by open vs closed
    sortRestaurantList(topRatedRestaurantList);
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
