// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:customer/app/models/addons_model.dart';
import 'package:customer/app/models/cart_model.dart';
import 'package:customer/app/models/coupon_model.dart';
import 'package:customer/app/models/product_model.dart';
import 'package:customer/app/models/variation_model.dart';
import 'package:customer/app/modules/my_cart/views/my_cart_view.dart';
import 'package:customer/app/modules/restaurant_detail_screen/controllers/restaurant_detail_screen_controller.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/network_image_widget.dart';
import 'package:customer/app/widget/search_field.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/item_tag.dart';
import 'package:customer/constant_widgets/container_custom.dart';
import 'package:customer/constant_widgets/login_dialog.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/screen_size.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constant/show_toast_dialog.dart';

class RestaurantDetailScreenView extends GetView<RestaurantDetailScreenController> {
  const RestaurantDetailScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<RestaurantDetailScreenController>(
        init: RestaurantDetailScreenController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? const Color(0xff1C1C22) : const Color(0xffFFFFFF),
            bottomNavigationBar: Visibility(
                visible: controller.cartItemsList.any((cartItem) => cartItem.productId!.isNotEmpty),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: RoundShapeButton(
                      title: "GetCartItem_Count".trParams({"getCartItemCount": controller.getCartItemCount().toString()}),
                      buttonColor: AppThemeData.orange300,
                      buttonTextColor: AppThemeData.primaryWhite,
                      onTap: () {
                        Get.to(const MyCartView());
                      },
                      size: Size(0.w, ScreenSize.height(6, context))),
                )),
            body: CustomScrollView(physics: const AlwaysScrollableScrollPhysics(), slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: ExampleAppBar(),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          RichText(
                              text: TextSpan(
                                  text: controller.restaurantModel.value.vendorName.toString(),
                                  style: TextStyle(fontSize: 20, fontFamily: FontFamily.bold, color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000),
                                  children: [
                                TextSpan(
                                    text: " • ${controller.restaurantModel.value.cuisineName.toString()}",
                                    style: TextStyle(fontSize: 16, fontFamily: FontFamily.regular, color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000))
                              ])).expand(),
                          spaceW(width: 4),
                          Constant.showFoodType(name: controller.restaurantModel.value.vendorType.toString())
                        ],
                      ),
                      spaceH(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextCustom(
                              title: controller.restaurantModel.value.address?.address.toString() ?? "",
                              fontSize: 14,
                              maxLine: 2,
                              textAlign: TextAlign.start,
                              textOverflow: TextOverflow.ellipsis,
                              fontFamily: FontFamily.light,
                              color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                            ),
                          ),
                          if (controller.restaurantModel.value.openingHoursList != null && controller.restaurantModel.value.openingHoursList!.isNotEmpty)
                            Align(
                              alignment: FractionalOffset.centerRight,
                              child: Container(
                                  margin: EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 4),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: Constant.isRestaurantOpen(controller.restaurantModel.value)
                                          ? themeChange.isDarkTheme()
                                              ? AppThemeData.secondary600
                                              : AppThemeData.secondary50
                                          : themeChange.isDarkTheme()
                                              ? AppThemeData.danger600
                                              : AppThemeData.danger50),
                                  child: TextCustom(
                                    title: Constant.isRestaurantOpen(controller.restaurantModel.value) ? "Open" : "Closed",
                                    fontSize: 14,
                                    fontFamily: FontFamily.medium,
                                    color: Constant.isRestaurantOpen(controller.restaurantModel.value) ? AppThemeData.secondary300 : AppThemeData.danger300,
                                  )),
                            ),
                        ],
                      ),
                      spaceH(height: 2),
                      Row(
                        children: [
                          SvgPicture.asset("assets/icons/ic_star.svg"),
                          spaceW(width: 4),
                          TextCustom(
                            title: Constant.calculateReview(
                              Constant.safeParse(controller.restaurantModel.value.reviewSum),
                              Constant.safeParse(controller.restaurantModel.value.reviewCount),
                            ).toStringAsFixed(1),
                            fontSize: 14,
                            fontFamily: FontFamily.regular,
                            color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: TextCustom(
                              title: " | ",
                              fontSize: 14,
                              fontFamily: FontFamily.light,
                              color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400,
                            ),
                          ),
                          TextCustom(
                            title: FireStoreUtils.getCurrentUid() == null
                                ? "${Constant.calculateDistanceInKm(Constant.currentLocation!.location!.latitude!, Constant.currentLocation!.location!.longitude!, controller.restaurantModel.value.address!.location!.latitude!, controller.restaurantModel.value.address!.location!.longitude!)} km"
                                : "${Constant.calculateDistanceInKm(Constant.userModel!.addAddresses!.first.location!.latitude!, Constant.userModel!.addAddresses!.first.location!.longitude!, controller.restaurantModel.value.address!.location!.latitude!, controller.restaurantModel.value.address!.location!.longitude!)} km",
                            fontSize: 14,
                            fontFamily: FontFamily.light,
                            color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                          ),
                        ],
                      ),
                      spaceH(height: 16),
                      controller.restaurantOfferList.isEmpty
                          ? const SizedBox()
                          : SizedBox(
                              height: 65,
                              width: ScreenSize.width(100, context),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal, // Ensure horizontal scroll
                                itemCount: controller.restaurantOfferList.length,
                                itemBuilder: (context, index) {
                                  CouponModel couponModel = controller.restaurantOfferList[index];
                                  return Container(
                                    width: ScreenSize.width(80, context),
                                    margin: const EdgeInsets.only(right: 8),
                                    // Optional margin for spacing
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xffD1FAFF), Color(0xffFFFFFF)],
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min, // Ensures column takes minimal vertical space
                                          children: [
                                            TextCustom(
                                              title: couponModel.title!,
                                              fontSize: 16,
                                              fontFamily: FontFamily.medium,
                                              color: AppThemeData.primaryBlack,
                                            ),
                                            TextCustom(
                                              title: "Min_Amount".trParams({
                                                "code": couponModel.code!,
                                                "minAmount": Constant.amountShow(amount: couponModel.minAmount),
                                              }),
                                              //"Use ${couponModel.code!} above ${Constant.amountShow(amount: couponModel.minAmount)}"
                                              fontSize: 12,
                                              fontFamily: FontFamily.light,
                                              color: AppThemeData.primaryBlack,
                                            ),
                                          ],
                                        ),
                                        // const SizedBox(width: 8),
                                        const Spacer(),
                                        Image.asset(
                                          "assets/animation/gift.gif",
                                          height: 46,
                                          width: 46,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ).paddingOnly(bottom: 16),
                      SearchField(
                        controller: controller.searchController.value,
                        onChanged: (value) {
                          controller.searchProducts(value); // Pass 'value' directly
                        },
                        onPress: () {},
                      ),
                      spaceH(height: 16),
                      controller.categoryList.isEmpty
                          ? SizedBox()
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  controller.restaurantModel.value.vendorType == "Both"
                                      ? SizedBox(
                                          height: 44.h,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: controller.foodTypeList.length,
                                            itemBuilder: (context, index) {
                                              final type = controller.foodTypeList[index];
                                              if (type == "All") return const SizedBox();
                                              return Obx(() {
                                                final isSelected = controller.selectedFoodTypes.contains(type);
                                                return GestureDetector(
                                                  onTap: () {
                                                    if (type == "All") {
                                                      controller.selectedFoodTypes.clear();
                                                      controller.selectedFoodTypes.add("All");
                                                    } else {
                                                      controller.selectedFoodTypes.remove("All");
                                                      if (controller.selectedFoodTypes.contains(type)) {
                                                        controller.selectedFoodTypes.remove(type);
                                                      } else {
                                                        controller.selectedFoodTypes.add(type);
                                                      }
                                                    }
                                                    controller.filterProductList();
                                                  },
                                                  child: Container(
                                                    margin: const EdgeInsets.only(right: 8),
                                                    decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? type == "Veg"
                                                                ? themeChange.isDarkTheme()
                                                                    ? AppThemeData.success500
                                                                    : AppThemeData.success50
                                                                : themeChange.isDarkTheme()
                                                                    ? AppThemeData.danger600
                                                                    : AppThemeData.danger50
                                                            : themeChange.isDarkTheme()
                                                                ? AppThemeData.grey900
                                                                : AppThemeData.grey100,
                                                        borderRadius: BorderRadius.circular(10),
                                                        border: Border.all(
                                                            color: isSelected
                                                                ? type == "Veg"
                                                                    ? AppThemeData.success300
                                                                    : AppThemeData.danger300
                                                                : themeChange.isDarkTheme()
                                                                    ? AppThemeData.grey800
                                                                    : AppThemeData.grey200)),
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/icons/ic_food_type.svg',
                                                          width: 16,
                                                          height: 16,
                                                          color: type == "Veg" ? AppThemeData.success300 : AppThemeData.danger300,
                                                        ),
                                                        SizedBox(width: 8),
                                                        TextCustom(
                                                          title: type,
                                                          color: type == "Veg" ? AppThemeData.success300 : AppThemeData.danger300,
                                                        ),
                                                        if (isSelected)
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: 8),
                                                            child: GestureDetector(
                                                              onTap: () {
                                                                controller.selectedFoodTypes.remove(type);
                                                                if (controller.selectedFoodTypes.isEmpty) {
                                                                  controller.selectedFoodTypes.add("All");
                                                                }
                                                                controller.filterProductList();
                                                              },
                                                              child: Icon(
                                                                Icons.close,
                                                                size: 16,
                                                                color: isSelected ? (type == "Veg" ? AppThemeData.success300 : AppThemeData.danger300) : Colors.transparent,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });
                                            },
                                          ),
                                        )
                                      : SizedBox(),
                                  spaceW(width: 8),
                                  Obx(
                                    () => SizedBox(
                                      height: 44.h,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: controller.categoryList.length,
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              controller.selectedCategory.value = controller.categoryList[index];
                                              controller.getSubCategory(controller.selectedCategory.value.id.toString());
                                            },
                                            child: Obx(
                                              () => Container(
                                                margin: const EdgeInsets.only(right: 8),
                                                decoration: BoxDecoration(
                                                    color: controller.selectedCategory.value == controller.categoryList[index]
                                                        ? AppThemeData.secondary300
                                                        : themeChange.isDarkTheme()
                                                            ? AppThemeData.grey800
                                                            : AppThemeData.grey200,
                                                    borderRadius: BorderRadius.circular(30)),
                                                padding: paddingEdgeInsets(horizontal: 16, vertical: 8),
                                                child: Center(
                                                  child: TextCustom(
                                                    title: controller.categoryList[index].categoryName.toString(),
                                                    color: controller.selectedCategory.value == controller.categoryList[index]
                                                        ? AppThemeData.grey50
                                                        : themeChange.isDarkTheme()
                                                            ? AppThemeData.grey400
                                                            : AppThemeData.grey600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).paddingOnly(bottom: 10),
                      Obx(
                        () => ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: controller.subCategoryList.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ListTileTheme(
                              minLeadingWidth: 20,
                              child: Theme(
                                data: ThemeData().copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  onExpansionChanged: (value) {
                                    // controller.isOpen[index] = value;
                                    if (index < controller.isOpen.length) {
                                      controller.isOpen[index] = value;
                                    }
                                    if (value) {
                                      controller.selectedSubCategory.value = controller.subCategoryList[index];
                                      controller.filterProductList();
                                    }
                                  },
                                  tilePadding: paddingEdgeInsets(horizontal: 0, vertical: 0),
                                  minTileHeight: 8,
                                  initiallyExpanded: true,
                                  title: Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextCustom(
                                      title: controller.subCategoryList[index].subCategoryName.toString(),
                                      fontSize: 18,
                                      fontFamily: FontFamily.bold,
                                      color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                    ),
                                  ),
                                  children: [
                                    Obx(
                                      () => controller.filteredProductList.isEmpty
                                          ? Center(
                                              child: TextCustom(
                                                title: "No Item Available Menu".tr,
                                              ),
                                            )
                                          : ListView.builder(
                                              padding: EdgeInsets.zero,
                                              itemCount: controller.filteredProductList.length,
                                              itemBuilder: (context, productIndex) {
                                                ProductModel product = controller.filteredProductList[productIndex];
                                                bool isItemInCart = controller.cartItemsList.any((cartItem) => cartItem.productId == product.id);
                                                CartModel? cartModel = isItemInCart
                                                    ? controller.cartItemsList.firstWhere(
                                                        (cartItem) => cartItem.productId == product.id,
                                                      )
                                                    : null;

                                                if (product.subCategoryId == controller.subCategoryList[index].id) {
                                                  return Padding(
                                                    padding: paddingEdgeInsets(horizontal: 0, vertical: 8),
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
                                                                  decoration: BoxDecoration(
                                                                      color: ItemTag.getItemTagBackgroundColor(product.itemTag.toString(), context),
                                                                      borderRadius: BorderRadius.circular(4)),
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
                                                                              bool isLiked = product.likedUser?.contains(FireStoreUtils.getCurrentUid()) ?? false;
                                                                              if (isLiked) {
                                                                                product.likedUser!.remove(FireStoreUtils.getCurrentUid());
                                                                              } else {
                                                                                product.likedUser!.add(FireStoreUtils.getCurrentUid());
                                                                              }
                                                                              await FireStoreUtils.updateProduct(product);
                                                                              controller.filteredProductList.refresh();
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
                                                                          child: (product.likedUser?.contains(FireStoreUtils.getCurrentUid()) ?? false)
                                                                              ? SvgPicture.asset("assets/icons/ic_fill_favourite.svg")
                                                                              : SvgPicture.asset("assets/icons/ic_favorite.svg")),
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
                                                                  Row(
                                                                    children: [
                                                                      TextCustom(
                                                                        title: Constant.amountShow(amount: "${Constant.getDiscountedPrice(product)}"),
                                                                        fontSize: 16,
                                                                        fontFamily: FontFamily.bold,
                                                                        color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                                      ),
                                                                      spaceW(width: 4),
                                                                      TextCustom(
                                                                        title: Constant.amountShow(amount: product.price.toString()),
                                                                        fontSize: 12,
                                                                        fontFamily: FontFamily.regular,
                                                                        color: AppThemeData.grey500,
                                                                        islineThrough: true,
                                                                      ),
                                                                    ],
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
                                                                              decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(12), border: Border.all(color: AppThemeData.orange300)),
                                                                              child: Row(
                                                                                children: [
                                                                                  InkWell(
                                                                                    onTap: () {
                                                                                      if (cartModel.quantity != null && cartModel.quantity! > 1) {
                                                                                        controller.updateQuantity(cartModel, cartModel.quantity! - 1);
                                                                                      } else {
                                                                                        controller.removeItem(cartModel);
                                                                                        // ShowToastDialog.showToast("Item Removed From Cart..".tr);
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
                                                                                        ShowToastDialog.showToast(
                                                                                            "Max_Quantity".trParams({"maxQuantity": product.maxQuantity.toString()})
                                                                                            // "Max Quantity is ${product.maxQuantity}".tr
                                                                                            );
                                                                                      } else {
                                                                                        controller.updateQuantity(cartModel, cartModel.quantity! + 1);
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
                                                                      : Constant.isRestaurantOpen(controller.restaurantModel.value)
                                                                          ? RoundShapeButton(
                                                                              title: "Add".tr,
                                                                              buttonColor: AppThemeData.orange300,
                                                                              buttonTextColor: AppThemeData.primaryWhite,
                                                                              onTap: () async {
                                                                                if (FireStoreUtils.getCurrentUid() != null) {
                                                                                  showModalBottomSheet(
                                                                                    context: context,
                                                                                    isScrollControlled: true,
                                                                                    backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                                                                    builder: (context) {
                                                                                      return AddonsBottomSheet(
                                                                                        isEditing: false,
                                                                                        productModel: product,
                                                                                        detailController: controller,
                                                                                        onTap: () async {
                                                                                          CartModel cartModel = CartModel(
                                                                                            productId: product.id,
                                                                                            productName: product.productName,
                                                                                            customerId: FireStoreUtils.getCurrentUid(),
                                                                                            vendorId: product.vendorId,
                                                                                            itemPrice: product.variationList!.isEmpty && product.addonsList!.isEmpty
                                                                                                ? Constant.getDiscountedPrice(product).toInt()
                                                                                                : controller.calculateItemPrice(productModel: product),
                                                                                            totalAmount: product.variationList!.isEmpty && product.addonsList!.isEmpty
                                                                                                ? Constant.getDiscountedPrice(product).toInt()
                                                                                                : controller.calculateItemTotal(productModel: product),
                                                                                            quantity: controller.quantity.value,
                                                                                            addOns: product.addonsList!.isEmpty ? [] : controller.selectedAddons,
                                                                                            variation: product.variationList!.isEmpty
                                                                                                ? null
                                                                                                : VariationModel(
                                                                                                    name: controller.selectedVariationName.value.name,
                                                                                                    optionList: [controller.selectedOption.value],
                                                                                                    inStock: controller.selectedVariationName.value.inStock,
                                                                                                  ),
                                                                                            preparationTime: product.preparationTime,
                                                                                          );

                                                                                          log("+++++++++++++ ${cartModel.toJson()}");
                                                                                          // ✅ Insert into cart logic inline
                                                                                          bool isItemInCart =
                                                                                              await controller.cartDatabaseHelper.isItemInCart(cartModel.productId.toString());

                                                                                          if (isItemInCart) {
                                                                                            ShowToastDialog.showToast("Item Already in cart.".tr);
                                                                                            return;
                                                                                          }

                                                                                          if (controller.cartItemsList.isEmpty) {
                                                                                            controller.cartDatabaseHelper.insertCartItem(cartModel).then((value) {
                                                                                              Get.back();
                                                                                              controller.cartItemsList.add(cartModel);
                                                                                              controller.cartItemsList.refresh();
                                                                                              ShowToastDialog.showToast("Item Added to Cart".tr);
                                                                                            }).catchError((error) {
                                                                                              ShowToastDialog.showToast("Failed to add item to cart".tr);
                                                                                            });
                                                                                          } else {
                                                                                            bool isSameRestaurant =
                                                                                                await controller.cartDatabaseHelper.isSameRestaurant(cartModel.vendorId.toString());

                                                                                            if (isSameRestaurant) {
                                                                                              controller.cartDatabaseHelper.insertCartItem(cartModel).then((value) {
                                                                                                Get.back();
                                                                                                controller.cartItemsList.add(cartModel);
                                                                                                controller.cartItemsList.refresh();
                                                                                                ShowToastDialog.showToast("Item Added to Cart".tr);
                                                                                              }).catchError((error) {
                                                                                                ShowToastDialog.showToast("Failed to add item to cart".tr);
                                                                                              });
                                                                                            } else {
                                                                                              showDialog(
                                                                                                context: Get.context!,
                                                                                                builder: (BuildContext context) {
                                                                                                  return AlertDialog(
                                                                                                    backgroundColor: themeChange.isDarkTheme()
                                                                                                        ? AppThemeData.primaryBlack
                                                                                                        : AppThemeData.primaryWhite,
                                                                                                    title: Column(
                                                                                                      children: [
                                                                                                        TextCustom(
                                                                                                          title: "Replace Cart Item ? ".tr,
                                                                                                          fontSize: 16,
                                                                                                          color: themeChange.isDarkTheme()
                                                                                                              ? AppThemeData.grey50
                                                                                                              : AppThemeData.grey1000,
                                                                                                          fontFamily: FontFamily.bold,
                                                                                                        ),
                                                                                                        spaceH(height: 4),
                                                                                                        TextCustom(
                                                                                                          title:
                                                                                                              "Your cart Contains dishes from another Restaurant. Do you want to replace dishes from this Restaurant ?"
                                                                                                                  .tr,
                                                                                                          maxLine: 5,
                                                                                                          fontSize: 14,
                                                                                                          color: themeChange.isDarkTheme()
                                                                                                              ? AppThemeData.grey300
                                                                                                              : AppThemeData.grey700,
                                                                                                        ),
                                                                                                        spaceH(height: 16),
                                                                                                        Row(
                                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                                          children: [
                                                                                                            Expanded(
                                                                                                              child: RoundShapeButton(
                                                                                                                title: "Cancel".tr,
                                                                                                                buttonColor: themeChange.isDarkTheme()
                                                                                                                    ? AppThemeData.grey700
                                                                                                                    : AppThemeData.grey300,
                                                                                                                buttonTextColor: themeChange.isDarkTheme()
                                                                                                                    ? AppThemeData.grey50
                                                                                                                    : AppThemeData.grey1000,
                                                                                                                onTap: () {
                                                                                                                  Navigator.pop(context);
                                                                                                                },
                                                                                                                size: Size(0, 38.h),
                                                                                                              ),
                                                                                                            ),
                                                                                                            spaceW(width: 12),
                                                                                                            Expanded(
                                                                                                              child: RoundShapeButton(
                                                                                                                title: "Replace".tr,
                                                                                                                buttonColor: AppThemeData.orange300,
                                                                                                                buttonTextColor: AppThemeData.primaryWhite,
                                                                                                                onTap: () {
                                                                                                                  controller.cartDatabaseHelper.clearCart();
                                                                                                                  controller.cartDatabaseHelper
                                                                                                                      .insertCartItem(cartModel)
                                                                                                                      .then((value) {
                                                                                                                    Get.back();
                                                                                                                    Get.back();
                                                                                                                    controller.cartItemsList.add(cartModel);
                                                                                                                    controller.cartItemsList.refresh();
                                                                                                                    ShowToastDialog.showToast("Item Added to Cart".tr);
                                                                                                                  }).catchError((error) {
                                                                                                                    ShowToastDialog.showToast("Failed to add item to cart".tr);
                                                                                                                  });
                                                                                                                },
                                                                                                                size: Size(0, 38.h),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ],
                                                                                                        )
                                                                                                      ],
                                                                                                    ),
                                                                                                  );
                                                                                                },
                                                                                              );
                                                                                            }
                                                                                          }
                                                                                        },
                                                                                      );
                                                                                    },
                                                                                  );
                                                                                } else {
                                                                                  showDialog(
                                                                                    context: context,
                                                                                    builder: (context) {
                                                                                      return Dialog(
                                                                                        child: LoginDialog(),
                                                                                      );
                                                                                    },
                                                                                  );
                                                                                }
                                                                              },
                                                                              size: Size(131.w, ScreenSize.height(5, context)))
                                                                          : SizedBox(),
                                                                ],
                                                              ))
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                                return Container();
                                              },
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                            ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ]),
          );
        });
  }
}

class AddonsBottomSheet extends StatelessWidget {
  final ProductModel productModel;
  final RestaurantDetailScreenController detailController;
  final CartModel? cartModel;
  final bool isEditing;
  final Function() onTap;

  const AddonsBottomSheet({super.key, required this.productModel, required this.detailController, this.cartModel, this.isEditing = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    if (isEditing == true && cartModel != null) {
      detailController.selectedOption.value = OptionModel();
      detailController.selectedVariationName.value = VariationModel();
      detailController.selectedAddons.clear();
      detailController.quantity.value = 1;
      detailController.quantity.value = cartModel!.quantity!;
      if (cartModel!.addOns != null && cartModel!.addOns!.isNotEmpty) {
        for (var addon in cartModel!.addOns!) {
          AddonsModel addOns = AddonsModel.fromJson(addon);

          // Check if this addon still exists in product's addons list
          int addOnIndex = productModel.addonsList!.indexWhere((addonName) => addonName.name == addOns.name);

          if (addOnIndex != -1) {
            detailController.selectedAddons.add(productModel.addonsList![addOnIndex]);
          }
        }
      }
      if (cartModel!.variation != null) {
        int variationIndex = productModel.variationList!.indexWhere((variation) => variation.name == cartModel!.variation!.name);

        if (variationIndex != -1) {
          detailController.selectedVariationName.value = productModel.variationList![variationIndex];

          int optionIndex = productModel.variationList![variationIndex].optionList!.indexWhere((option) => option.name == cartModel!.variation!.optionList!.first.name);

          if (optionIndex != -1) {
            if (productModel.variationList!.isNotEmpty) {
              detailController.selectedOption.value = productModel.variationList![variationIndex].optionList![optionIndex];
            }
          }
        }
      }
    } else {
      detailController.selectedOption.value = OptionModel();
      detailController.selectedVariationName.value = VariationModel();
      detailController.selectedAddons.clear();
      detailController.quantity.value = 1;
      if (productModel.variationList!.isNotEmpty) {
        detailController.selectedVariationName.value = productModel.variationList!.first;
        detailController.selectedOption.value = productModel.variationList?.first.optionList?.first ?? OptionModel();
      } else {}
    }
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
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
                    spaceH(height: 16),
                    NetworkImageWidget(
                      imageUrl: productModel.productImage.toString(),
                      width: double.infinity,
                      height: 170.h,
                      borderRadius: 12,
                    ),
                    spaceH(),
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
                        if (productModel.variationList!.isEmpty)
                          TextCustom(
                            title: Constant.amountShow(amount: "${Constant.getDiscountedPrice(productModel)}"),
                            fontSize: 16,
                            fontFamily: FontFamily.bold,
                            color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
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
                                                groupValue: detailController.selectedOption.value,
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
                                                    detailController.selectedOption.value = value;
                                                    detailController.selectedVariationName.value = variation;
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
                                            value: detailController.selectedAddons.any((selectedAddon) => selectedAddon.name == addOns.name),
                                            onChanged: (bool? value) {
                                              if (value == true) {
                                                if (!detailController.selectedAddons.any((selectedAddon) => selectedAddon.name == addOns.name)) {
                                                  detailController.selectedAddons.add(addOns);
                                                }
                                              } else {
                                                detailController.selectedAddons.removeWhere(
                                                  (selectedAddon) => selectedAddon.name == addOns.name,
                                                );
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
                        if (detailController.quantity.value > 1) {
                          detailController.quantity.value--;
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
                        title: "${detailController.quantity.value}",
                        fontSize: 16,
                        fontFamily: FontFamily.medium,
                        color: AppThemeData.orange300,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (detailController.quantity.value >= int.parse(productModel.maxQuantity.toString())) {
                          ShowToastDialog.showToast("max_qty".trParams({"qty": productModel.maxQuantity.toString()})
                              // "you can only add ${productModel.maxQuantity} Items..".tr
                              );
                        } else {
                          detailController.quantity.value++;
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
                            ? "${"Edit Item |"} ${Constant.amountShow(amount: detailController.calculateItemTotal(productModel: productModel).toString())}".tr
                            : "${"Add Item |"} ${Constant.amountShow(amount: detailController.calculateItemTotal(productModel: productModel).toString())}".tr,
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

class ExampleAppBar extends SliverPersistentHeaderDelegate {
  final bottomHeight = 65;
  final extraRadius = 4;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    final themeChange = Provider.of<DarkThemeProvider>(Get.context!);

    final imageTop = -shrinkOffset.clamp(0.0, maxExtent - minExtent - bottomHeight);
    final double clowsingRate = (shrinkOffset == 0 ? 0.0 : (shrinkOffset / (maxExtent - minExtent - bottomHeight))).clamp(0, 1);

    final double opacity = (shrinkOffset == minExtent ? 0.0 : 1.0 - (shrinkOffset.clamp(minExtent, minExtent + 30.h) - minExtent) / 30.h).clamp(0.0, 1.0);

    return GetX<RestaurantDetailScreenController>(
      init: RestaurantDetailScreenController(),
      builder: (controller) {
        final double logoOpacity = (1.0 - clowsingRate * 1.2).clamp(0.0, 1.0);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: imageTop,
              left: 0,
              right: 0,
              child: SizedBox(
                height: maxExtent - bottomHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (Constant.isRestaurantOpen(controller.restaurantModel.value))
                      Opacity(
                        opacity: opacity,
                        child: NetworkImageWidget(
                          imageUrl: controller.restaurantModel.value.coverImage.toString(),
                          height: 255.h,
                          width: ScreenSize.width(100, context),
                          fit: BoxFit.fill,
                        ),
                      ),
                    if (!Constant.isRestaurantOpen(controller.restaurantModel.value))
                      ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ]),
                        child: Opacity(
                          opacity: opacity,
                          child: NetworkImageWidget(
                            imageUrl: controller.restaurantModel.value.coverImage.toString(),
                            height: 255.h,
                            width: ScreenSize.width(100, context),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    if (!Constant.isRestaurantOpen(controller.restaurantModel.value))
                      Container(
                        color: Colors.black.withOpacity(0.45),
                      ),
                    if (!Constant.isRestaurantOpen(controller.restaurantModel.value))
                      Center(
                        child: Transform.rotate(
                          angle: -0.30,
                          child: Image.asset(
                            "assets/icons/ic_close.png",
                            width: 90,
                            height: 90,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: (maxExtent - 120.h / 2 - bottomHeight),
              left: 16.w,
              child: AnimatedOpacity(
                opacity: logoOpacity,
                duration: Duration(milliseconds: 150),
                child: Transform.scale(
                  scale: 1.0 - (clowsingRate * 0.3),
                  alignment: Alignment.center,
                  child: ClipOval(
                    child: Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        color: Colors.white, // optional
                        shape: BoxShape.circle,
                      ),
                      child: Image.network(
                        controller.restaurantModel.value.logoImage.toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                surfaceTintColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 0, right: 10),
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey100,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, right: 10, bottom: 8, top: 8),
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          size: 18,
                          color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Obx(
                      () => Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey100,
                            ),
                            child: GestureDetector(
                                onTap: () async {
                                  if (FireStoreUtils.getCurrentUid() != null) {
                                    bool isLiked = controller.restaurantModel.value.likedUser?.contains(FireStoreUtils.getCurrentUid()) ?? false;
                                    if (isLiked) {
                                      controller.restaurantModel.value.likedUser!.remove(FireStoreUtils.getCurrentUid());
                                    } else {
                                      controller.restaurantModel.value.likedUser!.add(FireStoreUtils.getCurrentUid());
                                    }
                                    await FireStoreUtils.updateRestaurant(controller.restaurantModel.value);
                                    controller.restaurantModel.refresh();
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
                                child: (controller.restaurantModel.value.likedUser?.contains(FireStoreUtils.getCurrentUid()) ?? false)
                                    ? SvgPicture.asset(
                                        "assets/icons/ic_fill_favourite.svg",
                                        height: 20,
                                      )
                                    : SvgPicture.asset(
                                        "assets/icons/ic_favorite.svg",
                                        height: 20,
                                        color: themeChange.isDarkTheme() ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
                                      )),
                          ),
                          spaceW(width: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  double get maxExtent => 315.h;

  @override
  double get minExtent => Get.statusBarHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

class InvertedCircleClipper extends CustomClipper<Path> {
  const InvertedCircleClipper({
    required this.offset,
    required this.radius,
  });

  final Offset offset;
  final double radius;

  @override
  Path getClip(size) {
    return Path()
      ..addOval(Rect.fromCircle(
        center: offset,
        radius: radius,
      ))
      ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
