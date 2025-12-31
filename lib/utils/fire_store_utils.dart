// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/models/admin_commission.dart';
import 'package:customer/app/models/bank_detail_model.dart';
import 'package:customer/app/models/banner_model.dart';
import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/models/category_model.dart';
import 'package:customer/app/models/coupon_model.dart';
import 'package:customer/app/models/cuisine_model.dart';
import 'package:customer/app/models/driver_user_model.dart';
import 'package:customer/app/models/global_value_model.dart';
import 'package:customer/app/models/language_model.dart';
import 'package:customer/app/models/notification_model.dart';
import 'package:customer/app/models/onboarding_model.dart';
import 'package:customer/app/models/owner_model.dart';
import 'package:customer/app/models/payment_method_model.dart';
import 'package:customer/app/models/platform_fee_setting_model.dart';
import 'package:customer/app/models/product_model.dart';
import 'package:customer/app/models/referral_model.dart';
import 'package:customer/app/models/transaction_log_model.dart';
import 'package:customer/app/models/vendor_model.dart';
import 'package:customer/app/models/review_model.dart';
import 'package:customer/app/models/sub_category_model.dart';
import 'package:customer/app/models/tax_model.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/models/wallet_transaction_model.dart';
import 'package:customer/app/models/zone_model.dart';
import 'package:customer/constant/order_status.dart';
import 'package:customer/constant/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../app/models/currency_model.dart';
import '../constant/collection_name.dart';

class FireStoreUtils {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static String? getCurrentUid() {
    if (FirebaseAuth.instance.currentUser == null) {
      return null;
    }
    return FirebaseAuth.instance.currentUser!.uid;
  }

  static Future<bool> userExistOrNot(String uid) async {
    try {
      var value = await fireStore.collection(CollectionName.customers).doc(uid).get();
      return value.exists;
    } catch (e) {
      developer.log("Failed to check user exist: $e");
      return false;
    }
  }

  static Future<bool> isLogin() async {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        return await userExistOrNot(FirebaseAuth.instance.currentUser!.uid);
      }
    } catch (e) {
      developer.log("Failed to check login status: $e");
    }
    return false;
  }

  static Future<bool> setNotification(NotificationModel notificationModel) async {
    try {
      await fireStore.collection(CollectionName.notification).doc(notificationModel.id).set(notificationModel.toJson());
      return true;
    } catch (e) {
      developer.log("Failed to update user notification: $e");
      return false;
    }
  }

  // Future<void> getAdminCommissionDriver() async {
  //   try {
  //    await fireStore.collection(CollectionName.settings).doc("admin_commission").get().then(
  //       (value) {
  //         if (value.exists) {
  //           Constant.adminCommissionDriver = value.data()!["admin_commission_driver"];
  //         }
  //       },
  //     );
  //   } catch (e, stack) {
  //     developer.log('Error fetching admin commission: $e', error: e, stackTrace: stack);
  //   }
  // }
  //
  // Future<void> getAdminCommissionVendor() async {
  //   try {
  //     await fireStore.collection(CollectionName.settings).doc("admin_commission").get().then(
  //       (value) {
  //         if (value.exists) {
  //           Constant.adminCommissionVendor = value.data()!["admin_commission_vendor"];
  //         }
  //       },
  //     );
  //   } catch (e, stack) {
  //     developer.log('Error fetching admin commission: $e', error: e, stackTrace: stack);
  //   }
  // }

  Future<void> getSettings() async {
    try {
      var value = await fireStore.collection(CollectionName.settings).doc("constant").get();
      if (value.exists) {
        final data = value.data()!;
        Constant.senderId = data["notification_senderId"];
        Constant.jsonFileURL = data["jsonFileURL"];
        Constant.radius = data["radius"] ?? "50";
        Constant.googleMapKey = data["googleMapKey"] ?? "";
        Constant.minimumAmountToDeposit = data["minimum_amount_deposit"] ?? "100";
        Constant.minimumAmountToWithdrawal = data["minimum_amount_withdraw"] ?? "100";
        Constant.notificationServerKey = data["notification_senderId"] ?? "";
        Constant.termsAndConditions = data["termsAndConditions"];
        Constant.aboutApp = data["aboutApp"];
        Constant.privacyPolicy = data["privacyPolicy"];
        Constant.appName.value = data["appName"];
        Constant.appColor = data["customerAppColor"];
        Constant.referralAmount = data["referral_Amount"];
        Constant.countryCode = data["countryCode"];
      }
    } catch (e) {
      developer.log('Error in getSettings "constant": $e');
    }

    try {
      var value = await fireStore.collection(CollectionName.settings).doc("admin_commission").get();
      final data = value.data()!;
      try {
        AdminCommission driverCommission = AdminCommission.fromJson(data["admin_commission_driver"]);
        if (driverCommission.active == true) {
          Constant.adminCommissionDriver = driverCommission;
        }
      } catch (e) {
        developer.log("Driver commission parse error: $e");
      }
    } catch (e) {
      developer.log('Error in getSettings "admin_commission": $e');
    }

    try {
      var value = await fireStore.collection(CollectionName.settings).doc("admin_commission").get();
      final data = value.data()!;
      try {
        AdminCommission driverCommission = AdminCommission.fromJson(data["admin_commission_vendor"]);
        if (driverCommission.active == true) {
          Constant.adminCommissionVendor = driverCommission;
        }
      } catch (e) {
        developer.log("Driver commission parse error: $e");
      }
    } catch (e) {
      developer.log('Error in getSettings "admin_commission": $e');
    }

    try {
      var value = await fireStore.collection(CollectionName.settings).doc("cancelling_reason").get();
      if (value.exists) {
        Constant.cancellationReason = value.data()!["reasons"];
      }
    } catch (e) {
      developer.log('Error in getSettings "cancelling_reason": $e');
    }
  }

  static Future<GlobalValueModel?> getGlobalValueSetting() async {
    try {
      var value = await FirebaseFirestore.instance.collection(CollectionName.settings).doc("globalValue").get();
      if (value.exists) {
        return GlobalValueModel.fromJson(value.data()!);
      }
    } catch (e) {
      developer.log("Failed to get global value setting: $e");
    }
    return null;
  }

  static Future<PlatFormFeeSettingModel?> getPlatFormFeeSetting() async {
    try {
      var value = await FirebaseFirestore.instance.collection(CollectionName.settings).doc("platform_fee_settings").get();
      if (value.exists && value.data() != null) {
        PlatFormFeeSettingModel setting = PlatFormFeeSettingModel.fromJson(value.data()!);
        Constant.platFormFeeSetting = setting;
        return setting;
      }
    } catch (e, stack) {
      developer.log("Failed to get PlatFormFee setting: $e", error: e, stackTrace: stack);
    }

    return null;
  }

  static Future<List<LanguageModel>> getLanguage() async {
    List<LanguageModel> languageModelList = [];
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance.collection(CollectionName.languages).where("active", isEqualTo: true).get();

      for (var document in snap.docs) {
        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
        if (data != null) {
          languageModelList.add(LanguageModel.fromJson(data));
        } else {
          developer.log("getLanguage: data is null for a document");
        }
      }
    } catch (e) {
      developer.log("Error fetching languages: $e");
    }
    return languageModelList;
  }

  Future<CurrencyModel?> getCurrency() async {
    try {
      var value = await fireStore.collection(CollectionName.currencies).where("active", isEqualTo: true).get();

      if (value.docs.isNotEmpty) {
        return CurrencyModel.fromJson(value.docs.first.data());
      }
    } catch (e) {
      developer.log("Error fetching currency: $e");
    }
    return null;
  }

  static Future<List<CategoryModel>> getCategoryList() async {
    List<CategoryModel> categoryList = [];
    try {
      var value = await fireStore.collection(CollectionName.category).where("active", isEqualTo: true).get();

      for (var element in value.docs) {
        categoryList.add(CategoryModel.fromJson(element.data()));
      }
    } catch (e) {
      developer.log("Error fetching category list: $e");
    }
    return categoryList;
  }

  static Future<List<SubCategoryModel>> getSubCategoryList(String? categoryId) async {
    List<SubCategoryModel> subCategoryList = [];
    try {
      var snapshot = await fireStore.collection(CollectionName.sub_category).where("categoryId", isEqualTo: categoryId).get();

      for (var element in snapshot.docs) {
        subCategoryList.add(SubCategoryModel.fromJson(element.data()));
      }
    } catch (e) {
      developer.log("Error fetching subcategories: $e");
    }
    return subCategoryList;
  }

  static Future<List<CuisineModel>> getCuisineList() async {
    List<CuisineModel> cuisineList = [];
    try {
      var value = await fireStore.collection(CollectionName.cuisine).where("active", isEqualTo: true).get();

      for (var element in value.docs) {
        cuisineList.add(CuisineModel.fromJson(element.data()));
      }
    } catch (e) {
      developer.log("Error fetching Cuisine list: $e");
    }
    return cuisineList;
  }

  static Future<List<ProductModel>> getProductList() async {
    List<ProductModel> productList = [];
    try {
      var snapshot = await fireStore.collection(CollectionName.product).where("status", isEqualTo: true).get();

      for (var element in snapshot.docs) {
        productList.add(ProductModel.fromJson(element.data()));
      }
    } catch (e) {
      developer.log("Error fetching products: $e");
    }
    return productList;
  }

  static Future<List<DriverUserModel>> getAllDriver() async {
    List<DriverUserModel> productList = [];
    try {
      var snapshot = await fireStore.collection(CollectionName.driver).get();

      for (var element in snapshot.docs) {
        productList.add(DriverUserModel.fromJson(element.data()));
      }
    } catch (e) {
      developer.log("Error fetching products: $e");
    }
    return productList;
  }

  static Future<List<ProductModel>> getCategoryProductList(String id) async {
    List<ProductModel> productList = [];
    try {
      var snapshot = await fireStore.collection(CollectionName.product).where("categoryId", isEqualTo: id).get();

      for (var element in snapshot.docs) {
        productList.add(ProductModel.fromJson(element.data()));
      }
    } catch (e) {
      developer.log("Error fetching products by category: $e");
    }
    return productList;
  }

  static Future<List<VendorModel>> getRestaurantByCuisine(String cuisineId, {required double latitude, required double longitude, double? radiusKm}) async {
    List<VendorModel> restaurantList = [];

    // Firestore query without radius restriction
    Query<Map<String, dynamic>> query = fireStore.collection(CollectionName.vendors).where("active", isEqualTo: true).where('cuisineId', isEqualTo: cuisineId);

    QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

    for (var doc in snapshot.docs) {
      final data = doc.data();

      if (data['position'] != null && data['position']['geopoint'] != null) {
        GeoPoint point = data['position']['geopoint'];

        double distance = _calculateDistance(
          latitude,
          longitude,
          point.latitude,
          point.longitude,
        );

        // ✅ Apply radius filter if given
        if (radiusKm == null || distance <= radiusKm) {
          VendorModel vendor = VendorModel.fromJson(data);
          vendor.distance = distance;
          restaurantList.add(vendor);
        }
      }
    }

    // Sort by nearest
    restaurantList.sort((a, b) => a.distance!.compareTo(b.distance!));

    return restaurantList;
  }

  static Future<bool> updateProduct(ProductModel productModel) async {
    try {
      await fireStore.collection(CollectionName.product).doc(productModel.id).set(productModel.toJson());
      return true;
    } catch (e) {
      developer.log("Failed to update product: $e");
      return false;
    }
  }

  static Future<ProductModel?> getProductByID(String productId) async {
    try {
      var doc = await fireStore.collection(CollectionName.product).doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromJson(doc.data()!);
      }
    } catch (e) {
      developer.log("Failed to get product by ID: $e");
    }
    return null;
  }

  static Future<bool> updateRestaurant(VendorModel restaurantModel) async {
    try {
      await fireStore.collection(CollectionName.vendors).doc(restaurantModel.id).set(restaurantModel.toJson());
      return true;
    } catch (e) {
      developer.log("Failed to update restaurant: $e");
      return false;
    }
  }

  static Future<bool> updateDriver(DriverUserModel driverModel) async {
    try {
      await fireStore.collection(CollectionName.driver).doc(driverModel.driverId).set(driverModel.toJson());
      return true;
    } catch (e) {
      developer.log("Failed to update driver: $e");
      return false;
    }
  }

  static Future<OwnerModel?> getOwnerProfile(String uuid) async {
    try {
      var doc = await fireStore.collection(CollectionName.owner).doc(uuid).get();
      if (doc.exists) {
        return OwnerModel.fromJson(doc.data()!);
      }
    } catch (e) {
      developer.log("Failed to get owner profile: $e");
    }
    return null;
  }

  static Future<UserModel?> getUserProfile(String uuid) async {
    try {
      var doc = await fireStore.collection(CollectionName.customers).doc(uuid).get();
      if (doc.exists) {
        UserModel user = UserModel.fromJson(doc.data()!);
        Constant.userModel = user;
        return user;
      }
    } catch (e) {
      developer.log("Failed to get user profile: $e");
    }
    return null;
  }

  static Future<bool> addUser(UserModel userModel) async {
    try {
      await fireStore.collection(CollectionName.customers).doc(userModel.id).set(userModel.toJson());
      Constant.userModel = userModel;
      return true;
    } catch (e) {
      developer.log("Failed to add user: $e");
      return false;
    }
  }

  static Future<bool> updateUser(UserModel userModel) async {
    try {
      await fireStore.collection(CollectionName.customers).doc(userModel.id).set(userModel.toJson());
      Constant.userModel = userModel;
      return true;
    } catch (e) {
      developer.log("Failed to update user: $e");
      return false;
    }
  }

  static Future<VendorModel?> getRestaurant(String uuid) async {
    try {
      var doc = await fireStore.collection(CollectionName.vendors).doc(uuid).get();
      if (doc.exists) {
        return VendorModel.fromJson(doc.data()!);
      }
    } catch (e) {
      developer.log("Failed to get restaurant: $e");
    }
    return null;
  }

  static Future<List<VendorModel>> getAllRestaurant({required double latitude, required double longitude, double? radiusKm}) async {
    List<VendorModel> restaurantList = [];

    // Firestore query without radius restriction
    Query<Map<String, dynamic>> query = fireStore.collection(CollectionName.vendors).where("active", isEqualTo: true).where("isOnline", isEqualTo: true);

    QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

    for (var doc in snapshot.docs) {
      final data = doc.data();

      if (data['position'] != null && data['position']['geopoint'] != null) {
        GeoPoint point = data['position']['geopoint'];

        double distance = _calculateDistance(
          latitude,
          longitude,
          point.latitude,
          point.longitude,
        );

        // ✅ Apply radius filter if given
        if (radiusKm == null || distance <= radiusKm) {
          VendorModel vendor = VendorModel.fromJson(data);
          vendor.distance = distance;
          restaurantList.add(vendor);
        }
      }
    }

    // Sort by nearest
    restaurantList.sort((a, b) => a.distance!.compareTo(b.distance!));

    return restaurantList;
  }

  /// Haversine formula to calculate distance (km)
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth radius in km
    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) + cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _deg2rad(double deg) => deg * (pi / 180);

  static Future<List<VendorModel>> getVegRestaurant({required double latitude, required double longitude, required double radius}) async {
    List<VendorModel> restaurantList = [];

    // Firestore query without radius restriction
    Query<Map<String, dynamic>> query =
        fireStore.collection(CollectionName.vendors).where("active", isEqualTo: true).where("isOnline", isEqualTo: true).where("vendorType", isEqualTo: "Veg");

    QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

    for (var doc in snapshot.docs) {
      final data = doc.data();

      if (data['position'] != null && data['position']['geopoint'] != null) {
        GeoPoint point = data['position']['geopoint'];

        double distance = _calculateDistance(
          latitude,
          longitude,
          point.latitude,
          point.longitude,
        );

        if (distance <= double.parse(Constant.restaurantRadius)) {
          VendorModel vendor = VendorModel.fromJson(data);
          vendor.distance = distance;
          restaurantList.add(vendor);
        }
      }
    }

    // Sort by nearest
    restaurantList.sort((a, b) => a.distance!.compareTo(b.distance!));

    return restaurantList;
  }

  static Future<List<VendorModel>> getNonVegRestaurant({required double latitude, required double longitude, required double radius}) async {
    List<VendorModel> restaurantList = [];

    // Firestore query without radius restriction
    Query<Map<String, dynamic>> query =
        fireStore.collection(CollectionName.vendors).where("active", isEqualTo: true).where("isOnline", isEqualTo: true).where("vendorType", isEqualTo: "Non veg");

    QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

    for (var doc in snapshot.docs) {
      final data = doc.data();

      if (data['position'] != null && data['position']['geopoint'] != null) {
        GeoPoint point = data['position']['geopoint'];

        double distance = _calculateDistance(
          latitude,
          longitude,
          point.latitude,
          point.longitude,
        );

        if (distance <= double.parse(Constant.restaurantRadius)) {
          VendorModel vendor = VendorModel.fromJson(data);
          vendor.distance = distance;
          restaurantList.add(vendor);
        }
      }
    }

    // Sort by nearest
    restaurantList.sort((a, b) => a.distance!.compareTo(b.distance!));

    return restaurantList;
  }

  Future<PaymentModel?> getPayment() async {
    PaymentModel? paymentModel;
    try {
      var doc = await fireStore.collection(CollectionName.settings).doc("payment").get();
      if (doc.exists) {
        paymentModel = PaymentModel.fromJson(doc.data()!);
        Constant.paymentModel = paymentModel;
      }
    } catch (e) {
      developer.log("Error fetching payment details: $e");
    }
    return paymentModel;
  }

  static Future<List<WalletTransactionModel>> getWalletTransaction() async {
    List<WalletTransactionModel> walletTransactionModelList = [];
    try {
      var snapshot = await fireStore
          .collection(CollectionName.walletTransaction)
          .where('userId', isEqualTo: FireStoreUtils.getCurrentUid())
          .where('type', isEqualTo: Constant.user)
          .orderBy('createdDate', descending: true)
          .get();

      for (var element in snapshot.docs) {
        walletTransactionModelList.add(WalletTransactionModel.fromJson(element.data()));
      }
    } catch (e) {
      developer.log("Error fetching wallet transactions: $e");
    }
    return walletTransactionModelList;
  }

  static Future<List<BankDetailsModel>> getBankDetailList(String? customerId) async {
    List<BankDetailsModel> bankDetailsList = [];
    try {
      var snapshot = await fireStore.collection(CollectionName.bankDetails).where("customerId", isEqualTo: customerId).get();

      for (var element in snapshot.docs) {
        bankDetailsList.add(BankDetailsModel.fromJson(element.data()));
      }
    } catch (e) {
      developer.log("Failed to get bank details: $e");
    }
    return bankDetailsList;
  }

  static Future<bool> setWalletTransaction(WalletTransactionModel walletTransactionModel) async {
    try {
      await fireStore.collection(CollectionName.walletTransaction).doc(walletTransactionModel.id).set(walletTransactionModel.toJson());
      return true;
    } catch (e) {
      developer.log("Failed to set wallet transaction: $e");
      return false;
    }
  }

  static Future<bool> setTransactionLog(TransactionLogModel transactionLogModel) async {
    try {
      await fireStore.collection(CollectionName.transactionLog).doc(transactionLogModel.id).set(transactionLogModel.toJson());
      return true;
    } catch (e) {
      developer.log("Failed to set transaction log: $e");
      return false;
    }
  }

  static Future<bool> updateUserWallet({required String amount}) async {
    try {
      var user = await getUserProfile(FireStoreUtils.getCurrentUid()!);
      if (user != null) {
        double updatedAmount = double.parse(user.walletAmount.toString()) + double.parse(amount);
        user.walletAmount = updatedAmount.toString();
        return await FireStoreUtils.updateUser(user);
      }
    } catch (e) {
      developer.log("Failed to update user wallet: $e");
    }
    return false;
  }

  static Future<bool> addBankDetail(BankDetailsModel bankDetailsModel) async {
    try {
      await fireStore.collection(CollectionName.bankDetails).doc(bankDetailsModel.id).set(bankDetailsModel.toJson());
      return true;
    } catch (e) {
      developer.log("Failed to add bank detail: $e");
      return false;
    }
  }

  static Future<bool> updateBankDetail(BankDetailsModel bankDetailsModel) async {
    try {
      await fireStore.collection(CollectionName.bankDetails).doc(bankDetailsModel.id).update(bankDetailsModel.toJson());
      return true;
    } catch (e) {
      developer.log("Failed to update bank detail: $e");
      return false;
    }
  }

  static Future<List<BannerModel>> getBannerList() async {
    List<BannerModel> bannerList = [];
    try {
      var snapshot = await fireStore.collection(CollectionName.banner).where('isEnable', isEqualTo: true).get();
      for (var element in snapshot.docs) {
        bannerList.add(BannerModel.fromJson(element.data()));
      }
    } catch (e) {
      developer.log("Failed to fetch banner list: $e");
    }
    return bannerList;
  }

  static Future<List<ProductModel>> getProductRestaurantWise(String? restaurantId) async {
    List<ProductModel> productList = [];
    try {
      var snapshot = await fireStore.collection(CollectionName.product).where("vendorId", isEqualTo: restaurantId).where("status", isEqualTo: true).get();

      for (var element in snapshot.docs) {
        productList.add(ProductModel.fromJson(element.data()));
      }
    } catch (e) {
      developer.log("Failed to fetch products by restaurant: $e");
    }
    return productList;
  }

  static Future<ProductModel?> getProductByProductId(String productId) async {
    ProductModel? productModel;
    try {
      var snapshot = await fireStore.collection(CollectionName.product).where("status", isEqualTo: true).where('id', isEqualTo: productId).get();

      for (var element in snapshot.docs) {
        productModel = ProductModel.fromJson(element.data());
      }
    } catch (e) {
      developer.log("Failed to get product by productId: $e");
    }
    return productModel;
  }

  // static Future<List<ProductModel>> getProductListByName(String query) async {
  //   List<ProductModel> productList = [];
  //   developer.log('=======----------> call getProductListByName $query');
  //   try {
  //     var products =
  //         await FirebaseFirestore.instance.collection(CollectionName.product).where("productName", isGreaterThanOrEqualTo: query).where("productName", isLessThanOrEqualTo: '$query\uf8ff').get();
  //
  //     for (var element in products.docs) {
  //       productList.add(ProductModel.fromJson(element.data()));
  //     }
  //   } catch (e) {
  //     developer.log('Error fetching products by name: $e');
  //   }
  //   return productList;
  // }

  static Future<List<ProductModel>> getProductsFromVendorsWithSearch({
    required List<String> vendorIds, // kept for structure consistency
    required String query,
  }) async {
    List<ProductModel> productList = [];

    try {
      if (query.trim().isEmpty) return productList;

      query = query.toLowerCase().trim();

      // ✅ Fetch all products whose `searchKeywords` contains the query
      var productsSnapshot =
          await FirebaseFirestore.instance.collection(CollectionName.product).where("status", isEqualTo: true).where("searchKeywords", arrayContains: query).get();

      for (var doc in productsSnapshot.docs) {
        final product = ProductModel.fromJson(doc.data());

        // ✅ If you still want to filter by vendors (optional)
        if (vendorIds.isEmpty || vendorIds.contains(product.vendorId)) {
          productList.add(product);
        }
      }
    } catch (e, stack) {
      developer.log('❌ Error fetching products with search: $e', error: e, stackTrace: stack);
    }

    return productList;
  }

  static Future<List<CouponModel>> getRestaurantOffer(String restaurantID) async {
    List<CouponModel> couponModelList = [];
    try {
      var snapshot = await fireStore.collection(CollectionName.coupon).where('isVendorOffer', isEqualTo: true).where('vendorId', isEqualTo: restaurantID).get();

      for (var element in snapshot.docs) {
        couponModelList.add(CouponModel.fromJson(element.data()));
      }
    } catch (e) {
      developer.log("Failed to fetch restaurant offers: $e");
    }
    return couponModelList;
  }

  static Future<List<VendorModel>> getFavouriteRestaurant() async {
    List<VendorModel> favouriteRestaurantList = [];
    try {
      var snapshot = await fireStore.collection(CollectionName.vendors).where("active", isEqualTo: true).where("likedUser", arrayContains: FireStoreUtils.getCurrentUid()).get();

      for (var element in snapshot.docs) {
        favouriteRestaurantList.add(VendorModel.fromJson(element.data()));
      }
    } catch (e) {
      developer.log("Failed to get favourite restaurants: $e");
    }
    return favouriteRestaurantList;
  }

  static Future<List<ProductModel>> getFavouriteDishes() async {
    List<ProductModel> favouriteDishList = [];
    try {
      var snapshot = await fireStore.collection(CollectionName.product).where('status', isEqualTo: true).where("likedUser", arrayContains: FireStoreUtils.getCurrentUid()).get();

      for (var element in snapshot.docs) {
        favouriteDishList.add(ProductModel.fromJson(element.data()));
      }
    } catch (e) {
      developer.log("Failed to get favourite dishes: $e");
    }
    return favouriteDishList;
  }

  static Stream<QuerySnapshot> getNotificationList() {
    return fireStore.collection(CollectionName.notification).where('customerId', isEqualTo: FireStoreUtils.getCurrentUid()).orderBy('createdAt', descending: true).snapshots();
  }

  static Future<bool> setOrder(OrderModel bookingModel) async {
    try {
      await fireStore.collection(CollectionName.orders).doc(bookingModel.id).set(bookingModel.toJson());
      return true;
    } catch (e) {
      developer.log("Failed to set order: $e");
      return false;
    }
  }

  static Future<List<OrderModel>> getOrderListForStatement(DateTimeRange? dateTimeRange) async {
    List<OrderModel> orderList = [];
    try {
      var snapshot = await fireStore
          .collection(CollectionName.orders)
          .where('customerId', isEqualTo: FireStoreUtils.getCurrentUid())
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: dateTimeRange!.start,
            isLessThan: dateTimeRange.end,
          )
          .orderBy('createdAt', descending: true)
          .get();

      for (var element in snapshot.docs) {
        orderList.add(OrderModel.fromJson(element.data()));
      }
    } catch (e) {
      developer.log("Failed to get order list for statement: $e");
    }
    return orderList;
  }

  Future<List<TaxModel>> getTaxList() async {
    List<TaxModel> taxList = [];
    try {
      var snapshot = await fireStore.collection(CollectionName.countryTax).where('country', isEqualTo: Constant.country).where('active', isEqualTo: true).get();

      for (var element in snapshot.docs) {
        taxList.add(TaxModel.fromJson(element.data()));
      }
    } catch (e) {
      developer.log("Failed to get tax list: $e");
    }
    return taxList;
  }

  static Stream<Map<String, List<OrderModel>>> getAllOrderList() {
    List<String> pendingStatuses = [
      OrderStatus.orderPending,
      OrderStatus.orderAccepted,
      OrderStatus.orderOnReady,
      OrderStatus.driverAccepted,
      OrderStatus.driverAssigned,
      OrderStatus.driverPickup
    ];

    List<String> cancelledStatuses = [OrderStatus.orderCancel, OrderStatus.orderRejected];

    return fireStore
        .collection(CollectionName.orders)
        .where("customerId", isEqualTo: FireStoreUtils.getCurrentUid())
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      List<OrderModel> pendingOrders = [];
      List<OrderModel> completedOrders = [];
      List<OrderModel> cancelledOrders = [];

      for (var doc in snapshot.docs) {
        OrderModel bookingModel = OrderModel.fromJson(doc.data());
        String status = bookingModel.orderStatus.toString();

        if (pendingStatuses.contains(status)) {
          pendingOrders.add(bookingModel);
        } else if (status == OrderStatus.orderComplete) {
          completedOrders.add(bookingModel);
        } else if (cancelledStatuses.contains(status)) {
          cancelledOrders.add(bookingModel);
        }
      }

      return {
        'pendingOrders': pendingOrders,
        'completedOrders': completedOrders,
        'cancelledOrders': cancelledOrders,
      };
    });
  }

  static Future<List<CouponModel>> getCoupon() async {
    List<CouponModel> couponList = [];
    try {
      var snapshot = await fireStore
          .collection(CollectionName.coupon)
          .where("active", isEqualTo: true)
          .where("isPrivate", isEqualTo: false)
          .where('expireAt', isGreaterThanOrEqualTo: Timestamp.now())
          .get();

      for (var element in snapshot.docs) {
        couponList.add(CouponModel.fromJson(element.data()));
      }
    } catch (e) {
      developer.log("Failed to get coupons: $e");
    }
    return couponList;
  }

  static Future<DriverUserModel?> getDriverUserProfile(String uuid) async {
    try {
      var doc = await fireStore.collection(CollectionName.driver).doc(uuid).get();
      if (doc.exists) {
        return DriverUserModel.fromJson(doc.data()!);
      }
    } catch (e) {
      developer.log("Failed to get driver profile: $e");
    }
    return null;
  }

  static Future<bool> setReview(ReviewModel reviewModel) async {
    try {
      await fireStore.collection(CollectionName.review).doc(reviewModel.id).set(reviewModel.toJson());
      return true;
    } catch (e) {
      developer.log("Failed to set review: $e");
      return false;
    }
  }

  static Future<ReviewModel?> getRestaurantReview(String orderId) async {
    try {
      var doc = await fireStore.collection(CollectionName.review).doc(orderId).get();
      if (doc.exists) {
        var data = doc.data();
        if (data != null && data['type'] == Constant.restaurant) {
          return ReviewModel.fromJson(data);
        }
      }
    } catch (e) {
      developer.log("Failed to get restaurant review: $e");
    }
    return null;
  }

  static Future<ReviewModel?> getDriverReview(String orderId) async {
    try {
      var doc = await fireStore.collection(CollectionName.review).doc(orderId).get();
      if (doc.exists) {
        var data = doc.data();
        if (data != null && data['type'] == Constant.driver) {
          return ReviewModel.fromJson(data);
        }
      }
    } catch (e) {
      developer.log("Failed to get driver review: $e");
    }
    return null;
  }

  static Future<List<OnboardingScreenModel>> getOnboardingDataList() async {
    List<OnboardingScreenModel> onboardingList = [];
    try {
      var snapshot = await fireStore
          .collection(CollectionName.onboardingScreen)
          .where('status', isEqualTo: true)
          .where('type', isEqualTo: 'customer')
          .orderBy('createdAt', descending: false)
          .get();
      for (var element in snapshot.docs) {
        onboardingList.add(OnboardingScreenModel.fromJson(element.data()));
      }
    } catch (e) {
      developer.log("Failed to fetch Onboarding list: $e");
    }
    return onboardingList;
  }

  static Future<ReferralModel?> getReferral() async {
    ReferralModel? referralModel;
    await fireStore.collection(CollectionName.referral).doc(FireStoreUtils.getCurrentUid()).get().then((value) {
      if (value.exists) {
        referralModel = ReferralModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      developer.log("Error getting referral: $error");
      referralModel = null;
    });
    return referralModel;
  }

  static Future<ReferralModel?> getReferralUserByCode(String referralCode) async {
    ReferralModel? referralModel;
    try {
      await fireStore.collection(CollectionName.referral).where("referralCode", isEqualTo: referralCode).get().then((value) {
        referralModel = ReferralModel.fromJson(value.docs.first.data());
      });
    } catch (e, s) {
      developer.log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return referralModel;
  }

  static Future<String?> referralAdd(ReferralModel referral) async {
    try {
      await fireStore.collection(CollectionName.referral).doc(referral.userId).set(referral.toJson());
    } catch (e, s) {
      developer.log('add referral error:  $e $s');
      return null;
    }
    return null;
  }

  static Future<bool?> checkReferralCodeValidOrNot(String referralCode) async {
    bool? isExit;
    try {
      await fireStore.collection(CollectionName.referral).where("referralCode", isEqualTo: referralCode).get().then((value) {
        if (value.size > 0) {
          isExit = true;
        } else {
          isExit = false;
        }
      });
    } catch (e, s) {
      developer.log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isExit;
  }

  static Future<bool?> updateWalletForReferral({
    required String userId,
    required String amount,
    required String role,
  }) async {
    bool isAdded = false;

    // 3 Roles Support
    String collection;
    if (role == Constant.user) {
      collection = CollectionName.customers;
    } else if (role == Constant.driver) {
      collection = CollectionName.driver;
    } else if (role == Constant.owner) {
      collection = CollectionName.owner;
    } else {
      collection = CollectionName.customers;
    }

    final docSnapshot = await FirebaseFirestore.instance.collection(collection).doc(userId).get();

    if (docSnapshot.exists) {
      double currentWalletAmount = double.tryParse(docSnapshot.data()?['walletAmount']?.toString() ?? '0') ?? 0;
      double updatedWalletAmount = currentWalletAmount + double.parse(amount);

      await FirebaseFirestore.instance.collection(collection).doc(userId).update({
        'walletAmount': updatedWalletAmount.toStringAsFixed(2),
      }).then((value) {
        isAdded = true;
      }).catchError((error) {
        developer.log('Error updating wallet for referral: $error');
        isAdded = false;
      });
    } else {
      developer.log("User not found in $collection collection for ID: $userId");
    }
    return isAdded;
  }

  static Future<List<ZoneModel>> getZoneList() async {
    List<ZoneModel> zoneList = [];
    try {
      var querySnapshot = await fireStore.collection(CollectionName.zones).where('status', isEqualTo: true).orderBy('createdAt', descending: true).get();

      zoneList = querySnapshot.docs.map((doc) {
        var data = doc.data();
        return ZoneModel.fromJson(data);
      }).toList();
    } catch (error) {
      developer.log('Error in ZoneList: $error');
    }
    return zoneList;
  }
}
