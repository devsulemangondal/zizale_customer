// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:customer/app/models/addons_model.dart';
import 'package:customer/app/models/cart_model.dart';
import 'package:customer/app/models/product_model.dart';
import 'package:customer/app/models/variation_model.dart';
import 'package:customer/app/models/vendor_model.dart';
import 'package:customer/app/modules/favourites_screen/controllers/favourites_screen_controller.dart';
import 'package:customer/app/modules/restaurant_detail_screen/views/restaurant_detail_screen_view.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/network_image_widget.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/item_tag.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/constant_widgets/container_custom.dart';
import 'package:customer/constant_widgets/login_dialog.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/constant_widgets/top_widget.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/common_ui.dart';
import 'package:customer/themes/screen_size.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FavouritesScreenView extends GetView<FavouritesScreenController> {
  const FavouritesScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<FavouritesScreenController>(
      init: FavouritesScreenController(),
      builder: (controller) {
        return Scaffold(
          appBar: UiInterface.customAppBar(context, themeChange, "", backgroundColor: Colors.transparent),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTopWidget(context, "Favourites".tr, "View and manage your favorite restaurants and dishes.".tr),
                  spaceH(height: 24),
                  Row(
                    children: [
                      RoundShapeButton(
                        title: "Restaurant".tr,
                        borderRadius: 50,
                        buttonColor: controller.selectedType.value == 0
                            ? AppThemeData.secondary300
                            : themeChange.isDarkTheme()
                                ? AppThemeData.grey800
                                : AppThemeData.grey200,
                        buttonTextColor: controller.selectedType.value == 0
                            ? AppThemeData.primaryWhite
                            : themeChange.isDarkTheme()
                                ? AppThemeData.grey400
                                : AppThemeData.grey600,
                        onTap: () {
                          controller.selectedType.value = 0;
                        },
                        size: Size(140.w, 38.h),
                        textSize: 14,
                      ),
                      spaceW(width: 12),
                      RoundShapeButton(
                        title: "Dishes".tr,
                        borderRadius: 50,
                        buttonColor: controller.selectedType.value == 1
                            ? AppThemeData.secondary300
                            : themeChange.isDarkTheme()
                                ? AppThemeData.grey800
                                : AppThemeData.grey200,
                        buttonTextColor: controller.selectedType.value == 1
                            ? AppThemeData.primaryWhite
                            : themeChange.isDarkTheme()
                                ? AppThemeData.grey400
                                : AppThemeData.grey600,
                        onTap: () {
                          controller.selectedType.value = 1;
                        },
                        size: Size(110.w, 38.h),
                        textSize: 14,
                      ),
                    ],
                  ),
                  spaceH(height: 24),
                  if (controller.selectedType.value == 0)
                    controller.isLoading.value
                        ? Constant.loader()
                        : controller.favouriteRestaurantList.isEmpty
                            ? Constant.showEmptyView(context, message: "No Favourite Restaurant Available".tr)
                            : ListView.builder(
                                itemCount: controller.favouriteRestaurantList.length,
                                itemBuilder: (context, index) {
                                  VendorModel restaurant = controller.favouriteRestaurantList[index];
                                  bool isLiked = restaurant.likedUser?.contains(FireStoreUtils.getCurrentUid()) ?? false;
                                  return Padding(
                                    padding: paddingEdgeInsets(horizontal: 0, vertical: 8),
                                    child: Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Get.to(const RestaurantDetailScreenView(), arguments: {"restaurantModel": restaurant});
                                          },
                                          child: Row(
                                            children: [
                                              NetworkImageWidget(
                                                imageUrl: restaurant.coverImage.toString(),
                                                width: 104.w,
                                                height: 116.h,
                                                borderRadius: 10,
                                                fit: BoxFit.cover,
                                              ),
                                              spaceW(width: 12),
                                              SizedBox(
                                                // height: 88.h,
                                                width: 230.w,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    spaceH(height: 6),
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 16),
                                                      child: TextCustom(
                                                        title: restaurant.vendorName.toString(),
                                                        fontSize: 16,
                                                        fontFamily: FontFamily.medium,
                                                        color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        SvgPicture.asset(
                                                          "assets/icons/ic_location.svg",
                                                          height: 14.h,
                                                          width: 11.w,
                                                          color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                        ),
                                                        spaceW(width: 4),
                                                        Expanded(
                                                          child: TextCustom(
                                                            title: restaurant.address!.address.toString(),
                                                            fontSize: 12,
                                                            fontFamily: FontFamily.regular,
                                                            textAlign: TextAlign.start,
                                                            color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    TextCustom(
                                                      title: restaurant.cuisineName.toString(),
                                                      fontSize: 12,
                                                      fontFamily: FontFamily.regular,
                                                      color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                    ),
                                                    Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          "assets/icons/ic_star.svg",
                                                          height: 18.h,
                                                          width: 18.w,
                                                        ),
                                                        spaceW(width: 4),
                                                        TextCustom(
                                                          title: Constant.calculateReview(
                                                            Constant.safeParse(restaurant.reviewSum),
                                                            Constant.safeParse(restaurant.reviewCount),
                                                          ).toStringAsFixed(1),
                                                          fontSize: 14,
                                                          fontFamily: FontFamily.regular,
                                                          color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                                          child: TextCustom(
                                                            title: "|",
                                                            color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400,
                                                          ),
                                                        ),
                                                        TextCustom(
                                                          title: FireStoreUtils.getCurrentUid() == null
                                                              ? "${Constant.calculateDistanceInKm(Constant.currentLocation!.location!.latitude!, Constant.currentLocation!.location!.longitude!, restaurant.address!.location!.latitude!, restaurant.address!.location!.longitude!)} km"
                                                              : "${Constant.calculateDistanceInKm(Constant.userModel!.addAddresses!.first.location!.latitude!, Constant.userModel!.addAddresses!.first.location!.longitude!, restaurant.address!.location!.latitude!, restaurant.address!.location!.longitude!)} km",
                                                          fontSize: 14,
                                                          fontFamily: FontFamily.light,
                                                          color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                                        ),
                                                      ],
                                                    ),
                                                    spaceH(height: 6)
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                            top: 0,
                                            right: 0,
                                            child: GestureDetector(
                                              onTap: () async {
                                                if (FireStoreUtils.getCurrentUid() != null) {
                                                  if (Constant.isRestaurantOpen(restaurant)) {
                                                    if (isLiked) {
                                                      restaurant.likedUser!.remove(FireStoreUtils.getCurrentUid());
                                                      controller.getFavouriteRestaurant();
                                                    } else {
                                                      restaurant.likedUser!.add(FireStoreUtils.getCurrentUid());
                                                    }
                                                    await FireStoreUtils.updateRestaurant(restaurant);
                                                    controller.favouriteRestaurantList.refresh();
                                                  } else {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return Dialog(
                                                            child: LoginDialog(),
                                                          );
                                                        });
                                                  }
                                                }
                                              },
                                              child: isLiked ? SvgPicture.asset("assets/icons/ic_fill_favourite.svg") : SvgPicture.asset("assets/icons/ic_favorite.svg"),
                                            ))
                                      ],
                                    ),
                                  );
                                },
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                              ),
                  if (controller.selectedType.value == 1)
                    Obx(
                      () => controller.isLoading.value
                          ? Constant.loader()
                          : controller.favouriteDishesList.isEmpty
                              ? Constant.showEmptyView(context, message: "No Favourite Dishes Available".tr)
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: controller.favouriteDishesList.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    ProductModel product = controller.favouriteDishesList[index];
                                    bool isLiked = product.likedUser?.contains(FireStoreUtils.getCurrentUid()) ?? false;
                                    bool isItemInCart = controller.cartItemsList.any((cartItem) => cartItem.productId == product.id);
                                    CartModel? cartModel = isItemInCart ? controller.cartItemsList.firstWhere((cartItem) => cartItem.productId == product.id) : null;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 20),
                                      child: FittedBox(
                                        child: Row(
                                          children: [
                                            Stack(
                                              children: [
                                                NetworkImageWidget(
                                                  imageUrl: product.productImage.toString(),
                                                  height: 183.h,
                                                  width: 140.w,
                                                  fit: BoxFit.cover,
                                                  borderRadius: 8,
                                                ),
                                                Positioned(
                                                  top: 8,
                                                  left: 8,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(color: ItemTag.getItemTagBackgroundColor(product.itemTag.toString(), context), borderRadius: BorderRadius.circular(4)),
                                                    child: TextCustom(
                                                      title: ItemTag.getItemTagTitle(product.itemTag.toString()),
                                                      fontSize: 12,
                                                      fontFamily: FontFamily.medium,
                                                      color: ItemTag.getItemTagTitleColor(product.itemTag.toString(), context),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            spaceW(width: 12),
                                            SizedBox(
                                                width: 202.w,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          "assets/icons/ic_star.svg",
                                                        ),
                                                        spaceW(width: 5),
                                                        TextCustom(
                                                          title: Constant.calculateReview(
                                                            Constant.safeParse(product.reviewSum),
                                                            Constant.safeParse(product.reviewCount),
                                                          ).toStringAsFixed(1),
                                                          fontSize: 14,
                                                          fontFamily: FontFamily.regular,
                                                          color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                        ),
                                                        const Spacer(),
                                                        GestureDetector(
                                                            onTap: () async {
                                                              if (FireStoreUtils.getCurrentUid() != null) {
                                                                if (isLiked) {
                                                                  product.likedUser!.remove(FireStoreUtils.getCurrentUid());
                                                                } else {
                                                                  product.likedUser!.add(FireStoreUtils.getCurrentUid());
                                                                }
                                                                await FireStoreUtils.updateProduct(product);
                                                                controller.favouriteDishesList.refresh();
                                                              } else {
                                                                showDialog(
                                                                    context: context,
                                                                    builder: (context) {
                                                                      return Dialog(
                                                                        child: LoginDialog(),
                                                                      );
                                                                    });
                                                              }
                                                            },
                                                            child: isLiked ? SvgPicture.asset("assets/icons/ic_fill_favourite.svg") : SvgPicture.asset("assets/icons/ic_favorite.svg")),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          "assets/icons/ic_food_type.svg",
                                                          color: product.foodType == "Veg"
                                                              ? themeChange.isDarkTheme()
                                                                  ? AppThemeData.success200
                                                                  : AppThemeData.success400
                                                              : themeChange.isDarkTheme()
                                                                  ? AppThemeData.danger200
                                                                  : AppThemeData.danger400,
                                                          height: 18.h,
                                                          width: 18.w,
                                                        ),
                                                        spaceW(width: 4),
                                                        Expanded(
                                                            child: TextCustom(
                                                          title: product.productName.toString(),
                                                          fontSize: 16,
                                                          fontFamily: FontFamily.medium,
                                                          textAlign: TextAlign.start,
                                                          color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                        ))
                                                      ],
                                                    ),
                                                    TextCustom(
                                                      title: Constant.amountShow(amount: product.price.toString()),
                                                      fontSize: 16,
                                                      fontFamily: FontFamily.bold,
                                                      color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                    ),
                                                    TextCustom(
                                                      title: product.description.toString(),
                                                      fontSize: 14,
                                                      fontFamily: FontFamily.regular,
                                                      color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                                    ),
                                                    spaceH(height: 10),
                                                    (cartModel != null)
                                                        ? Row(
                                                            children: [
                                                              Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppThemeData.orange300)),
                                                                child: Row(
                                                                  children: [
                                                                    InkWell(
                                                                      onTap: () {
                                                                        if (cartModel.quantity != null && cartModel.quantity! > 1) {
                                                                          controller.updateQuantity(cartModel, cartModel.quantity! - 1);
                                                                          controller.favouriteDishesList.refresh();
                                                                        } else {
                                                                          controller.removeItem(cartModel);
                                                                          controller.favouriteDishesList.refresh();
                                                                        }
                                                                      },
                                                                      child: SvgPicture.asset(
                                                                        "assets/icons/ic_minus.svg",
                                                                        height: 20,
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                                                      child: TextCustom(
                                                                        title: cartModel.quantity.toString(),
                                                                        fontSize: 16,
                                                                        fontFamily: FontFamily.medium,
                                                                        color: AppThemeData.orange300,
                                                                      ),
                                                                    ),
                                                                    InkWell(
                                                                      onTap: () {
                                                                        if (int.parse(cartModel.quantity.toString()) >= int.parse(product.maxQuantity.toString())) {
                                                                          ShowToastDialog.showToast("${"You’ve reached the maximum quantity allowed".tr} ${product.maxQuantity}");
                                                                        } else {
                                                                          controller.updateQuantity(cartModel, cartModel.quantity! + 1);
                                                                          controller.favouriteDishesList.refresh();
                                                                        }
                                                                      },
                                                                      child: SvgPicture.asset(
                                                                        "assets/icons/ic_add.svg",
                                                                        height: 20,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : RoundShapeButton(
                                                            title: "Add",
                                                            buttonColor: AppThemeData.orange300,
                                                            buttonTextColor: AppThemeData.primaryWhite,
                                                            onTap: () async {
                                                              if (FireStoreUtils.getCurrentUid() != null) {
                                                                if (product.variationList!.isEmpty && product.addonsList!.isEmpty) {
                                                                  CartModel cartModel = CartModel(
                                                                    productId: product.id,
                                                                    productName: product.productName,
                                                                    customerId: FireStoreUtils.getCurrentUid(),
                                                                    vendorId: product.vendorId,
                                                                    itemPrice: int.parse(product.price.toString()),
                                                                    totalAmount: int.parse(product.price.toString()),
                                                                    quantity: controller.quantity.value,
                                                                  );
                                                                  bool isItemInCart = await controller.cartDatabaseHelper.isItemInCart(cartModel.productId.toString());
                                                                  if (isItemInCart) {
                                                                    ShowToastDialog.showToast("Item Already in cart.".tr);
                                                                    return;
                                                                  }
                                                                  if (controller.cartItemsList.isEmpty) {
                                                                    controller.cartDatabaseHelper.insertCartItem(cartModel).then((value) {
                                                                      // Get.back();
                                                                      controller.cartItemsList.add(cartModel); // ✅ add to observable list
                                                                      controller.favouriteDishesList.refresh();
                                                                      ShowToastDialog.showToast("Item Added to Cart".tr);
                                                                    }).catchError((error) {
                                                                      ShowToastDialog.showToast("Failed to add item to cart".tr);
                                                                    });
                                                                  } else {
                                                                    bool isSameRestaurant = await controller.cartDatabaseHelper.isSameRestaurant(cartModel.vendorId.toString());
                                                                    if (isSameRestaurant) {
                                                                      controller.cartDatabaseHelper.insertCartItem(cartModel).then((value) {
                                                                        // Get.back();
                                                                        controller.cartItemsList.add(cartModel); // ✅ add to observable list
                                                                        controller.favouriteDishesList.refresh();
                                                                        ShowToastDialog.showToast("Item Added to Cart".tr);
                                                                      }).catchError((error) {
                                                                        ShowToastDialog.showToast("Failed to add item to cart".tr);
                                                                      });
                                                                    } else {
                                                                      showDialog(
                                                                          context: Get.context!,
                                                                          builder: (BuildContext context) {
                                                                            return AlertDialog(
                                                                              backgroundColor: themeChange.isDarkTheme() ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
                                                                              title: Column(
                                                                                children: [
                                                                                  TextCustom(
                                                                                    title: "Replace Cart Item ? ".tr,
                                                                                    fontSize: 16,
                                                                                    color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                                                    fontFamily: FontFamily.bold,
                                                                                  ),
                                                                                  spaceH(height: 4),
                                                                                  TextCustom(
                                                                                    title: "Your cart Contains dishes from another Restaurant.do you want to replace dishes from this Restaurant ?".tr,
                                                                                    maxLine: 5,
                                                                                    fontSize: 14,
                                                                                    color: themeChange.isDarkTheme() ? AppThemeData.grey300 : AppThemeData.grey700,
                                                                                  ),
                                                                                  spaceH(height: 16),
                                                                                  Row(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Expanded(
                                                                                        child: RoundShapeButton(
                                                                                            title: "Cancel".tr,
                                                                                            buttonColor: themeChange.isDarkTheme() ? AppThemeData.grey700 : AppThemeData.grey300,
                                                                                            buttonTextColor: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                                                            onTap: () {
                                                                                              Navigator.pop(context);
                                                                                            },
                                                                                            size: Size(0, 38.h)),
                                                                                      ),
                                                                                      spaceW(width: 12),
                                                                                      Expanded(
                                                                                        child: RoundShapeButton(
                                                                                            title: "Replace".tr,
                                                                                            buttonColor: AppThemeData.orange300,
                                                                                            buttonTextColor: AppThemeData.primaryWhite,
                                                                                            onTap: () {
                                                                                              controller.cartDatabaseHelper.clearCart();
                                                                                              controller.cartDatabaseHelper.insertCartItem(cartModel).then((value) {
                                                                                                Get.back();
                                                                                                // Get.back();
                                                                                                controller.cartItemsList.add(cartModel); // ✅ add to observable list
                                                                                                controller.favouriteDishesList.refresh();
                                                                                                ShowToastDialog.showToast("Item Added to Cart".tr);
                                                                                              }).catchError((error) {
                                                                                                ShowToastDialog.showToast("Failed to add item to cart".tr);
                                                                                              });
                                                                                            },
                                                                                            size: Size(0, 38.h)),
                                                                                      ),
                                                                                    ],
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            );
                                                                          });
                                                                    }
                                                                  }
                                                                } else {
                                                                  showModalBottomSheet(
                                                                      context: context,
                                                                      isScrollControlled: true,
                                                                      backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                                                      builder: (context) {
                                                                        return AddonsBottomSheet(
                                                                          isEditing: false,
                                                                          productModel: product,
                                                                          favouritesScreenController: controller,
                                                                          onTap: () async {
                                                                            CartModel cartModel = CartModel(
                                                                              productId: product.id,
                                                                              productName: product.productName,
                                                                              customerId: FireStoreUtils.getCurrentUid(),
                                                                              vendorId: product.vendorId,
                                                                              itemPrice: controller.calculateItemPrice(productModel: product),
                                                                              totalAmount: controller.calculateItemTotal(productModel: product),
                                                                              quantity: controller.quantity.value,
                                                                              addOns: controller.selectedAddons,
                                                                              variation: VariationModel(
                                                                                name: controller.selectedVariationName.value.name,
                                                                                optionList: [controller.selectedOption.value],
                                                                                inStock: controller.selectedVariationName.value.inStock,
                                                                              ),
                                                                                preparationTime: product.preparationTime
                                                                            );
                                                                            bool isItemInCart = await controller.cartDatabaseHelper.isItemInCart(cartModel.productId.toString());
                                                                            if (isItemInCart) {
                                                                              ShowToastDialog.showToast("Item Already in cart.".tr);
                                                                              return;
                                                                            }
                                                                            if (controller.cartItemsList.isEmpty) {
                                                                              controller.cartDatabaseHelper.insertCartItem(cartModel).then((value) {
                                                                                Get.back();
                                                                                controller.cartItemsList.add(cartModel);
                                                                                controller.favouriteDishesList.refresh();
                                                                                ShowToastDialog.showToast("Item Added to Cart".tr);
                                                                              }).catchError((error) {
                                                                                ShowToastDialog.showToast("Failed to add item to cart".tr);
                                                                              });
                                                                            } else {
                                                                              bool isSameRestaurant = await controller.cartDatabaseHelper.isSameRestaurant(cartModel.vendorId.toString());
                                                                              if (isSameRestaurant) {
                                                                                controller.cartDatabaseHelper.insertCartItem(cartModel).then((value) {
                                                                                  Get.back();
                                                                                  controller.cartItemsList.add(cartModel); // ✅ add to observable list
                                                                                  controller.favouriteDishesList.refresh();
                                                                                  ShowToastDialog.showToast("Item Added to Cart".tr);
                                                                                }).catchError((error) {
                                                                                  ShowToastDialog.showToast("Failed to add item to cart".tr);
                                                                                });
                                                                              } else {
                                                                                showDialog(
                                                                                    context: Get.context!,
                                                                                    builder: (BuildContext context) {
                                                                                      return AlertDialog(
                                                                                        backgroundColor: themeChange.isDarkTheme() ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
                                                                                        title: Column(
                                                                                          children: [
                                                                                            TextCustom(
                                                                                              title: "Replace Cart Item ? ".tr,
                                                                                              fontSize: 16,
                                                                                              color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                                                              fontFamily: FontFamily.bold,
                                                                                            ),
                                                                                            spaceH(height: 4),
                                                                                            TextCustom(
                                                                                              title:
                                                                                                  "Your cart Contains dishes from another Restaurant.do you want to replace dishes from this Restaurant ?"
                                                                                                      .tr,
                                                                                              maxLine: 5,
                                                                                              fontSize: 14,
                                                                                              color: themeChange.isDarkTheme() ? AppThemeData.grey300 : AppThemeData.grey700,
                                                                                            ),
                                                                                            spaceH(height: 16),
                                                                                            Row(
                                                                                              mainAxisSize: MainAxisSize.min,
                                                                                              children: [
                                                                                                Expanded(
                                                                                                  child: RoundShapeButton(
                                                                                                      title: "Cancel".tr,
                                                                                                      buttonColor: themeChange.isDarkTheme() ? AppThemeData.grey700 : AppThemeData.grey300,
                                                                                                      buttonTextColor: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                                                                      onTap: () {
                                                                                                        Navigator.pop(context);
                                                                                                      },
                                                                                                      size: Size(0, 38.h)),
                                                                                                ),
                                                                                                spaceW(width: 12),
                                                                                                Expanded(
                                                                                                  child: RoundShapeButton(
                                                                                                      title: "Replace".tr,
                                                                                                      buttonColor: AppThemeData.orange300,
                                                                                                      buttonTextColor: AppThemeData.primaryWhite,
                                                                                                      onTap: () {
                                                                                                        controller.cartDatabaseHelper.clearCart();
                                                                                                        controller.cartDatabaseHelper.insertCartItem(cartModel).then((value) {
                                                                                                          Get.back();
                                                                                                          Get.back();
                                                                                                          controller.cartItemsList.add(cartModel);
                                                                                                          controller.favouriteDishesList.refresh();
                                                                                                          ShowToastDialog.showToast("Item Added to Cart".tr);
                                                                                                        }).catchError((error) {
                                                                                                          ShowToastDialog.showToast("Failed to add item to cart".tr);
                                                                                                        });
                                                                                                      },
                                                                                                      size: Size(0, 38.h)),
                                                                                                ),
                                                                                              ],
                                                                                            )
                                                                                          ],
                                                                                        ),
                                                                                      );
                                                                                    });
                                                                              }
                                                                            }
                                                                          },
                                                                        );
                                                                      });
                                                                }
                                                              } else {
                                                                showDialog(
                                                                    context: context,
                                                                    builder: (context) {
                                                                      return Dialog(
                                                                        child: LoginDialog(),
                                                                      );
                                                                    });
                                                              }
                                                            },
                                                            size: Size(131.w, ScreenSize.height(5, context))),
                                                  ],
                                                ))
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class AddonsBottomSheet extends StatelessWidget {
  final ProductModel productModel;
  final FavouritesScreenController favouritesScreenController;
  final CartModel? cartModel;
  final bool isEditing;
  final Function() onTap;

  const AddonsBottomSheet({super.key, required this.productModel, required this.favouritesScreenController, this.cartModel, this.isEditing = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    if (isEditing == true && cartModel != null) {
      favouritesScreenController.selectedOption.value = OptionModel();
      favouritesScreenController.selectedVariationName.value = VariationModel();
      favouritesScreenController.selectedAddons.clear();
      favouritesScreenController.quantity.value = 1;
      favouritesScreenController.quantity.value = cartModel!.quantity!;
      if (cartModel!.addOns != null && cartModel!.addOns!.isNotEmpty) {
        for (var addon in cartModel!.addOns!) {
          AddonsModel addOns = AddonsModel.fromJson(addon);

          // Check if this addon still exists in product's addons list
          int addOnIndex = productModel.addonsList!.indexWhere((addonName) => addonName.name == addOns.name);

          if (addOnIndex != -1) {
            favouritesScreenController.selectedAddons.add(productModel.addonsList![addOnIndex]);
          }
        }
      }
      if (cartModel!.variation != null) {
        int variationIndex = productModel.variationList!.indexWhere((variation) => variation.name == cartModel!.variation!.name);

        if (variationIndex != -1) {
          favouritesScreenController.selectedVariationName.value = productModel.variationList![variationIndex];

          int optionIndex = productModel.variationList![variationIndex].optionList!.indexWhere((option) => option.name == cartModel!.variation!.optionList!.first.name);

          if (optionIndex != -1) {
            if (productModel.variationList!.isNotEmpty) {
              favouritesScreenController.selectedOption.value = productModel.variationList![variationIndex].optionList![optionIndex];
            }
          }
        }
      }
    } else {
      favouritesScreenController.selectedOption.value = OptionModel();
      favouritesScreenController.selectedVariationName.value = VariationModel();
      favouritesScreenController.selectedAddons.clear();
      favouritesScreenController.quantity.value = 1;
      if (productModel.variationList!.isNotEmpty) {
        favouritesScreenController.selectedVariationName.value = productModel.variationList!.first;
        favouritesScreenController.selectedOption.value = productModel.variationList?.first.optionList?.first ?? OptionModel();
      } else {}
    }
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: AlignmentDirectional.center,
              child: Container(
                height: 8.h,
                width: 72.w,
                decoration: BoxDecoration(color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400, borderRadius: BorderRadius.circular(100)),
              ),
            ),
            spaceH(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey100,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                        ),
                      ),
                    ),
                    spaceH(height: 24),
                    Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/ic_food_type.svg",
                          height: 16.h,
                          width: 16.w,
                          color: productModel.foodType == "Veg"
                              ? themeChange.isDarkTheme()
                                  ? AppThemeData.success200
                                  : AppThemeData.success400
                              : themeChange.isDarkTheme()
                                  ? AppThemeData.danger200
                                  : AppThemeData.danger400,
                        ),
                        spaceW(width: 4),
                        Expanded(
                          child: TextCustom(
                            title: productModel.productName.toString(),
                            fontSize: 20,
                            maxLine: 2,
                            textAlign: TextAlign.start,
                            fontFamily: FontFamily.bold,
                            color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                          ),
                        ),
                      ],
                    ),
                    spaceH(height: 4),
                    TextCustom(
                      title: productModel.description.toString(),
                      fontSize: 16,
                      maxLine: 3,
                      fontFamily: FontFamily.regular,
                      textAlign: TextAlign.start,
                      color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                    ),
                    spaceH(height: 24),
                    (productModel.variationList!.isEmpty)
                        ? const SizedBox()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: productModel.variationList!.length,
                            itemBuilder: (context, index) {
                              VariationModel variation = productModel.variationList![index];
                              if (variation.inStock == true) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextCustom(
                                      title: variation.name.toString(),
                                      textAlign: TextAlign.start,
                                      fontSize: 16,
                                      fontFamily: FontFamily.medium,
                                      color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                    ),
                                    spaceH(height: 8),
                                    ContainerCustom(
                                      padding: const EdgeInsets.fromLTRB(10, 10, 16, 10),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: variation.optionList!.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          OptionModel option = variation.optionList![index];
                                          return Obx(
                                            () => RadioListTile(
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                dense: true,
                                                value: option,
                                                groupValue: favouritesScreenController.selectedOption.value,
                                                fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                                                  if (states.contains(WidgetState.selected)) {
                                                    return AppThemeData.orange300;
                                                  } else {
                                                    return themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600;
                                                  }
                                                }),
                                                title: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    TextCustom(
                                                      title: option.name.toString(),
                                                      textAlign: TextAlign.start,
                                                      fontSize: 16,
                                                      fontFamily: FontFamily.regular,
                                                      color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                    ),
                                                    TextCustom(
                                                      title: Constant.amountShow(amount: option.price),
                                                      textAlign: TextAlign.start,
                                                      fontSize: 16,
                                                      fontFamily: FontFamily.regular,
                                                      color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                    ),
                                                  ],
                                                ),
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    favouritesScreenController.selectedOption.value = value;
                                                    favouritesScreenController.selectedVariationName.value = variation;
                                                  }
                                                }),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox();
                            }),
                    spaceH(height: 20),
                    if (productModel.addonsList!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextCustom(
                            title: "Addons".tr,
                            textAlign: TextAlign.start,
                            fontSize: 16,
                            fontFamily: FontFamily.medium,
                            color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                          ),
                          spaceH(height: 8),
                          ContainerCustom(
                            child: ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: productModel.addonsList!.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  AddonsModel addOns = (productModel.addonsList![index]);
                                  return (addOns.inStock == true)
                                      ? Obx(
                                          () => CheckboxListTile(
                                            dense: true,
                                            contentPadding: const EdgeInsets.all(0),
                                            controlAffinity: ListTileControlAffinity.leading,
                                            checkColor: themeChange.isDarkTheme() ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
                                            activeColor: AppThemeData.orange300,
                                            side: BorderSide(color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600),
                                            value: favouritesScreenController.selectedAddons.any((selectedAddon) => selectedAddon.name == addOns.name),
                                            onChanged: (bool? value) {
                                              if (value == true) {
                                                if (!favouritesScreenController.selectedAddons.any((selectedAddon) => selectedAddon.name == addOns.name)) {
                                                  favouritesScreenController.selectedAddons.add(addOns);
                                                }
                                                // favouritesScreenController.selectedAddons.add(addOns);
                                              } else {
                                                favouritesScreenController.selectedAddons.removeWhere(
                                                  (selectedAddon) => selectedAddon.name == addOns.name,
                                                );
                                                // favouritesScreenController.selectedAddons.remove(addOns);
                                              }
                                            },
                                            title: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: TextCustom(
                                                    title: addOns.name.toString(),
                                                    fontSize: 16,
                                                    fontFamily: FontFamily.regular,
                                                    textAlign: TextAlign.start,
                                                    color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                  ),
                                                ),
                                                spaceW(width: 10),
                                                TextCustom(
                                                  title: Constant.amountShow(amount: addOns.price),
                                                  fontSize: 16,
                                                  fontFamily: FontFamily.regular,
                                                  color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : const SizedBox();
                                }),
                          ),
                        ],
                      ),
                    spaceH(height: 20),
                  ],
                ),
              ),
            ),
            Obx(
              () => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (favouritesScreenController.quantity.value > 1) {
                          favouritesScreenController.quantity.value--;
                        }
                      },
                      child: Container(
                        height: 28.h,
                        width: 28.w,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppThemeData.orange300)),
                        child: Center(child: SvgPicture.asset("assets/icons/ic_minus.svg")),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextCustom(
                        title: "${favouritesScreenController.quantity.value}",
                        fontSize: 16,
                        fontFamily: FontFamily.medium,
                        color: AppThemeData.orange300,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (favouritesScreenController.quantity.value >= int.parse(productModel.maxQuantity.toString())) {
                          ShowToastDialog.showToast("max_qty".trParams({'qty': productModel.maxQuantity.toString()}) .tr);
                        } else {
                          favouritesScreenController.quantity.value++;
                        }
                      },
                      child: Container(
                        height: 28.h,
                        width: 28.w,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppThemeData.orange300)),
                        child: Center(child: SvgPicture.asset("assets/icons/ic_add.svg")),
                      ),
                    ),
                    const Spacer(),
                    RoundShapeButton(
                        title: isEditing == true
                            ? "${"Edit Item |".tr} ${Constant.amountShow(amount: favouritesScreenController.calculateItemTotal(productModel: productModel).toString())}"
                            : "${"Add Item |".tr} ${Constant.amountShow(amount: favouritesScreenController.calculateItemTotal(productModel: productModel).toString())}",
                        buttonColor: AppThemeData.orange300,
                        buttonTextColor: AppThemeData.primaryWhite,
                        size: Size(225.w, ScreenSize.height(6, context)),
                        onTap: onTap),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
