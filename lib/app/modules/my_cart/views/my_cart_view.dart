// ignore_for_file: deprecated_member_use, use_build_context_synchronously, depend_on_referenced_packages
import 'package:customer/app/models/cart_model.dart';
import 'package:customer/app/models/product_model.dart';
import 'package:customer/app/models/tax_model.dart';
import 'package:customer/app/models/variation_model.dart';
import 'package:customer/app/modules/all_restaurant_screen/views/all_restaurant_screen_view.dart';
import 'package:customer/app/modules/coupon_screen/views/coupon_screen_view.dart';
import 'package:customer/app/modules/my_cart/controllers/my_cart_controller.dart';
import 'package:customer/app/modules/my_cart/views/widget/payment_method.dart';
import 'package:customer/app/modules/order_detail_screen/views/widgets/price_row_view.dart';
import 'package:customer/app/modules/restaurant_detail_screen/controllers/restaurant_detail_screen_controller.dart';
import 'package:customer/app/modules/restaurant_detail_screen/views/restaurant_detail_screen_view.dart';
import 'package:customer/app/modules/select_address/controllers/select_address_controller.dart';
import 'package:customer/app/modules/select_address/views/select_address_view.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/network_image_widget.dart';
import 'package:customer/app/widget/text_field_widget.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/constant_widgets/container_custom.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/constant_widgets/top_widget.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/common_ui.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../themes/screen_size.dart';

class MyCartView extends GetView {
  const MyCartView({super.key});

  @override
  Widget build(BuildContext context) {
    final SelectAddressController selectAddressController =
        Get.put(SelectAddressController());
    final RestaurantDetailScreenController restaurantDetailController =
        Get.put(RestaurantDetailScreenController());
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<MyCartController>(
        init: MyCartController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface.customAppBar(context, themeChange, "",
                backgroundColor: Colors.transparent),
            body: RefreshIndicator(
              onRefresh: () async {
                controller.getData();
              },
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: buildTopWidget(
                              context,
                              "My Cart".tr,
                              "Review your selections and customize your order before completing your purchase."
                                  .tr)),
                      spaceH(height: 32),
                      controller.isLoading.value
                          ? Constant.loader()
                          : (controller.cartItems.isEmpty)
                              ? Constant.showEmptyView(context,
                                  message: "Your Cart is Empty".tr)
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextCustom(
                                                title: "Item Details".tr,
                                                fontSize: 16,
                                                fontFamily: FontFamily.medium,
                                                color: themeChange.isDarkTheme()
                                                    ? AppThemeData.grey50
                                                    : AppThemeData.grey1000,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Get.to(
                                                      const AllRestaurantScreenView());
                                                },
                                                child: TextCustom(
                                                  title: "Add Items".tr,
                                                  fontSize: 14,
                                                  fontFamily: FontFamily.medium,
                                                  color: AppThemeData.info300,
                                                  isUnderLine: true,
                                                ),
                                              )
                                            ],
                                          ),
                                          spaceH(height: 8),
                                          ContainerCustom(
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount:
                                                    controller.cartItems.length,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  CartModel cartModel =
                                                      controller
                                                          .cartItems[index];
                                                  return Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          FutureBuilder(
                                                              future: FireStoreUtils
                                                                  .getProductByProductId(
                                                                      cartModel
                                                                          .productId
                                                                          .toString()),
                                                              builder: (context,
                                                                  snapshot) {
                                                                if (!snapshot
                                                                    .hasData) {
                                                                  return Container();
                                                                }
                                                                ProductModel?
                                                                    product =
                                                                    snapshot.data ??
                                                                        ProductModel();
                                                                return SvgPicture
                                                                    .asset(
                                                                  "assets/icons/ic_food_type.svg",
                                                                  height: 16.h,
                                                                  width: 16.w,
                                                                  color: product
                                                                              .foodType ==
                                                                          "Veg"
                                                                      ? themeChange
                                                                              .isDarkTheme()
                                                                          ? AppThemeData
                                                                              .success200
                                                                          : AppThemeData
                                                                              .success400
                                                                      : themeChange
                                                                              .isDarkTheme()
                                                                          ? AppThemeData
                                                                              .danger200
                                                                          : AppThemeData
                                                                              .danger400,
                                                                );
                                                              }),
                                                          spaceW(width: 4),
                                                          Expanded(
                                                            child: TextCustom(
                                                              title: cartModel
                                                                  .productName
                                                                  .toString(),
                                                              fontSize: 16,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              fontFamily:
                                                                  FontFamily
                                                                      .bold,
                                                              color: themeChange
                                                                      .isDarkTheme()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey1000,
                                                            ),
                                                          ),
                                                          spaceW(width: 12),
                                                          Column(
                                                            children: [
                                                              TextCustom(
                                                                title: Constant.amountShow(
                                                                    amount: (cartModel
                                                                        .totalAmount
                                                                        .toString())),
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    FontFamily
                                                                        .medium,
                                                                color: themeChange
                                                                        .isDarkTheme()
                                                                    ? AppThemeData
                                                                        .grey50
                                                                    : AppThemeData
                                                                        .grey1000,
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      if (cartModel
                                                                  .variation !=
                                                              null &&
                                                          cartModel.variation!
                                                                  .name
                                                                  ?.trim()
                                                                  .isNotEmpty ==
                                                              true &&
                                                          (cartModel
                                                                  .variation!
                                                                  .optionList
                                                                  ?.isNotEmpty ??
                                                              false))
                                                        Row(
                                                          children: [
                                                            TextCustom(
                                                              title:
                                                                  "${cartModel.variation!.name.toString().trim()}: ",
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  FontFamily
                                                                      .light,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              color: themeChange
                                                                      .isDarkTheme()
                                                                  ? AppThemeData
                                                                      .grey400
                                                                  : AppThemeData
                                                                      .grey600,
                                                            ),
                                                            TextCustom(
                                                              title: cartModel
                                                                  .variation!
                                                                  .optionList!
                                                                  .first
                                                                  .name
                                                                  .toString(),
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  FontFamily
                                                                      .light,
                                                              color: themeChange
                                                                      .isDarkTheme()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey1000,
                                                            ),
                                                          ],
                                                        ),
                                                      if (cartModel.addOns !=
                                                              null &&
                                                          cartModel.addOns!
                                                              .isNotEmpty)
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextCustom(
                                                              title:
                                                                  "Addons: ".tr,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  FontFamily
                                                                      .light,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              color: themeChange
                                                                      .isDarkTheme()
                                                                  ? AppThemeData
                                                                      .grey400
                                                                  : AppThemeData
                                                                      .grey600,
                                                            ),
                                                            Expanded(
                                                              child: TextCustom(
                                                                title: cartModel
                                                                    .addOns!
                                                                    .map((addon) =>
                                                                        addon['name']
                                                                            .toString())
                                                                    .join(", "),
                                                                fontSize: 14,
                                                                maxLine: 3,
                                                                fontFamily:
                                                                    FontFamily
                                                                        .light,
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                color: themeChange
                                                                        .isDarkTheme()
                                                                    ? AppThemeData
                                                                        .grey50
                                                                    : AppThemeData
                                                                        .grey1000,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      spaceH(height: 10),
                                                      Row(
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              if (cartModel
                                                                          .quantity !=
                                                                      null &&
                                                                  cartModel
                                                                          .quantity! >
                                                                      1) {
                                                                controller.updateQuantity(
                                                                    cartModel,
                                                                    cartModel
                                                                            .quantity! -
                                                                        1);
                                                              } else {
                                                                controller
                                                                    .removeItem(
                                                                        cartModel);
                                                                ShowToastDialog
                                                                    .showToast(
                                                                        "Item removed from cart."
                                                                            .tr);
                                                              }
                                                            },
                                                            child: Container(
                                                              height: 28.h,
                                                              width: 28.w,
                                                              decoration: BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  border: Border.all(
                                                                      color: AppThemeData
                                                                          .orange300)),
                                                              child: Center(
                                                                  child: SvgPicture
                                                                      .asset(
                                                                          "assets/icons/ic_minus.svg")),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10),
                                                            child: TextCustom(
                                                              title:
                                                                  "${cartModel.quantity}",
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  FontFamily
                                                                      .medium,
                                                              color: AppThemeData
                                                                  .orange300,
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              if (int.parse(cartModel
                                                                      .quantity
                                                                      .toString()) >=
                                                                  5) {
                                                                ShowToastDialog
                                                                    .showToast(
                                                                        "you can only add 5 Items.."
                                                                            .tr);
                                                              } else {
                                                                controller.updateQuantity(
                                                                    cartModel,
                                                                    cartModel
                                                                            .quantity! +
                                                                        1);
                                                              }
                                                            },
                                                            child: Container(
                                                              height: 28.h,
                                                              width: 28.w,
                                                              decoration: BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  border: Border.all(
                                                                      color: AppThemeData
                                                                          .orange300)),
                                                              child: Center(
                                                                  child: SvgPicture
                                                                      .asset(
                                                                          "assets/icons/ic_add.svg")),
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          if (cartModel
                                                                  .variation !=
                                                              null)
                                                            GestureDetector(
                                                              onTap: () async {
                                                                ProductModel?
                                                                    product =
                                                                    await FireStoreUtils.getProductByProductId(cartModel
                                                                        .productId
                                                                        .toString());
                                                                if (product !=
                                                                    null) {
                                                                  showModalBottomSheet(
                                                                      context:
                                                                          context,
                                                                      isScrollControlled:
                                                                          true,
                                                                      backgroundColor: themeChange.isDarkTheme()
                                                                          ? AppThemeData
                                                                              .grey1000
                                                                          : AppThemeData
                                                                              .grey50,
                                                                      builder:
                                                                          (context) {
                                                                        return AddonsBottomSheet(
                                                                          productModel:
                                                                              product,
                                                                          detailController:
                                                                              restaurantDetailController,
                                                                          cartModel:
                                                                              cartModel,
                                                                          isEditing:
                                                                              true,
                                                                          onTap:
                                                                              () async {
                                                                            CartModel cartModel = CartModel(
                                                                                productId: product.id,
                                                                                productName: product.productName,
                                                                                customerId: FireStoreUtils.getCurrentUid(),
                                                                                vendorId: product.vendorId,
                                                                                itemPrice: restaurantDetailController.calculateItemPrice(productModel: product),
                                                                                totalAmount: restaurantDetailController.calculateItemTotal(productModel: product),
                                                                                quantity: restaurantDetailController.quantity.value,
                                                                                addOns: restaurantDetailController.selectedAddons,
                                                                                variation: VariationModel(
                                                                                  name: restaurantDetailController.selectedVariationName.value.name,
                                                                                  optionList: [
                                                                                    restaurantDetailController.selectedOption.value
                                                                                  ],
                                                                                  inStock: restaurantDetailController.selectedVariationName.value.inStock,
                                                                                ),
                                                                                preparationTime: product.preparationTime);

                                                                            await controller.cartDatabaseHelper.updateCartItem(cartModel).then((value) {
                                                                              Get.back();
                                                                              controller.getData();
                                                                              ShowToastDialog.showToast("Item updated successfully.".tr);
                                                                            }).catchError((error) {});
                                                                          },
                                                                        );
                                                                      });
                                                                } else {
                                                                  ShowToastDialog
                                                                      .showToast(
                                                                          "Product details unavailable."
                                                                              .tr);
                                                                }
                                                              },
                                                              child: SvgPicture
                                                                  .asset(
                                                                "assets/icons/ic_edit_2.svg",
                                                                height: 22,
                                                              ),
                                                            ),
                                                          spaceW(width: 12),
                                                          GestureDetector(
                                                            onTap: () {
                                                              controller
                                                                  .removeItem(
                                                                      cartModel);
                                                              ShowToastDialog
                                                                  .showToast(
                                                                      "Item removed from cart."
                                                                          .tr);
                                                            },
                                                            child: SvgPicture
                                                                .asset(
                                                              "assets/icons/ic_delete.svg",
                                                              height: 22,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      if (index !=
                                                          controller.cartItems
                                                                  .length -
                                                              1)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 12),
                                                          child: Divider(
                                                            color: themeChange
                                                                    .isDarkTheme()
                                                                ? AppThemeData
                                                                    .grey700
                                                                : AppThemeData
                                                                    .grey300,
                                                          ),
                                                        ),
                                                    ],
                                                  );
                                                }),
                                          ),
                                        ],
                                      ),
                                    ),
                                    spaceH(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: TextFieldWidget(
                                        title: "Add Cooking Request".tr,
                                        controller:
                                            controller.cookingInstruction.value,
                                        onPress: () {},
                                        hintText: '',
                                      ),
                                    ),
                                    spaceH(height: 24),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: TextCustom(
                                            title: "People also order".tr,
                                            fontSize: 16,
                                            fontFamily: FontFamily.medium,
                                            color: themeChange.isDarkTheme()
                                                ? AppThemeData.grey50
                                                : AppThemeData.grey1000,
                                          ),
                                        ),
                                        spaceH(height: 8),
                                        SizedBox(
                                          height: 181.h,
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount:
                                                  controller.productList.length,
                                              scrollDirection: Axis.horizontal,
                                              padding: const EdgeInsets.only(
                                                  left: 16),
                                              itemBuilder: (context, index) {
                                                ProductModel productModel =
                                                    controller
                                                        .productList[index];
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 12),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        height: 181.h,
                                                        width: 115.w,
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Stack(
                                                              alignment:
                                                                  AlignmentDirectional
                                                                      .bottomEnd,
                                                              children: [
                                                                NetworkImageWidget(
                                                                  imageUrl: productModel
                                                                      .productImage
                                                                      .toString(),
                                                                  height: 119.h,
                                                                  width: 115.w,
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  borderRadius:
                                                                      8,
                                                                ),
                                                                GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    CartModel
                                                                        cartModel =
                                                                        CartModel(
                                                                      productId:
                                                                          productModel
                                                                              .id,
                                                                      productName:
                                                                          productModel
                                                                              .productName,
                                                                      customerId:
                                                                          FireStoreUtils
                                                                              .getCurrentUid(),
                                                                      vendorId:
                                                                          productModel
                                                                              .vendorId,
                                                                      itemPrice: productModel
                                                                          .price
                                                                          .toInt(),
                                                                      totalAmount:
                                                                          productModel.price.toInt() *
                                                                              1,
                                                                      quantity:
                                                                          1,
                                                                    );

                                                                    bool isItemInCart = await restaurantDetailController
                                                                        .cartDatabaseHelper
                                                                        .isItemInCart(cartModel
                                                                            .productId
                                                                            .toString());
                                                                    if (isItemInCart) {
                                                                      ShowToastDialog.showToast(
                                                                          "This item is already in your cart."
                                                                              .tr);
                                                                      return;
                                                                    } else {
                                                                      restaurantDetailController
                                                                          .cartDatabaseHelper
                                                                          .insertCartItem(
                                                                              cartModel)
                                                                          .then(
                                                                              (value) {
                                                                        controller
                                                                            .getCartItems();
                                                                        ShowToastDialog.showToast(
                                                                            "Item added to cart.".tr);
                                                                      }).catchError(
                                                                              (error) {});
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    margin: const EdgeInsets
                                                                        .fromLTRB(
                                                                        0,
                                                                        0,
                                                                        8,
                                                                        8),
                                                                    height:
                                                                        28.h,
                                                                    width: 28.w,
                                                                    decoration: BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        color: themeChange.isDarkTheme()
                                                                            ? AppThemeData.grey1000
                                                                            : AppThemeData.grey50),
                                                                    child:
                                                                        Center(
                                                                      child: SvgPicture
                                                                          .asset(
                                                                              "assets/icons/ic_add.svg"),
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            spaceH(height: 8),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    SvgPicture
                                                                        .asset(
                                                                      "assets/icons/ic_food_type.svg",
                                                                      color: productModel.foodType ==
                                                                              "Veg"
                                                                          ? themeChange.isDarkTheme()
                                                                              ? AppThemeData.success200
                                                                              : AppThemeData.success400
                                                                          : themeChange.isDarkTheme()
                                                                              ? AppThemeData.danger200
                                                                              : AppThemeData.danger400,
                                                                      height:
                                                                          14.h,
                                                                      width:
                                                                          14.w,
                                                                    ),
                                                                    spaceW(
                                                                        width:
                                                                            4),
                                                                    Expanded(
                                                                      child:
                                                                          TextCustom(
                                                                        title: productModel
                                                                            .productName
                                                                            .toString(),
                                                                        fontSize:
                                                                            14,
                                                                        fontFamily:
                                                                            FontFamily.light,
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        color: themeChange.isDarkTheme()
                                                                            ? AppThemeData.grey50
                                                                            : AppThemeData.grey1000,
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                TextCustom(
                                                                  title: Constant.amountShow(
                                                                      amount: productModel
                                                                          .price
                                                                          .toString()),
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      FontFamily
                                                                          .regular,
                                                                  color: themeChange.isDarkTheme()
                                                                      ? AppThemeData
                                                                          .grey50
                                                                      : AppThemeData
                                                                          .grey1000,
                                                                )
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                        ),
                                      ],
                                    ),
                                    spaceH(height: 24),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextCustom(
                                            title: "Offers".tr,
                                            fontSize: 14,
                                            fontFamily: FontFamily.medium,
                                            color: themeChange.isDarkTheme()
                                                ? AppThemeData.grey50
                                                : AppThemeData.grey1000,
                                          ),
                                          spaceH(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: themeChange.isDarkTheme()
                                                    ? AppThemeData.secondary600
                                                    : AppThemeData.secondary50),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  "assets/animation/offer.gif",
                                                  height: 34.h,
                                                ),
                                                spaceW(width: 4),
                                                Expanded(
                                                  child: controller.couponCode
                                                          .value.isEmpty
                                                      ? Row(
                                                          children: [
                                                            Expanded(
                                                              child: TextCustom(
                                                                title:
                                                                    "Apply coupon code for discount"
                                                                        .tr,
                                                                fontSize: 12,
                                                                fontFamily:
                                                                    FontFamily
                                                                        .light,
                                                                maxLine: 2,
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                color: themeChange
                                                                        .isDarkTheme()
                                                                    ? AppThemeData
                                                                        .grey50
                                                                    : AppThemeData
                                                                        .grey1000,
                                                              ),
                                                            ),
                                                            spaceW(width: 8),
                                                            SvgPicture.asset(
                                                              "assets/icons/ic_arrow_right.svg",
                                                              color: themeChange
                                                                      .isDarkTheme()
                                                                  ? AppThemeData
                                                                      .grey400
                                                                  : AppThemeData
                                                                      .grey600,
                                                            )
                                                          ],
                                                        )
                                                      : Row(
                                                          children: [
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  TextCustom(
                                                                    title: controller
                                                                        .selectedCoupon
                                                                        .value
                                                                        .code
                                                                        .toString(),
                                                                    fontSize:
                                                                        16,
                                                                    fontFamily:
                                                                        FontFamily
                                                                            .medium,
                                                                    maxLine: 2,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    color: themeChange.isDarkTheme()
                                                                        ? AppThemeData
                                                                            .grey50
                                                                        : AppThemeData
                                                                            .grey1000,
                                                                  ),
                                                                  TextCustom(
                                                                    title: controller
                                                                        .selectedCoupon
                                                                        .value
                                                                        .title
                                                                        .toString(),
                                                                    fontSize:
                                                                        12,
                                                                    fontFamily:
                                                                        FontFamily
                                                                            .light,
                                                                    maxLine: 2,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    color: themeChange.isDarkTheme()
                                                                        ? AppThemeData
                                                                            .grey50
                                                                        : AppThemeData
                                                                            .grey1000,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            spaceW(width: 8),
                                                            GestureDetector(
                                                              onTap: () {
                                                                controller
                                                                    .couponCode
                                                                    .value = "";
                                                                controller
                                                                    .couponAmount
                                                                    .value = 0.0;
                                                                controller
                                                                    .update();
                                                              },
                                                              child: TextCustom(
                                                                title:
                                                                    "Remove".tr,
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    FontFamily
                                                                        .bold,
                                                                color: themeChange
                                                                        .isDarkTheme()
                                                                    ? AppThemeData
                                                                        .grey50
                                                                    : AppThemeData
                                                                        .grey1000,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                ),
                                              ],
                                            ),
                                          ).onTap(() {
                                            Get.to(const CouponScreenView());
                                          }),
                                        ],
                                      ),
                                    ),
                                    spaceH(height: 24),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextCustom(
                                            title: "Type".tr,
                                            fontSize: 14,
                                            fontFamily: FontFamily.medium,
                                            color: themeChange.isDarkTheme()
                                                ? AppThemeData.grey50
                                                : AppThemeData.grey1000,
                                          ),
                                          spaceH(height: 8),
                                          ContainerCustom(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 0, vertical: 8),
                                            child: Obx(
                                              () => Row(
                                                children: [
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Radio<String>(
                                                          activeColor:
                                                              AppThemeData
                                                                  .orange300,
                                                          value:
                                                              'home_delivery',
                                                          groupValue: controller
                                                              .selectedDeliveryType
                                                              .value,
                                                          onChanged: (value) {
                                                            controller
                                                                .selectedDeliveryType
                                                                .value = value!;
                                                            controller
                                                                .calculationOfDeliveryCharge();
                                                          },
                                                        ),
                                                        Text(
                                                          "Home Delivery".tr,
                                                          style: TextStyle(
                                                            color: themeChange
                                                                    .isDarkTheme()
                                                                ? AppThemeData
                                                                    .grey100
                                                                : AppThemeData
                                                                    .grey900,
                                                            fontFamily: controller
                                                                        .selectedDeliveryType
                                                                        .value ==
                                                                    'home_delivery'
                                                                ? FontFamily
                                                                    .bold
                                                                : FontFamily
                                                                    .medium,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Radio<String>(
                                                          activeColor:
                                                              AppThemeData
                                                                  .orange300,
                                                          value: 'take_away',
                                                          groupValue: controller
                                                              .selectedDeliveryType
                                                              .value,
                                                          onChanged: (value) {
                                                            controller
                                                                .selectedDeliveryType
                                                                .value = value!;
                                                            controller
                                                                .calculationOfDeliveryCharge();
                                                          },
                                                        ),
                                                        Text(
                                                          "Take Away".tr,
                                                          style: TextStyle(
                                                            color: themeChange
                                                                    .isDarkTheme()
                                                                ? AppThemeData
                                                                    .grey100
                                                                : AppThemeData
                                                                    .grey900,
                                                            fontFamily: controller
                                                                        .selectedDeliveryType
                                                                        .value ==
                                                                    'take_away'
                                                                ? FontFamily
                                                                    .bold
                                                                : FontFamily
                                                                    .medium,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    spaceH(height: 24),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextCustom(
                                            title: "Delivery Address".tr,
                                            fontSize: 16,
                                            fontFamily: FontFamily.medium,
                                            color: themeChange.isDarkTheme()
                                                ? AppThemeData.grey50
                                                : AppThemeData.grey1000,
                                          ),
                                          spaceH(height: 8),
                                          ContainerCustom(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset(
                                                  selectAddressController
                                                              .selectedAddress
                                                              .value
                                                              .addressAs ==
                                                          "Home"
                                                      ? "assets/icons/ic_home2.svg"
                                                      : selectAddressController
                                                                  .selectedAddress
                                                                  .value
                                                                  .addressAs ==
                                                              "Work"
                                                          ? "assets/icons/ic_work.svg"
                                                          : selectAddressController
                                                                      .selectedAddress
                                                                      .value
                                                                      .addressAs ==
                                                                  "Friends and Family"
                                                              ? "assets/icons/ic_user.svg"
                                                              : "assets/icons/ic_location.svg",
                                                  color: AppThemeData.orange300,
                                                ),
                                                spaceW(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      TextCustom(
                                                        title:
                                                            selectAddressController
                                                                .selectedAddress
                                                                .value
                                                                .addressAs
                                                                .toString(),
                                                        fontSize: 14,
                                                        fontFamily:
                                                            FontFamily.light,
                                                        textAlign:
                                                            TextAlign.start,
                                                        color: themeChange
                                                                .isDarkTheme()
                                                            ? AppThemeData
                                                                .grey200
                                                            : AppThemeData
                                                                .grey800,
                                                      ),
                                                      spaceH(height: 2),
                                                      TextCustom(
                                                        title:
                                                            selectAddressController
                                                                .selectedAddress
                                                                .value
                                                                .address
                                                                .toString(),
                                                        fontSize: 16,
                                                        fontFamily:
                                                            FontFamily.medium,
                                                        maxLine: 1,
                                                        textAlign:
                                                            TextAlign.start,
                                                        textOverflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        color: themeChange
                                                                .isDarkTheme()
                                                            ? AppThemeData
                                                                .grey100
                                                            : AppThemeData
                                                                .grey900,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                spaceW(width: 8),
                                                GestureDetector(
                                                    onTap: () {
                                                      Get.to(SelectAddressView(
                                                        isFromCart: true,
                                                      ));
                                                    },
                                                    child: SvgPicture.asset(
                                                        "assets/icons/ic_edit_2.svg")),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    spaceH(height: 24),

                                    // Payment method
                                    if (controller
                                        .selectedPaymentMethod.value.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextCustom(
                                              title: "Payment Method".tr,
                                              fontSize: 16,
                                              fontFamily: FontFamily.medium,
                                              color: themeChange.isDarkTheme()
                                                  ? AppThemeData.grey50
                                                  : AppThemeData.grey1000,
                                            ),
                                            spaceH(height: 8),
                                            ContainerCustom(
                                              child: Row(
                                                children: [
                                                  Container(
                                                      height: 46.h,
                                                      width: 46.w,
                                                      padding: const EdgeInsets.all(
                                                          10),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: themeChange
                                                                .isDarkTheme()
                                                            ? AppThemeData
                                                                .grey1000
                                                            : AppThemeData
                                                                .grey50,
                                                      ),
                                                      child: (controller
                                                                  .selectedPaymentMethod
                                                                  .value ==
                                                              Constant
                                                                  .paymentModel!
                                                                  .wallet!
                                                                  .name)
                                                          ? SvgPicture.asset(
                                                              "assets/icons/ic_wallet2.svg",
                                                              color: AppThemeData
                                                                  .orange300,
                                                            )
                                                          : (controller
                                                                      .selectedPaymentMethod
                                                                      .value ==
                                                                  Constant
                                                                      .paymentModel!
                                                                      .razorpay!
                                                                      .name)
                                                              ? Image.asset(
                                                                  "assets/images/ig_razorpay.png")
                                                              : (controller
                                                                          .selectedPaymentMethod
                                                                          .value ==
                                                                      Constant
                                                                          .paymentModel!
                                                                          .strip!
                                                                          .name)
                                                                  ? Image.asset(
                                                                      "assets/images/ig_stripe.png")
                                                                  : (controller.selectedPaymentMethod.value ==
                                                                          Constant.paymentModel!.payStack!.name)
                                                                      ? Image.asset("assets/images/ig_paystack.png")
                                                                      : (controller.selectedPaymentMethod.value == Constant.paymentModel!.paypal!.name)
                                                                          ? Image.asset("assets/images/ig_paypal.png")
                                                                          : (controller.selectedPaymentMethod.value == Constant.paymentModel!.payFast!.name)
                                                                              ? Image.asset("assets/images/ig_payfast.png")
                                                                              // : (controller.selectedPaymentMethod.value == Constant.paymentModel!.mercadoPago!.name)
                                                                              //     ? Image.asset("assets/images/ig_marcadopago.png")
                                                                              : (controller.selectedPaymentMethod.value == Constant.paymentModel!.flutterWave!.name)
                                                                                  ? Image.asset("assets/images/ig_flutterwave.png")
                                                                                  : (controller.selectedPaymentMethod.value == Constant.paymentModel!.midtrans!.name)
                                                                                      ? Image.asset("assets/images/ig_midtrans.png")
                                                                                      : (controller.selectedPaymentMethod.value == Constant.paymentModel!.xendit!.name)
                                                                                          ? Image.asset("assets/images/ig_xendit.png")
                                                                                          : SvgPicture.asset("assets/icons/ic_cash.svg")),
                                                  const SizedBox(width: 12),
                                                  TextCustom(
                                                    title: controller
                                                        .selectedPaymentMethod
                                                        .value
                                                        .toString(),
                                                    fontSize: 16,
                                                    fontFamily:
                                                        FontFamily.medium,
                                                    color: themeChange
                                                            .isDarkTheme()
                                                        ? AppThemeData.grey100
                                                        : AppThemeData.grey900,
                                                  ),
                                                  const Spacer(),
                                                  GestureDetector(
                                                      onTap: () {
                                                        showModalBottomSheet(
                                                            context: context,
                                                            isScrollControlled:
                                                                true,
                                                            backgroundColor: themeChange
                                                                    .isDarkTheme()
                                                                ? AppThemeData
                                                                    .grey1000
                                                                : AppThemeData
                                                                    .grey50,
                                                            builder: (context) {
                                                              return const PaymentMethodView();
                                                            });
                                                      },
                                                      child: SvgPicture.asset(
                                                          "assets/icons/ic_edit_2.svg"))
                                                ],
                                              ),
                                            ),
                                            spaceH(height: 24),
                                          ],
                                        ),
                                      ),

                                    // Bill Details
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextCustom(
                                            title: "Bill Details".tr,
                                            fontSize: 16,
                                            fontFamily: FontFamily.medium,
                                            color: themeChange.isDarkTheme()
                                                ? AppThemeData.grey50
                                                : AppThemeData.grey1000,
                                          ),
                                          spaceH(height: 8),
                                          ContainerCustom(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                PriceRowView(
                                                    title: "Item Total".tr,
                                                    price: Constant.amountShow(
                                                        amount: controller
                                                            .calculateItemTotal()
                                                            .toString()),
                                                    priceColor: themeChange
                                                            .isDarkTheme()
                                                        ? AppThemeData.grey100
                                                        : AppThemeData.grey900,
                                                    titleColor: const Color(
                                                        0xff656565)),
                                                spaceH(height: 12),
                                                PriceRowView(
                                                    title: "Discount".tr,
                                                    price:
                                                        "-${Constant.amountShow(amount: controller.couponAmount.toString())}",
                                                    priceColor: themeChange
                                                            .isDarkTheme()
                                                        ? AppThemeData
                                                            .success200
                                                        : AppThemeData
                                                            .success400,
                                                    titleColor: const Color(
                                                        0xff656565)),
                                                spaceH(height: 12),
                                                PriceRowView(
                                                    title: "Delivery Fee".tr,
                                                    price: Constant.amountShow(
                                                        amount: controller
                                                            .deliveryFee.value
                                                            .toString()),
                                                    priceColor: AppThemeData
                                                        .secondary300,
                                                    titleColor: const Color(
                                                        0xff656565)),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8),
                                                  child: Dash(
                                                    length: 320.w,
                                                    direction: Axis.horizontal,
                                                    dashColor: themeChange
                                                            .isDarkTheme()
                                                        ? AppThemeData.grey700
                                                        : AppThemeData.grey300,
                                                  ),
                                                ),
                                                Obx(() {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) =>
                                                            TipDialog(
                                                                controller:
                                                                    controller),
                                                      );
                                                    },
                                                    child: PriceRowView(
                                                      title: "Delivery Tip".tr,
                                                      price: controller
                                                              .selectedTip
                                                              .value
                                                              .isEmpty
                                                          ? "Add Tip".tr
                                                          : Constant.amountShow(
                                                              amount: controller
                                                                  .selectedTip
                                                                  .value),
                                                      priceColor: AppThemeData
                                                          .orange300,
                                                      titleColor: const Color(
                                                          0xff656565),
                                                    ),
                                                  );
                                                }),
                                                spaceH(height: 12),
                                                GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                          GSTDetailsPopup(
                                                        controller: controller,
                                                        itemTotal: controller
                                                            .calculateItemTotal(),
                                                        coupon: controller
                                                            .couponAmount.value,
                                                        themeChange:
                                                            themeChange,
                                                      ),
                                                    );
                                                  },
                                                  child: Obx(() {
                                                    double totalTax = controller
                                                            .restaurantTaxAmount
                                                            .value +
                                                        controller
                                                            .deliveryTaxAmount
                                                            .value +
                                                        controller
                                                            .packagingTaxAmount
                                                            .value +
                                                        controller.packagingFee
                                                            .value +
                                                        controller
                                                            .platformFee.value;

                                                    return PriceRowView(
                                                      title: "",
                                                      price:
                                                          Constant.amountShow(
                                                        amount:
                                                            totalTax.toString(),
                                                      ),
                                                      priceColor: themeChange
                                                              .isDarkTheme()
                                                          ? AppThemeData.grey100
                                                          : AppThemeData
                                                              .grey900,
                                                      titleColor: const Color(
                                                          0xff656565),
                                                      titleWidget: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          TextCustom(
                                                            title: "Tax & Other"
                                                                .tr,
                                                            fontSize: 14,
                                                            color: Color(
                                                                0xff656565),
                                                            isUnderLine: true,
                                                          ),
                                                          SizedBox(width: 4),
                                                          Icon(
                                                            Icons.error_outline,
                                                            size: 16,
                                                            color: Color(
                                                                0xff656565),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8),
                                                  child: Dash(
                                                    length: 320.w,
                                                    direction: Axis.horizontal,
                                                    dashColor: themeChange
                                                            .isDarkTheme()
                                                        ? AppThemeData.grey700
                                                        : AppThemeData.grey300,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    TextCustom(
                                                        title: "Total".tr,
                                                        fontSize: 16,
                                                        textAlign:
                                                            TextAlign.start,
                                                        fontFamily:
                                                            FontFamily.regular,
                                                        color: AppThemeData
                                                            .orange300),
                                                    const Spacer(),
                                                    TextCustom(
                                                      title: Constant.amountShow(
                                                          amount: controller
                                                              .calculateFinalAmount()
                                                              .toString()),
                                                      fontSize: 16,
                                                      fontFamily:
                                                          FontFamily.bold,
                                                      color: AppThemeData
                                                          .orange300,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          spaceH(height: 4),
                                          TextFieldWidget(
                                              title:
                                                  "Add Delivery Instruction".tr,
                                              hintText: "",
                                              controller: controller
                                                  .deliveryInstruction.value,
                                              onPress: () {})
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: Visibility(
              visible: controller.cartItems.isNotEmpty,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextCustom(
                          title: "Total Amount".tr,
                          fontSize: 14,
                          color: themeChange.isDarkTheme()
                              ? AppThemeData.grey400
                              : AppThemeData.grey600,
                          fontFamily: FontFamily.light,
                        ),
                        TextCustom(
                          title: Constant.amountShow(
                              amount:
                                  controller.calculateFinalAmount().toString()),
                          fontSize: 18,
                          color: themeChange.isDarkTheme()
                              ? AppThemeData.grey50
                              : AppThemeData.grey1000,
                          fontFamily: FontFamily.bold,
                        )
                      ],
                    ),
                    (controller.selectedPaymentMethod.value.isNotEmpty)
                        ? RoundShapeButton(
                            title: "Place Order".tr,
                            buttonColor: AppThemeData.orange300,
                            buttonTextColor: AppThemeData.primaryWhite,
                            onTap: () async {
                              if (controller.selectedPaymentMethod.value ==
                                  Constant.paymentModel!.cash!.name) {
                                controller.completeOrder(
                                    DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                    false);
                              } else if (controller
                                      .selectedPaymentMethod.value ==
                                  Constant.paymentModel!.wallet!.name) {
                                controller.getProfileData();
                                if (double.parse(controller
                                        .userModel.value.walletAmount
                                        .toString()) >=
                                    controller.calculateFinalAmount()) {
                                  ShowToastDialog.showLoader(
                                      "Please Wait..".tr);
                                  controller.walletPayment();
                                  ShowToastDialog.showToast(
                                      "Payment successful.".tr);
                                  ShowToastDialog.closeLoader();
                                } else {
                                  ShowToastDialog.showToast(
                                      "Insufficient Balance in Wallet Amount"
                                          .tr);
                                }
                              } else if (controller
                                      .selectedPaymentMethod.value ==
                                  Constant.paymentModel!.razorpay!.name) {
                                await controller.razorpayMakePayment(
                                    amount: controller
                                        .calculateFinalAmount()
                                        .toString());
                              } else if (controller
                                      .selectedPaymentMethod.value ==
                                  Constant.paymentModel!.payFast!.name) {
                                controller.payFastPayment(
                                    context: context,
                                    amount: controller
                                        .calculateFinalAmount()
                                        .toString());
                              } else if (controller
                                      .selectedPaymentMethod.value ==
                                  Constant.paymentModel!.payStack!.name) {
                                await controller.payStackPayment(
                                    totalAmount: controller
                                        .calculateFinalAmount()
                                        .toString());
                              } else if (controller
                                      .selectedPaymentMethod.value ==
                                  Constant.paymentModel!.flutterWave!.name) {
                                if (Constant.userModel!.email!.isEmpty ||
                                    Constant.userModel!.email == '') {
                                  ShowToastDialog.closeLoader();
                                  return ShowToastDialog.showToast(
                                      "Add your email address in your profile."
                                          .tr);
                                } else {
                                  await controller.flutterWaveInitiatePayment(
                                      context: context,
                                      amount: controller
                                          .calculateFinalAmount()
                                          .toString());
                                }
                              } else if (controller
                                      .selectedPaymentMethod.value ==
                                  Constant.paymentModel!.strip!.name) {
                                await controller.stripeMakePayment(
                                    amount: controller
                                        .calculateFinalAmount()
                                        .toString());
                              } else if (controller
                                      .selectedPaymentMethod.value ==
                                  Constant.paymentModel!.paypal!.name) {
                                await controller.payPalPayment(
                                    amount: controller
                                        .calculateFinalAmount()
                                        .toString());
                              } else if (controller
                                      .selectedPaymentMethod.value ==
                                  Constant.paymentModel!.mercadoPago!.name) {
                                controller.mercadoPagoMakePayment(
                                    context: context,
                                    amount: controller
                                        .calculateFinalAmount()
                                        .toString());
                              } else if (controller
                                      .selectedPaymentMethod.value ==
                                  Constant.paymentModel!.midtrans!.name) {
                                controller.midtransPayment(
                                    context: context,
                                    amount: controller
                                        .calculateFinalAmount()
                                        .toString());
                              } else if (controller
                                      .selectedPaymentMethod.value ==
                                  Constant.paymentModel!.xendit!.name) {
                                controller.xenditPayment(
                                    context: context,
                                    amount: controller
                                        .calculateFinalAmount()
                                        .toString());
                              }
                            },
                            size: Size(190.w, ScreenSize.height(6, context)))
                        : RoundShapeButton(
                            title: "Proceed to Pay".tr,
                            buttonColor: AppThemeData.orange300,
                            buttonTextColor: AppThemeData.primaryWhite,
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: themeChange.isDarkTheme()
                                      ? AppThemeData.grey1000
                                      : AppThemeData.grey50,
                                  builder: (context) {
                                    return const PaymentMethodView();
                                  });
                            },
                            size: Size(190.w, ScreenSize.height(6, context)))
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class GSTDetailsPopup extends StatelessWidget {
  final MyCartController controller;
  final double itemTotal;
  final double coupon;
  final dynamic themeChange;

  const GSTDetailsPopup({
    super.key,
    required this.controller,
    required this.itemTotal,
    required this.coupon,
    required this.themeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: themeChange.isDarkTheme()
          ? AppThemeData.primaryBlack
          : AppThemeData.primaryWhite,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: themeChange.isDarkTheme()
                    ? AppThemeData.grey900
                    : AppThemeData.grey200,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextCustom(
                    title: "Tax & Other Details".tr,
                    fontSize: 18,
                  ),
                  InkWell(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.close,
                      size: 22,
                      color: themeChange.isDarkTheme()
                          ? AppThemeData.primaryWhite
                          : AppThemeData.primaryBlack,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.deliveryTaxList.length,
                    itemBuilder: (context, index) {
                      TaxModel tax = controller.deliveryTaxList[index];
                      double amount = Constant.calculateTax(
                        amount: controller.deliveryFee.toString(),
                        taxModel: tax,
                      );
                      return PriceRowView(
                        title:
                            "${tax.name} (${tax.isFix == true ? Constant.amountShow(amount: tax.value) : "${tax.value}%"})",
                        price: Constant.amountShow(amount: amount.toString()),
                        priceColor: themeChange.isDarkTheme()
                            ? AppThemeData.grey100
                            : AppThemeData.grey900,
                        titleColor: themeChange.isDarkTheme()
                            ? AppThemeData.grey400
                            : AppThemeData.grey600,
                      );
                    },
                  ),
                  if (controller.deliveryTaxAmount.value > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Dash(
                        length: 276.w,
                        direction: Axis.horizontal,
                        dashColor: themeChange.isDarkTheme()
                            ? AppThemeData.grey700
                            : AppThemeData.grey300,
                      ),
                    ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.restaurantTaxList.length,
                    itemBuilder: (context, index) {
                      TaxModel tax = controller.restaurantTaxList[index];
                      double amount = Constant.calculateTax(
                        amount: (itemTotal - coupon).toString(),
                        taxModel: tax,
                      );
                      return PriceRowView(
                        title:
                            "${tax.name} (${tax.isFix == true ? Constant.amountShow(amount: tax.value) : "${tax.value}%"})",
                        price: Constant.amountShow(amount: amount.toString()),
                        priceColor: themeChange.isDarkTheme()
                            ? AppThemeData.grey100
                            : AppThemeData.grey900,
                        titleColor: themeChange.isDarkTheme()
                            ? AppThemeData.grey400
                            : AppThemeData.grey600,
                      );
                    },
                  ),
                  if (Constant.platFormFeeSetting != null &&
                      Constant.platFormFeeSetting!.platformFeeActive == true &&
                      Constant.platFormFeeSetting!.platformFee != null &&
                      Constant.platFormFeeSetting!.platformFee != "0")
                    PriceRowView(
                      title: "Platform Fee".tr,
                      price: Constant.amountShow(
                          amount: Constant.platFormFeeSetting!.platformFee
                              .toString()),
                      priceColor: AppThemeData.secondary300,
                      titleColor: themeChange.isDarkTheme()
                          ? AppThemeData.grey400
                          : AppThemeData.grey600,
                    ).paddingOnly(top: 10),
                  if (Constant.platFormFeeSetting!.packagingFeeActive == true &&
                      controller.restaurantModel.value.packagingFee != null &&
                      controller.restaurantModel.value.packagingFee!.active ==
                          true &&
                      controller.restaurantModel.value.packagingFee!.price !=
                          null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Dash(
                            length: 276.w,
                            direction: Axis.horizontal,
                            dashColor: themeChange.isDarkTheme()
                                ? AppThemeData.grey700
                                : AppThemeData.grey300,
                          ),
                        ),
                        PriceRowView(
                          title: "Restaurant Packaging Fee".tr,
                          price: Constant.amountShow(
                            amount: controller
                                .restaurantModel.value.packagingFee!.price
                                .toString(),
                          ),
                          priceColor: AppThemeData.secondary300,
                          titleColor: themeChange.isDarkTheme()
                              ? AppThemeData.grey400
                              : AppThemeData.grey600,
                        ),
                        SizedBox(height: 4),
                        TextCustom(
                          title:
                              "(Packaging may vary depending on the restaurant.)"
                                  .tr,
                          fontSize: 12,
                          maxLine: 2,
                          textAlign: TextAlign.start,
                          color: themeChange.isDarkTheme()
                              ? AppThemeData.grey600
                              : AppThemeData.grey400,
                        ),
                      ],
                    ),
                  if (Constant.platFormFeeSetting!.packagingFeeActive == true &&
                      controller.restaurantModel.value.packagingFee != null &&
                      controller.restaurantModel.value.packagingFee!.active ==
                          true &&
                      controller.restaurantModel.value.packagingFee!.price !=
                          null)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: controller.packagingTaxList.length,
                      itemBuilder: (context, index) {
                        TaxModel tax = controller.packagingTaxList[index];
                        double amount = Constant.calculateTax(
                          amount: controller.packagingFee.toString(),
                          taxModel: tax,
                        );
                        return PriceRowView(
                          title:
                              "${tax.name} (${tax.isFix == true ? Constant.amountShow(amount: tax.value) : "${tax.value}%"} )",
                          price: Constant.amountShow(amount: amount.toString()),
                          priceColor: themeChange.isDarkTheme()
                              ? AppThemeData.grey100
                              : AppThemeData.grey900,
                          titleColor: themeChange.isDarkTheme()
                              ? AppThemeData.grey400
                              : AppThemeData.grey600,
                        );
                      },
                    ).paddingOnly(bottom: 10),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TipDialog extends StatelessWidget {
  final MyCartController controller;

  const TipDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    RxString tempTip = controller.selectedTip.value.obs;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: themeChange.isDarkTheme()
          ? AppThemeData.primaryBlack
          : AppThemeData.primaryWhite,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(
              title:
                  "Support your delivery partner! Even a small tip can brighten their day.🚴‍♂️",
              fontSize: 14,
              maxLine: 3,
              color: themeChange.isDarkTheme() ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 20),
            Obx(() {
              return Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                alignment: WrapAlignment.start,
                children: List.generate(
                  controller.tipAmountList.length,
                  (index) {
                    String item = controller.tipAmountList[index];
                    return GestureDetector(
                      onTap: () {
                        tempTip.value = item;
                        if (item != "other") {
                          controller.deliveryTipAmountController.value.clear();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8, right: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: tempTip.value == item
                                ? AppThemeData.secondary300
                                : themeChange.isDarkTheme()
                                    ? AppThemeData.grey800
                                    : AppThemeData.grey200,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: TextCustom(
                            fontSize: 14,
                            title: item == "other"
                                ? "Other".tr
                                : "+ ${Constant.amountShow(amount: item)}",
                            color: tempTip.value == item
                                ? AppThemeData.grey50
                                : themeChange.isDarkTheme()
                                    ? AppThemeData.grey400
                                    : AppThemeData.grey600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            Obx(() {
              if (tempTip.value == "other") {
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      onPress: () {},
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      title: "Add Delivery Tip Amount".tr,
                      controller: controller.deliveryTipAmountController.value,
                      hintText: 'Enter Amount'.tr,
                    ),
                    const SizedBox(height: 15),
                  ],
                );
              }
              return const SizedBox();
            }),
            spaceH(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: RoundShapeButton(
                  title: "Done".tr,
                  buttonColor: AppThemeData.orange300,
                  buttonTextColor: AppThemeData.primaryWhite,
                  onTap: () {
                    if (tempTip.value == "other") {
                      if (controller
                          .deliveryTipAmountController.value.text.isEmpty) {
                        return;
                      }
                      tempTip.value =
                          controller.deliveryTipAmountController.value.text;
                    }
                    controller.selectedTip.value = tempTip.value;
                    Navigator.pop(context);
                  },
                  size: Size(120.w, 42)),
            )
          ],
        ),
      ),
    );
  }
}
