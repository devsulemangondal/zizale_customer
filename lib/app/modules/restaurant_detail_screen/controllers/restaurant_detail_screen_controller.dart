import 'dart:developer' as developer;
import 'dart:developer';
import 'package:customer/app/models/cart_model.dart';
import 'package:customer/app/models/category_model.dart';
import 'package:customer/app/models/coupon_model.dart';
import 'package:customer/app/models/product_model.dart';
import 'package:customer/app/models/vendor_model.dart';
import 'package:customer/app/models/sub_category_model.dart';
import 'package:customer/app/models/tax_model.dart';
import 'package:customer/app/models/variation_model.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/services/database_helper.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestaurantDetailScreenController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<TextEditingController> searchController = TextEditingController().obs;
  Rx<VendorModel> restaurantModel = VendorModel().obs;
  RxList<ProductModel> productList = <ProductModel>[].obs;
  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  RxList<SubCategoryModel> subCategoryList = <SubCategoryModel>[].obs;
  Rx<CategoryModel> selectedCategory = CategoryModel().obs;
  Rx<SubCategoryModel> selectedSubCategory = SubCategoryModel().obs;
  RxList<ProductModel> filteredProductList = <ProductModel>[].obs;
  Rx<VariationModel> selectedVariationName = VariationModel().obs;
  Rx<OptionModel> selectedOption = OptionModel().obs;
  RxList selectedAddons = [].obs;
  RxInt quantity = 1.obs;
  CartDatabaseHelper cartDatabaseHelper = CartDatabaseHelper();
  RxList<CartModel> cartItemsList = <CartModel>[].obs;
  String searchQuery = "";
  RxList<bool> isOpen = <bool>[].obs;
  RxBool isVeg = true.obs;
  RxList<TaxModel> taxList = (Constant.taxList ?? []).obs;
  RxList<CouponModel> restaurantOfferList = <CouponModel>[].obs;
  RxBool isEditing = false.obs;
  ScrollController scrollController = ScrollController();
  List<String> foodTypeList = ["All", "Veg", "NonVeg"];
  var selectedFoodTypes = <String>[].obs;

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  Future<void> getArguments() async {
    try {
      dynamic argumentData = Get.arguments;
      if (argumentData != null) {
        restaurantModel.value = argumentData["restaurantModel"];
        log("++++++++++++ ====  ${restaurantModel.toJson()}");
        await FireStoreUtils.getRestaurant(restaurantModel.value.id.toString()).then(
          (value) {
            if (value != null) restaurantModel.value = value;
          },
        );
        await getData();
        selectedFoodTypes.clear();
        filterProductList();
      }
    } catch (e, stack) {
      developer.log("Error getting arguments: ", error: e, stackTrace: stack);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getData() async {
    try {
      productList.clear();
      categoryList.clear();
      filteredProductList.clear();

      if (FireStoreUtils.getCurrentUid() != null) {
        cartItemsList.value = await cartDatabaseHelper.getAllCartItems(FireStoreUtils.getCurrentUid().toString());
      }

      final products = await FireStoreUtils.getProductRestaurantWise(restaurantModel.value.id.toString());
      productList.addAll(products);

      final categories = await FireStoreUtils.getCategoryList();
      categoryList.addAll(categories.where((category) {
        return productList.any((product) => product.categoryId == category.id);
      }).toList());

      restaurantOfferList.clear();
      final offers = await FireStoreUtils.getRestaurantOffer(restaurantModel.value.id.toString());
      restaurantOfferList.addAll(offers);

      if (categoryList.isNotEmpty) {
        selectedCategory.value = categoryList.first;
        await getSubCategory(categoryList.first.id.toString());
      }
      isLoading.value = false;

      update();
    } catch (e, stack) {
      developer.log("Error loading data: $e", stackTrace: stack);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getTax() async {
    try {
      final taxValues = await FireStoreUtils().getTaxList();
      Constant.taxList = taxValues;
      taxList.value = taxValues;
    } catch (e, stack) {
      developer.log("Error getting tax data: $e", stackTrace: stack);
    }
  }

  Future<void> getSubCategory(String categoryId) async {
    try {
      subCategoryList.clear();
      final value = await FireStoreUtils.getSubCategoryList(categoryId);
      subCategoryList.addAll(value.where((subCategory) {
        return productList.any((product) => product.categoryId == categoryId && product.subCategoryId == subCategory.id);
      }).toList());
      isOpen.value = List.generate(subCategoryList.length, (index) => true);
      filterProductList();
    } catch (e, stack) {
      developer.log("Error getting subcategories: $e", stackTrace: stack);
    }
  }

  // void searchProducts(String query) {
  //   try {
  //     searchQuery = query;
  //     filteredProductList.clear();
  //
  //     if (query.isEmpty) {
  //       filteredProductList.addAll(productList);
  //     } else {
  //       filteredProductList.addAll(productList.where((product) {
  //         final productName = product.productName ?? "";
  //         return productName.contains(query);
  //       }));
  //     }
  //     update();
  //   } catch (e, stack) {
  //     developer.log("Error searching products: $e", stackTrace: stack);
  //   }
  // }
  void searchProducts(String query) {
    try {
      searchQuery = query.toLowerCase(); // convert query to lowercase
      filterProductList(); // instead of directly filtering here
    } catch (e, stack) {
      developer.log("Error searching products: $e", stackTrace: stack);
    }
  }

  void filterProductList() {
    try {
      filteredProductList.clear();
      isOpen.clear();
      filteredProductList.addAll(productList.where((product) {
        final matchesCategory = selectedCategory.value.id == null || product.categoryId == selectedCategory.value.id;
        final matchesSubCategory = selectedSubCategory.value.id == null || product.subCategoryId == selectedSubCategory.value.id;

        // Veg/NonVeg filter logic
        bool matchesVeg = true;
        if (selectedFoodTypes.isNotEmpty && !selectedFoodTypes.contains("All")) {
          if (selectedFoodTypes.contains("Veg") && selectedFoodTypes.contains("NonVeg")) {
            // Both selected, so no filter
            matchesVeg = true;
          } else if (selectedFoodTypes.contains("Veg")) {
            matchesVeg = product.foodType == "Veg";
          } else if (selectedFoodTypes.contains("NonVeg")) {
            matchesVeg = product.foodType == "Non veg";
          } else {
            matchesVeg = true;
          }
        }

        // Search filter
        final productName = (product.productName ?? "").toLowerCase();
        final matchesSearch = searchQuery.isEmpty || productName.contains(searchQuery.toLowerCase());

        return matchesCategory && matchesSubCategory && matchesVeg && matchesSearch;
      }).toList());
      filteredProductList.refresh();
      update();
    } catch (e, stack) {
      developer.log("Error filtering products: $e", stackTrace: stack);
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

  int calculateItemPrice({ProductModel? productModel}) {
    try {
      int price = 0;
      int addOnsTotal = 0;

      if (selectedOption.value.name == null || selectedOption.value.name!.isEmpty) {
        price += Constant.getDiscountedPrice(productModel!).toInt();
      } else {
        price += int.tryParse(selectedOption.value.price.toString()) ?? 0;
      }

      for (var addon in selectedAddons) {
        addOnsTotal += int.parse(addon.price.toString());
      }

      price += addOnsTotal;
      return price;
    } catch (e, stack) {
      developer.log("Error calculating item price: $e", stackTrace: stack);
      return 0;
    }
  }

  int calculateItemTotal({ProductModel? productModel}) {
    try {
      int total = calculateItemPrice(productModel: productModel);
      return total * quantity.value;
    } catch (e, stack) {
      developer.log("Error calculating item total: $e", stackTrace: stack);
      return 0;
    }
  }

  void updateQuantity(CartModel cartModel, int newQuantity) {
    try {
      int index = cartItemsList.indexWhere((item) => item.productId == cartModel.productId);
      if (index != -1) {
        cartItemsList[index].quantity = newQuantity;
        cartItemsList[index].totalAmount = (cartItemsList[index].itemPrice! * cartItemsList[index].quantity!);
        cartItemsList.refresh();
      }
      cartDatabaseHelper.updateCartItem(cartModel);
    } catch (e, stack) {
      developer.log("Error updating cart quantity: $e", stackTrace: stack);
    }
  }

  void removeItem(CartModel cartModel) async {
    try {
      String productId = cartModel.productId ?? "";

      await cartDatabaseHelper.deleteCartItemByProductId(productId);

      cartItemsList.removeWhere((item) => item.productId == productId);

      cartItemsList.refresh();
      update();
      ShowToastDialog.showToast("Item Removed From Cart..".tr);
    } catch (error, stack) {
      developer.log("Error removing item from cart: $error", stackTrace: stack);
    }
  }
}
