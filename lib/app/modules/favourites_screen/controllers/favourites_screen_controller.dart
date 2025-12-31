import 'dart:developer' as developer;
import 'dart:developer';

import 'package:customer/app/models/cart_model.dart';
import 'package:customer/app/models/product_model.dart';
import 'package:customer/app/models/variation_model.dart';
import 'package:customer/app/models/vendor_model.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/services/database_helper.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class FavouritesScreenController extends GetxController {
  RxBool isLoading = true.obs;
  RxInt selectedType = 0.obs;
  RxList<ProductModel> favouriteDishesList = <ProductModel>[].obs;
  RxList<VendorModel> favouriteRestaurantList = <VendorModel>[].obs;
  RxInt quantity = 1.obs;
  Rx<OptionModel> selectedOption = OptionModel().obs;
  Rx<VariationModel> selectedVariationName = VariationModel().obs;

  RxList selectedAddons = [].obs;
  CartDatabaseHelper cartDatabaseHelper = CartDatabaseHelper();
  RxList<CartModel> cartItemsList = <CartModel>[].obs;
  Rx<VendorModel> restaurantModel = VendorModel().obs;

  @override
  Future<void> onInit() async {
    if (FireStoreUtils.getCurrentUid() != null) {
      getFavouriteDishes();
      getFavouriteRestaurant();
      if (FireStoreUtils.getCurrentUid() != null) {
        cartItemsList.value = await cartDatabaseHelper.getAllCartItems(FireStoreUtils.getCurrentUid().toString());
        if (cartItemsList.isNotEmpty) {
          String? vendorId = cartItemsList.first.vendorId;

          if (vendorId!.isNotEmpty) {
            restaurantModel.value = (await FireStoreUtils.getRestaurant(vendorId))!;
            log("Restaurant Model: ${restaurantModel.value.toJson()}");
          }
        }
      }
    } else {
      favouriteDishesList.clear();
      favouriteRestaurantList.clear();
      isLoading.value = false;
    }

    super.onInit();
  }

  Future<void> getFavouriteDishes() async {
    await FireStoreUtils.getFavouriteDishes().then((value) {
      favouriteDishesList.value = value;
      isLoading.value = false;
    });
  }

  Future<void> getFavouriteRestaurant() async {
    await FireStoreUtils.getFavouriteRestaurant().then((value) {
      favouriteRestaurantList.value = value;
      isLoading.value = false;
    });
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

  int calculateItemTotal({ProductModel? productModel}) {
    try {
      int total = calculateItemPrice(productModel: productModel);
      return total * quantity.value;
    } catch (e, stack) {
      developer.log("Error calculating item total: $e", stackTrace: stack);
      return 0;
    }
  }

  int calculateItemPrice({ProductModel? productModel}) {
    try {
      int price = 0;
      int addOnsTotal = 0;

      if (selectedOption.value.name == null || selectedOption.value.name!.isEmpty) {
        price += int.tryParse(productModel!.price.toString()) ?? 0;
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
}
