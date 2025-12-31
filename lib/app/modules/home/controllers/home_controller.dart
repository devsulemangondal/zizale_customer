import 'dart:async';
import 'dart:developer' as developer;

import 'package:customer/app/models/add_address_model.dart';
import 'package:customer/app/models/banner_model.dart';
import 'package:customer/app/models/cart_model.dart';
import 'package:customer/app/models/category_model.dart';
import 'package:customer/app/models/cuisine_model.dart';
import 'package:customer/app/models/product_model.dart';
import 'package:customer/app/models/vendor_model.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/extension/string_extensions.dart';
import 'package:customer/services/database_helper.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  Rx<bool> isLoading = false.obs;
  RxList<BannerModel> bannerList = <BannerModel>[].obs;

  RxList<ProductModel> productList = <ProductModel>[].obs;
  RxList<VendorModel> restaurantList = <VendorModel>[].obs;
  RxList<VendorModel> top5RestaurantList = <VendorModel>[].obs;
  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  Rx<AddAddressModel> selectedAddress = AddAddressModel().obs;
  Rx<TextEditingController> searchController = TextEditingController().obs;
  RxList<ProductModel> searchProductList = <ProductModel>[].obs;
  CartDatabaseHelper cartDatabaseHelper = CartDatabaseHelper();
  RxList<CartModel> cartItemsList = <CartModel>[].obs;
  RxList<CuisineModel> cuisineList = <CuisineModel>[].obs;

  final List<Color> colors = [
    const Color(0xff3232AA),
    const Color(0xff1E955E),
    const Color(0xff007F90),
  ];

  final List<String> svgPaths = [
    "assets/images/banner.svg",
    "assets/images/banner_1.svg",
    "assets/images/banner_2.svg",
  ];

  @override
  void onInit() {
    getData();
    if (Constant.currentLocation != null) {
      selectedAddress.value = Constant.currentLocation!;
    }
    super.onInit();
  }

  Future<void> getData() async {
    try {
      isLoading.value = true;
      categoryList.clear();
      restaurantList.clear();
      cuisineList.clear();

      await getLocation();

      bannerList.value = await FireStoreUtils.getBannerList();
      categoryList.addAll(await FireStoreUtils.getCategoryList());
      cuisineList.addAll(await FireStoreUtils.getCuisineList());

      if (FireStoreUtils.getCurrentUid() != null) {
        cartItemsList.value = await cartDatabaseHelper.getAllCartItems(FireStoreUtils.getCurrentUid().toString());
      }

      await getNearbyRestaurant();
      fetchTop5Restaurants();
      fetchTopRatedProducts();
      await searchFoodNearby();
      isLoading.value = false;

      update();
    } catch (e, stack) {
      developer.log("❌ Error in getData: $e", stackTrace: stack);
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

  Future<void> fetchTop5Restaurants() async {
    top5RestaurantList.clear();

    if (restaurantList.isEmpty) {
      top5RestaurantList.clear();
      return;
    }

    List<VendorModel> validRestaurants = restaurantList.where((restaurant) {
      final reviewCount = double.tryParse(restaurant.reviewCount?.toString() ?? '0') ?? 0;
      return reviewCount > 0;
    }).toList();

    validRestaurants.sort((a, b) {
      final aCount = double.tryParse(a.reviewCount?.toString() ?? '0') ?? 0;
      final bCount = double.tryParse(b.reviewCount?.toString() ?? '0') ?? 0;

      final aSum = double.tryParse(a.reviewSum?.toString() ?? '0') ?? 0.0;
      final bSum = double.tryParse(b.reviewSum?.toString() ?? '0') ?? 0.0;

      final aAvg = aCount > 0 ? (aSum / aCount) : 0.0;
      final bAvg = bCount > 0 ? (bSum / bCount) : 0.0;

      return bAvg.compareTo(aAvg); // Descending order
    });

    List<VendorModel> top5 = validRestaurants.take(5).toList();

    if (top5.length < 5) {
      List<VendorModel> remaining = restaurantList.where((r) => !validRestaurants.contains(r)).take(5 - top5.length).toList();

      top5.addAll(remaining);
    }

    top5RestaurantList.value = top5;
  }

  Future<void> fetchTopRatedProducts() async {
    isLoading.value = true;

    productList.clear();
    try {
      List<String> nearbyRestaurantIds = restaurantList.map((element) => element.id ?? '').where((id) => id.isNotEmpty).toList();

      List<ProductModel> allProducts = await FireStoreUtils.getProductList();

      List<ProductModel> nearbyProducts = allProducts.where(
        (product) {
          return nearbyRestaurantIds.contains(product.vendorId);
        },
      ).toList();

      List<ProductModel> ratedProducts = nearbyProducts.where((product) {
        double reviewCount = double.tryParse(product.reviewCount ?? '0') ?? 0;
        double reviewSum = double.tryParse(product.reviewSum ?? '0') ?? 0;
        return reviewCount > 0 && reviewSum > 0;
      }).toList();

      ratedProducts.sort((a, b) {
        double ratingA = (double.tryParse(a.reviewSum ?? '0') ?? 0) / (double.tryParse(a.reviewCount ?? '1') ?? 1);
        double ratingB = (double.tryParse(b.reviewSum ?? '0') ?? 0) / (double.tryParse(b.reviewCount ?? '1') ?? 1);
        return ratingB.compareTo(ratingA);
      });

      productList.assignAll(ratedProducts.take(10));
    } catch (e) {
      debugPrint("❌ Error fetching top-rated nearby products: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> getNearbyRestaurant() async {
    isLoading.value = true;

    try {
      restaurantList.value = await FireStoreUtils.getAllRestaurant(
          latitude: selectedAddress.value.location!.latitude!.toDouble(),
          longitude: selectedAddress.value.location!.longitude!.toDouble(),
          radiusKm: Constant.restaurantRadius.toDouble());
      sortRestaurantsByOpenStatus();

      restaurantList.refresh();
    } finally {
      isLoading.value = false;
    }
  }

  void sortRestaurantsByOpenStatus() {
    restaurantList.sort((a, b) {
      bool aOpen = Constant.isRestaurantOpen(a);
      bool bOpen = Constant.isRestaurantOpen(b);

      if (aOpen == bOpen) return 0;
      return aOpen ? -1 : 1;
    });

    restaurantList.refresh();
  }

  Future<void> searchFoodNearby() async {
    final query = searchController.value.text.trim().toLowerCase();
    if (query.isEmpty) {
      searchProductList.clear();
      return;
    }

    isLoading.value = true;

    try {
      List<String> vendorIds = restaurantList.map((e) => e.id ?? "").where((id) => id.isNotEmpty).toList();

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

  Future<void> getLocation() async {
    try {
      if (FireStoreUtils.getCurrentUid() != null && Constant.userModel != null && Constant.userModel!.addAddresses != null && Constant.userModel!.addAddresses!.isNotEmpty) {
        selectedAddress.value = Constant.userModel!.addAddresses!.firstWhere(
          (element) => element.isDefault == true,
          orElse: () => Constant.userModel!.addAddresses!.first,
        );
        Constant.currentLocation = selectedAddress.value;
      }

      if (Constant.currentLocation?.location == null) {
        developer.log("⚠️ No valid location found, skipping zone check.");
        return;
      }

      Constant.country = (await placemarkFromCoordinates(
            Constant.currentLocation!.location!.latitude!,
            Constant.currentLocation!.location!.longitude!,
          ))[0]
              .country ??
          'Unknown';

      await Constant.checkZoneAvailability(Constant.currentLocation!.location!);

      if (Constant.isZoneAvailable) {
        await getNearbyRestaurant();
      } else {
        restaurantList.clear();
      }

      update();
    } catch (e, stack) {
      developer.log("❌ Error in getLocation (HomeController)", error: e, stackTrace: stack);
    }
  }
}
