// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:customer/app/models/driver_user_model.dart';
import 'package:customer/app/models/owner_model.dart';
import 'package:customer/app/models/product_model.dart';
import 'package:customer/app/models/vendor_model.dart';
import 'package:customer/app/models/tax_model.dart';
import 'package:customer/app/modules/driver_rating_screen/views/driver_rating_screen_view.dart';
import 'package:customer/app/modules/order_detail_screen/controllers/order_detail_screen_controller.dart';
import 'package:customer/app/modules/order_detail_screen/views/widgets/price_row_view.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/network_image_widget.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/order_status.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/constant_widgets/container_custom.dart';
import 'package:customer/constant_widgets/pick_drop_point_view.dart';
import 'package:customer/constant_widgets/top_widget.dart';
import 'package:customer/extension/string_extensions.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/common_ui.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/cart_model.dart';

class OrderDetailScreenView extends GetView<OrderDetailScreenController> {
  const OrderDetailScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<OrderDetailScreenController>(
        init: OrderDetailScreenController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
            appBar: UiInterface.customAppBar(context, themeChange, "", backgroundColor: Colors.transparent),
            body: SingleChildScrollView(
              child: Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: controller.isLoading.value
                      ? Constant.loader()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildTopWidget(context, "Order Details".tr, "View the full details of the customer’s order below.".tr),
                            spaceH(height: 32),
                            TextCustom(
                              title: "Item Details".tr,
                              fontSize: 16,
                              fontFamily: FontFamily.medium,
                              color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                            ),
                            spaceH(height: 8),
                            ContainerCustom(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: controller.bookingModel.value.items!.length,
                                  itemBuilder: (context, index) {
                                    CartModel items = controller.bookingModel.value.items![index];
                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        FutureBuilder(
                                            future: FireStoreUtils.getProductByProductId(items.productId.toString()),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return Container();
                                              }
                                              ProductModel? product = snapshot.data ?? ProductModel();
                                              return SvgPicture.asset(
                                                "assets/icons/ic_food_type.svg",
                                                height: 16.h,
                                                width: 16.w,
                                                color: product.foodType == "Veg"
                                                    ? themeChange.isDarkTheme()
                                                        ? AppThemeData.success200
                                                        : AppThemeData.success400
                                                    : themeChange.isDarkTheme()
                                                        ? AppThemeData.danger200
                                                        : AppThemeData.danger400,
                                              );
                                            }),
                                        spaceW(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              RichText(
                                                  text: TextSpan(
                                                      text: "${items.quantity}x ${items.productName.toString()}",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontFamily: FontFamily.bold,
                                                          color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000),
                                                      children: [
                                                    if (items.variation != null &&
                                                        items.variation!.optionList != null &&
                                                        items.variation!.optionList!.isNotEmpty &&
                                                        items.variation!.optionList!.first.name != null &&
                                                        items.variation!.optionList!.first.name!.trim().isNotEmpty)
                                                      TextSpan(
                                                          text: " (${items.variation!.optionList!.first.name.toString().trim()})",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontFamily: FontFamily.regular,
                                                              color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600))
                                                  ])),
                                            ],
                                          ),
                                        ),
                                        spaceW(width: 16),
                                        TextCustom(
                                          title: Constant.amountShow(amount: controller.bookingModel.value.items![index].totalAmount.toString()),
                                          fontSize: 16,
                                          fontFamily: FontFamily.medium,
                                          color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                        )
                                      ],
                                    );
                                  }),
                            ),
                            spaceH(height: 24),
                            TextCustom(
                              title: "Order Details".tr,
                              fontSize: 16,
                              fontFamily: FontFamily.medium,
                              color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                            ),
                            spaceH(height: 8),
                            ContainerCustom(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      TextCustom(
                                        title: "Order ID".tr,
                                        fontSize: 16,
                                        textAlign: TextAlign.start,
                                        fontFamily: FontFamily.medium,
                                        color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                      ),
                                      const Spacer(),
                                      TextCustom(
                                        title: Constant.showId(controller.bookingModel.value.id.toString()),
                                        fontSize: 16,
                                        fontFamily: FontFamily.medium,
                                        color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                      ),
                                    ],
                                  ),
                                  spaceH(height: 4),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextCustom(
                                        title: "Date".tr,
                                        fontSize: 16,
                                        textAlign: TextAlign.start,
                                        fontFamily: FontFamily.medium,
                                        color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                      ),
                                      spaceW(width: 10),
                                      Expanded(
                                        child: TextCustom(
                                          title:
                                              "${Constant.timestampToDate(controller.bookingModel.value.createdAt!)} at ${Constant.timestampToTime12Hour(controller.bookingModel.value.createdAt!)}",
                                          fontSize: 16,
                                          maxLine: 2,
                                          textAlign: TextAlign.end,
                                          fontFamily: FontFamily.medium,
                                          color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  spaceH(height: 4),
                                  Row(
                                    children: [
                                      TextCustom(
                                        title: "Payment".tr,
                                        fontSize: 16,
                                        textAlign: TextAlign.start,
                                        fontFamily: FontFamily.medium,
                                        color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                      ),
                                      const Spacer(),
                                      TextCustom(
                                        title: controller.bookingModel.value.paymentType.toString(),
                                        fontSize: 16,
                                        fontFamily: FontFamily.medium,
                                        color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                      ),
                                    ],
                                  ),
                                  spaceH(height: 4),
                                  Row(
                                    children: [
                                      TextCustom(
                                        title: "Delivery Type".tr,
                                        fontSize: 16,
                                        textAlign: TextAlign.start,
                                        fontFamily: FontFamily.medium,
                                        color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                      ),
                                      const Spacer(),
                                      TextCustom(
                                        title: controller.bookingModel.value.deliveryType == 'take_away' ? "Take Away".tr : "Home Delivery".tr,
                                        fontSize: 16,
                                        fontFamily: FontFamily.medium,
                                        color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            spaceH(height: 24),
                            TextCustom(
                              title: "Delivery Address".tr,
                              fontSize: 16,
                              fontFamily: FontFamily.medium,
                              color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                            ),
                            spaceH(height: 8),
                            PickDropPointView(
                                pickUpAddress: controller.bookingModel.value.vendorAddress!.address.toString(),
                                dropOutAddress: controller.bookingModel.value.customerAddress!.address.toString()),
                            spaceH(height: 16),
                            TextCustom(
                              title: "Restaurant Details".tr,
                              fontSize: 16,
                              fontFamily: FontFamily.medium,
                              color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                            ),
                            spaceH(height: 6),
                            ContainerCustom(
                              child: FutureBuilder(
                                  future: FireStoreUtils.getRestaurant(controller.bookingModel.value.vendorId.toString()),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Container();
                                    }
                                    VendorModel restaurant = snapshot.data ?? VendorModel();
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                  height: 45.h,
                                                  width: 45.h,
                                                  child: NetworkImageWidget(
                                                    imageUrl: restaurant.coverImage.toString(),
                                                    borderRadius: 50,
                                                  )),
                                              spaceW(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TextCustom(
                                                      title: restaurant.vendorName.toString(),
                                                      fontSize: 16,
                                                      fontFamily: FontFamily.bold,
                                                      textAlign: TextAlign.start,
                                                      color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                                    ),
                                                    TextCustom(
                                                      title: restaurant.address!.address.toString(),
                                                      fontSize: 14,
                                                      maxLine: 1,
                                                      textOverflow: TextOverflow.ellipsis,
                                                      textAlign: TextAlign.start,
                                                      fontFamily: FontFamily.regular,
                                                      color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        spaceW(width: 8),
                                        GestureDetector(
                                          onTap: () async {
                                            ShowToastDialog.showLoader("Please Wait..".tr);
                                            await FireStoreUtils.getOwnerProfile(restaurant.ownerId.toString()).then((value) async {
                                              if (value != null) {
                                                OwnerModel ownerModel = value;
                                                final fullPhoneNumber = '${ownerModel.countryCode}${ownerModel.phoneNumber}';
                                                final url = 'tel:$fullPhoneNumber';
                                                if (await canLaunch(url)) {
                                                  await launch(url);
                                                  ShowToastDialog.closeLoader();
                                                } else {
                                                  ShowToastDialog.closeLoader();
                                                }
                                              }
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: AppThemeData.secondary300,
                                              shape: BoxShape.circle,
                                            ),
                                            child: SvgPicture.asset("assets/icons/ic_phone_call.svg"),
                                          ),
                                        )
                                      ],
                                    );
                                  }),
                            ),
                            // order completed -- driver details
                            if (controller.bookingModel.value.driverId != null && controller.bookingModel.value.driverId!.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  spaceH(height: 24),
                                  TextCustom(
                                    title: "Driver Details".tr,
                                    fontSize: 16,
                                    fontFamily: FontFamily.medium,
                                    color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                  ),
                                  spaceH(height: 8),
                                  ContainerCustom(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        FutureBuilder<DriverUserModel?>(
                                          future: FireStoreUtils.getDriverUserProfile(controller.bookingModel.value.driverId ?? ''),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return Container();
                                            }
                                            DriverUserModel driverUserModel = snapshot.data ?? DriverUserModel();
                                            return Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          SizedBox(
                                                              height: 45.h,
                                                              width: 45.h,
                                                              child: NetworkImageWidget(
                                                                imageUrl: driverUserModel.profileImage.toString(),
                                                                borderRadius: 50,
                                                                isProfile: true,
                                                              )),
                                                          spaceW(width: 8),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                TextCustom(
                                                                  title: driverUserModel.fullNameString().toString(),
                                                                  fontSize: 16,
                                                                  fontFamily: FontFamily.bold,
                                                                  textAlign: TextAlign.start,
                                                                  color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                                                ),
                                                                TextCustom(
                                                                  title: "${driverUserModel.countryCode!.toString()} ${driverUserModel.phoneNumber}",
                                                                  fontSize: 14,
                                                                  maxLine: 1,
                                                                  textOverflow: TextOverflow.ellipsis,
                                                                  textAlign: TextAlign.start,
                                                                  fontFamily: FontFamily.regular,
                                                                  color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    spaceW(width: 8),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        final fullPhoneNumber = '${driverUserModel.countryCode}${driverUserModel.phoneNumber}';
                                                        final url = 'tel:$fullPhoneNumber';
                                                        if (await canLaunch(url)) {
                                                          await launch(url);
                                                        } else {}
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.all(6),
                                                        decoration: const BoxDecoration(
                                                          color: AppThemeData.secondary300,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: SvgPicture.asset("assets/icons/ic_phone_call.svg"),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 50),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  SvgPicture.asset("assets/icons/ic_star.svg"),
                                                  spaceW(width: 4),
                                                  TextCustom(
                                                    title: Constant.calculateReview(
                                                      Constant.safeParse(controller.driverModel.value.reviewSum),
                                                      Constant.safeParse(controller.driverModel.value.reviewCount),
                                                    ).toStringAsFixed(1),
                                                    fontSize: 14,
                                                    fontFamily: FontFamily.regular,
                                                    color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                  ),
                                                ],
                                              ),
                                              if (controller.bookingModel.value.orderStatus == OrderStatus.orderComplete)
                                                InkWell(
                                                    onTap: () {
                                                      Get.to(const DriverRatingScreenView(), arguments: {"bookingModel": controller.bookingModel.value});
                                                    },
                                                    child: TextCustom(
                                                      title: "Rate the Driver".tr,
                                                      fontFamily: FontFamily.medium,
                                                      isUnderLine: true,
                                                      color: AppThemeData.orange300,
                                                    )),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            spaceH(height: 24),
                            TextCustom(
                              title: "Bill Details".tr,
                              fontSize: 16,
                              fontFamily: FontFamily.medium,
                              color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                            ),
                            spaceH(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ContainerCustom(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      PriceRowView(
                                          title: "Item Total".tr,
                                          price: Constant.amountShow(amount: controller.bookingModel.value.subTotal.toString()),
                                          priceColor: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                          titleColor: const Color(0xff656565)),
                                      spaceH(height: 12),
                                      PriceRowView(
                                          title: "Discount".tr,
                                          price: "-${Constant.amountShow(amount: controller.bookingModel.value.discount ?? '0.0')}",
                                          priceColor: themeChange.isDarkTheme() ? AppThemeData.success200 : AppThemeData.success400,
                                          titleColor: const Color(0xff656565)),
                                      spaceH(height: 12),
                                      PriceRowView(
                                          title: "Delivery Fee".tr,
                                          price: Constant.amountShow(amount: controller.bookingModel.value.deliveryCharge.toString()),
                                          priceColor: AppThemeData.secondary300,
                                          titleColor: const Color(0xff656565)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Dash(
                                          length: 320.w,
                                          direction: Axis.horizontal,
                                          dashColor: themeChange.isDarkTheme() ? AppThemeData.grey700 : AppThemeData.grey300,
                                        ),
                                      ),
                                      PriceRowView(
                                          title: "Delivery Tip".tr,
                                          price: Constant.amountShow(amount: controller.bookingModel.value.deliveryTip.toString()),
                                          priceColor: AppThemeData.secondary300,
                                          titleColor: const Color(0xff656565)),
                                      spaceH(height: 12),
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => GSTDetailsPopup(
                                              controller: controller,
                                              coupon: controller.bookingModel.value.discount == null || controller.bookingModel.value.discount.toString().isEmpty
                                                  ? "0"
                                                  : controller.bookingModel.value.discount.toString(),
                                              themeChange: themeChange,
                                            ),
                                          );
                                        },
                                        child: Obx(() {
                                          double totalTax = controller.restaurantTaxAmount.value +
                                              controller.deliveryTaxAmount.value +
                                              controller.packagingTaxAmount.value +
                                              double.parse(controller.bookingModel.value.packagingFee!) +
                                              double.parse(controller.bookingModel.value.platFormFee.toString());

                                          return PriceRowView(
                                            title: "".tr,
                                            price: Constant.amountShow(
                                              amount: totalTax.toString(),
                                            ),
                                            priceColor: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                            titleColor: const Color(0xff656565),
                                            titleWidget: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextCustom(
                                                  title: "Tax & Other".tr,
                                                  fontSize: 14,
                                                  color: Color(0xff656565),
                                                  isUnderLine: true,
                                                ),
                                                SizedBox(width: 4),
                                                Icon(
                                                  Icons.error_outline,
                                                  size: 16,
                                                  color: Color(0xff656565),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Dash(
                                          length: 320.w,
                                          direction: Axis.horizontal,
                                          dashColor: themeChange.isDarkTheme() ? AppThemeData.grey700 : AppThemeData.grey300,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          TextCustom(title: "Total".tr, fontSize: 16, textAlign: TextAlign.start, fontFamily: FontFamily.regular, color: AppThemeData.orange300),
                                          const Spacer(),
                                          Obx(
                                            () => TextCustom(
                                              title: Constant.amountShow(amount: Constant.calculateFinalAmount(controller.bookingModel.value).toString()),
                                              fontSize: 16,
                                              fontFamily: FontFamily.bold,
                                              color: AppThemeData.orange300,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                spaceH(height: 4),
                              ],
                            ),
                            // TextCustom(
                            //   title: "Bill Details".tr,
                            //   fontSize: 16,
                            //   fontFamily: FontFamily.medium,
                            //   color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                            // ),
                            // spaceH(height: 8),
                            // ContainerCustom(
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       PriceRowView(
                            //           title: "Item Total".tr,
                            //           price: Constant.amountShow(amount: controller.bookingModel.value.subTotal.toString()),
                            //           priceColor: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                            //           titleColor: const Color(0xff656565)),
                            //       spaceH(height: 12),
                            //       controller.bookingModel.value.deliveryCharge == '0'
                            //           ? PriceRowView(title: "Delivery Fee".tr, price: "Free", priceColor: AppThemeData.secondary300, titleColor: const Color(0xff656565))
                            //           : PriceRowView(
                            //               title: "Delivery Fee".tr,
                            //               price: Constant.amountShow(amount: controller.bookingModel.value.deliveryCharge.toString()),
                            //               priceColor: AppThemeData.secondary300,
                            //               titleColor: const Color(0xff656565)),
                            //       spaceH(height: 12),
                            //       if (controller.bookingModel.value.platFormFee != null &&
                            //           controller.bookingModel.value.platFormFee!.isNotEmpty &&
                            //           controller.bookingModel.value.platFormFee != '0.0' &&
                            //           controller.bookingModel.value.platFormFee != '0')
                            //         PriceRowView(
                            //                 title: "PlatForm Fee".tr,
                            //                 price: Constant.amountShow(amount: controller.bookingModel.value.platFormFee.toString()),
                            //                 priceColor: AppThemeData.secondary300,
                            //                 titleColor: const Color(0xff656565))
                            //             .paddingOnly(bottom: 12),
                            //       PriceRowView(
                            //           title: "Discount".tr,
                            //           price: "-${Constant.amountShow(amount: controller.bookingModel.value.discount ?? '0.0')}",
                            //           priceColor: themeChange.isDarkTheme() ? AppThemeData.success200 : AppThemeData.success400,
                            //           titleColor: const Color(0xff656565)),
                            //       spaceH(height: 12),
                            //       ListView.builder(
                            //           physics: const NeverScrollableScrollPhysics(),
                            //           shrinkWrap: true,
                            //           itemCount: controller.bookingModel.value.taxList!.length,
                            //           itemBuilder: (context, index) {
                            //             TaxModel taxModel = controller.bookingModel.value.taxList![index];
                            //             return PriceRowView(
                            //                 price: Constant.amountShow(
                            //                     amount: Constant.calculateTax(amount: Constant.amountBeforeTax(controller.bookingModel.value).toString(), taxModel: taxModel)
                            //                         .toString()),
                            //                 title: "${taxModel.name} (${taxModel.isFix == true ? Constant.amountShow(amount: taxModel.value) : "${taxModel.value}%"})",
                            //                 priceColor: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                            //                 titleColor: const Color(0xff656565));
                            //           }),
                            //       Padding(
                            //         padding: const EdgeInsets.symmetric(vertical: 8),
                            //         child: Dash(
                            //           length: 320.w,
                            //           direction: Axis.horizontal,
                            //           dashColor: themeChange.isDarkTheme() ? AppThemeData.grey700 : AppThemeData.grey300,
                            //         ),
                            //       ),
                            //       Row(
                            //         children: [
                            //           TextCustom(
                            //             title: "Total".tr,
                            //             fontSize: 16,
                            //             textAlign: TextAlign.start,
                            //             fontFamily: FontFamily.regular,
                            //             color: AppThemeData.orange300,
                            //           ),
                            //           const Spacer(),
                            //           TextCustom(
                            //             title: Constant.amountShow(amount: Constant.calculateFinalAmount(controller.bookingModel.value).toString()),
                            //             fontSize: 16,
                            //             fontFamily: FontFamily.bold,
                            //             color: AppThemeData.orange300,
                            //           ),
                            //         ],
                            //       ),
                            //     ],
                            //   ),
                            // ),

                            // when order completed --- food rating
                            if (controller.bookingModel.value.orderStatus == OrderStatus.orderComplete &&
                                controller.reviewModel.value.comment != null &&
                                controller.reviewModel.value.comment!.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  spaceH(height: 24),
                                  TextCustom(
                                    title: "Food Rating".tr,
                                    fontSize: 16,
                                    fontFamily: FontFamily.medium,
                                    color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                  ),
                                  spaceH(height: 8),
                                  ContainerCustom(
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        RatingBar.builder(
                                            glow: false,
                                            initialRating: double.parse(controller.reviewModel.value.rating.toString()),
                                            minRating: 0,
                                            direction: Axis.horizontal,
                                            allowHalfRating: false,
                                            itemCount: 5,
                                            tapOnlyMode: false,
                                            itemSize: 18,
                                            ignoreGestures: true,
                                            itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                                            itemBuilder: (context, _) => const Icon(Icons.star, color: AppThemeData.pending300),
                                            onRatingUpdate: (rating) {
                                              // controller.rating(rating);
                                            }),
                                        spaceH(height: 4),
                                        TextCustom(
                                          title: controller.reviewModel.value.comment.toString(),
                                          fontSize: 14,
                                          maxLine: 3,
                                          textAlign: TextAlign.start,
                                          fontFamily: FontFamily.light,
                                          color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                        ),
                                      ],
                                    ),
                                  ),
                                  spaceH(height: 24),
                                ],
                              ),
                            // when order cancelled -- cancelled reason
                            if (controller.bookingModel.value.orderStatus == OrderStatus.orderCancel && controller.bookingModel.value.cancelledReason != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  spaceH(height: 24),
                                  TextCustom(
                                    title: "Cancel Order Reason".tr,
                                    fontSize: 16,
                                    fontFamily: FontFamily.medium,
                                    color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                  ),
                                  spaceH(height: 8),
                                  ContainerCustom(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextCustom(
                                        title: controller.bookingModel.value.cancelledReason.toString(),
                                        fontSize: 16,
                                        fontFamily: FontFamily.regular,
                                        color: AppThemeData.danger300,
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                          ],
                        ),
                ),
              ),
            ),
          );
        });
  }
}

class GSTDetailsPopup extends StatelessWidget {
  final OrderDetailScreenController controller;
  final String coupon;
  final dynamic themeChange;

  const GSTDetailsPopup({
    super.key,
    required this.controller,
    required this.coupon,
    required this.themeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: themeChange.isDarkTheme() ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey200,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
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
                      color: themeChange.isDarkTheme() ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.bookingModel.value.deliveryTaxList!.length,
                    itemBuilder: (context, index) {
                      TaxModel tax = controller.bookingModel.value.deliveryTaxList![index];
                      double amount = Constant.calculateTax(
                        amount: controller.bookingModel.value.deliveryCharge.toString(),
                        taxModel: tax,
                      );
                      return PriceRowView(
                        title: "${tax.name} (${tax.isFix == true ? Constant.amountShow(amount: tax.value) : "${tax.value}%"} )",
                        price: Constant.amountShow(amount: amount.toString()),
                        priceColor: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                        titleColor: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                      );
                    },
                  ),
                  if (controller.deliveryTaxAmount.value > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Dash(
                        length: 276.w,
                        direction: Axis.horizontal,
                        dashColor: themeChange.isDarkTheme() ? AppThemeData.grey700 : AppThemeData.grey300,
                      ),
                    ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.bookingModel.value.taxList!.length,
                    itemBuilder: (context, index) {
                      TaxModel tax = controller.bookingModel.value.taxList![index];
                      double discountValue = double.tryParse(coupon.toString()) ?? 0.0;
                      double taxableAmount = controller.bookingModel.value.subTotal.toDouble() - discountValue;
                      double amount = Constant.calculateTax(
                        amount: taxableAmount.toString(),
                        taxModel: tax,
                      );
                      return PriceRowView(
                        title: "${tax.name} (${tax.isFix == true ? Constant.amountShow(amount: tax.value) : "${tax.value}%"} )",
                        price: Constant.amountShow(amount: amount.toString()),
                        priceColor: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                        titleColor: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                      );
                    },
                  ),
                  if (controller.bookingModel.value.platFormFee != null && controller.bookingModel.value.platFormFee != '0.0' && controller.bookingModel.value.platFormFee != '0')
                    PriceRowView(
                      title: "Platform Fee".tr,
                      price: Constant.amountShow(amount: controller.bookingModel.value.platFormFee.toString()),
                      priceColor: AppThemeData.secondary300,
                      titleColor: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                    ).paddingOnly(top: 10),
                  if (controller.bookingModel.value.packagingFee != null &&
                      controller.bookingModel.value.packagingFee != '0.0' &&
                      controller.bookingModel.value.packagingFee != '0')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PriceRowView(
                          title: "Restaurant Packaging Fee".tr,
                          price: Constant.amountShow(
                            amount: controller.bookingModel.value.packagingFee.toString(),
                          ),
                          priceColor: AppThemeData.secondary300,
                          titleColor: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                        ),
                        SizedBox(height: 4),
                        TextCustom(
                          title: "(Packaging may vary depending on the restaurant.)".tr,
                          fontSize: 12,
                          maxLine: 2,
                          textAlign: TextAlign.start,
                          color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400,
                        ),
                      ],
                    ).paddingOnly(top: 10),
                  if (controller.bookingModel.value.packagingFee != null &&
                      controller.bookingModel.value.packagingFee != '0.0' &&
                      controller.bookingModel.value.packagingFee != '0')
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: controller.bookingModel.value.packagingTaxList!.length,
                      itemBuilder: (context, index) {
                        TaxModel tax = controller.bookingModel.value.packagingTaxList![index];
                        double amount = Constant.calculateTax(
                          amount: controller.bookingModel.value.packagingFee.toString(),
                          taxModel: tax,
                        );
                        return PriceRowView(
                          title: "${tax.name} (${tax.isFix == true ? Constant.amountShow(amount: tax.value) : "${tax.value}%"} )",
                          price: Constant.amountShow(amount: amount.toString()),
                          priceColor: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                          titleColor: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
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
