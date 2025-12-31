// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/models/cart_model.dart';
import 'package:customer/app/models/product_model.dart';
import 'package:customer/app/models/vendor_model.dart';
import 'package:customer/app/models/wallet_transaction_model.dart';
import 'package:customer/app/modules/add_review_screen/views/add_review_screen_view.dart';
import 'package:customer/app/modules/dashboard_screen/controllers/dashboard_screen_controller.dart';
import 'package:customer/app/modules/my_cart/views/my_cart_view.dart';
import 'package:customer/app/modules/order_detail_screen/views/order_detail_screen_view.dart';
import 'package:customer/app/modules/order_screen/controllers/order_screen_controller.dart';
import 'package:customer/app/modules/track_order/controllers/track_order_controller.dart';
import 'package:customer/app/modules/track_order/views/track_order_view.dart';
import 'package:customer/app/modules/track_order/views/widget/cancel_reason_bottom_sheet.dart';
import 'package:customer/app/modules/track_order/views/widget/order_cancelled_view.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/order_status.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/constant_widgets/container_custom.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/constant_widgets/top_widget.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../constant/send_notification.dart';

class OrderScreenView extends GetView<OrderScreenController> {
  const OrderScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<OrderScreenController>(
        init: OrderScreenController(),
        builder: (controller) {
          return Container(
            width: Responsive.width(100, context),
            height: Responsive.height(100, context),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    stops: const [0.2, 0.4],
                    colors: themeChange.isDarkTheme() ? [const Color(0xff1A0B00), const Color(0xff1C1C22)] : [const Color(0xffFFF1E5), const Color(0xffFFFFFF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                forceMaterialTransparency: true,
                title: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/images/logo.svg",
                      color: AppThemeData.orange300,
                      width: 32,
                      height: 32,
                    ),
                    spaceW(),
                    TextCustom(
                      title: Constant.appName.value.tr,
                      fontSize: 20,
                      color: AppThemeData.orange300,
                      fontFamily: FontFamily.bold,
                    ),
                  ],
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTopWidget(context, "Orders".tr, "Track your order history and stay updated on your current deliveries.".tr),
                    spaceH(height: 24),
                    SizedBox(
                      height: 45.h,
                      child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: [
                          RoundShapeButton(
                            title: "Pending".tr,
                            borderRadius: 50,
                            buttonColor: controller.selectedOrderType.value == 0
                                ? AppThemeData.secondary300
                                : themeChange.isDarkTheme()
                                    ? AppThemeData.grey800
                                    : AppThemeData.grey200,
                            buttonTextColor: controller.selectedOrderType.value == 0
                                ? AppThemeData.primaryWhite
                                : themeChange.isDarkTheme()
                                    ? AppThemeData.grey400
                                    : AppThemeData.grey600,
                            onTap: () {
                              controller.selectedOrderType.value = 0;
                            },
                            size: const Size(110, 38),
                            textSize: 14,
                          ),
                          spaceW(width: 8),
                          RoundShapeButton(
                            title: "Completed".tr,
                            borderRadius: 50,
                            buttonColor: controller.selectedOrderType.value == 1
                                ? AppThemeData.secondary300
                                : themeChange.isDarkTheme()
                                    ? AppThemeData.grey800
                                    : AppThemeData.grey200,
                            buttonTextColor: controller.selectedOrderType.value == 1
                                ? AppThemeData.primaryWhite
                                : themeChange.isDarkTheme()
                                    ? AppThemeData.grey400
                                    : AppThemeData.grey600,
                            onTap: () {
                              controller.selectedOrderType.value = 1;
                            },
                            size: const Size(128, 38),
                            textSize: 14,
                          ),
                          spaceW(width: 8),
                          RoundShapeButton(
                            title: "Cancelled".tr,
                            borderRadius: 50,
                            buttonColor: controller.selectedOrderType.value == 2
                                ? AppThemeData.secondary300
                                : themeChange.isDarkTheme()
                                    ? AppThemeData.grey800
                                    : AppThemeData.grey200,
                            buttonTextColor: controller.selectedOrderType.value == 2
                                ? AppThemeData.primaryWhite
                                : themeChange.isDarkTheme()
                                    ? AppThemeData.grey400
                                    : AppThemeData.grey600,
                            onTap: () {
                              controller.selectedOrderType.value = 2;
                            },
                            size: const Size(128, 38),
                            textSize: 14,
                          ),
                        ],
                      ),
                    ),
                    spaceH(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: controller.isLoading.value
                            ? Constant.loader()
                            : (controller.selectedOrderType.value == 0
                                    ? controller.pendingOrderList.isEmpty
                                    : controller.selectedOrderType.value == 1
                                        ? controller.completedOrderList.isEmpty
                                        : controller.cancelledOrderList.isEmpty)
                                ?  Center(child: TextCustom(title: "No Orders..".tr))
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: controller.selectedOrderType.value == 0
                                        ? controller.pendingOrderList.length
                                        : controller.selectedOrderType.value == 1
                                            ? controller.completedOrderList.length
                                            : controller.cancelledOrderList.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      OrderModel bookingModel = controller.selectedOrderType.value == 0
                                          ? controller.pendingOrderList[index]
                                          : controller.selectedOrderType.value == 1
                                              ? controller.completedOrderList[index]
                                              : controller.cancelledOrderList[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: InkWell(
                                          onTap: () {
                                            Get.to(const OrderDetailScreenView(), arguments: {"bookingModel": bookingModel});
                                          },
                                          child: ContainerCustom(
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Expanded(
                                                      child: TextCustom(
                                                        title: "${Constant.timestampToDate(bookingModel.createdAt!)} at ${Constant.timestampToTime12Hour(bookingModel.createdAt!)}",
                                                        fontSize: 14,
                                                        fontFamily: FontFamily.regular,
                                                        textAlign: TextAlign.start,
                                                        color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                                      ),
                                                    ),
                                                    spaceW(width: 10),
                                                    TextCustom(
                                                      // title: Constant.showId(bookingModel.id.toString()),
                                                      title: "#${bookingModel.id!.substring(0, 5)}",
                                                      fontSize: 14,
                                                      fontFamily: FontFamily.regular,
                                                      isUnderLine: true,
                                                      color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                                    )
                                                  ],
                                                ),
                                                spaceH(height: 12),
                                                Row(
                                                  children: [
                                                    FutureBuilder(
                                                        future: FireStoreUtils.getRestaurant(bookingModel.vendorId.toString()),
                                                        builder: (context, snapshot) {
                                                          if (!snapshot.hasData) {
                                                            return Container();
                                                          }
                                                          VendorModel restaurantModel = snapshot.data ?? VendorModel();
                                                          return Expanded(
                                                            child: TextCustom(
                                                              title: restaurantModel.vendorName.toString(),
                                                              fontSize: 16,
                                                              fontFamily: FontFamily.bold,
                                                              maxLine: 1,
                                                              textAlign: TextAlign.start,
                                                              color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                                            ),
                                                          );
                                                        }),
                                                    spaceW(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                          color: OrderStatus.getOrderStatusBackgroundColor(bookingModel.orderStatus.toString(), context),
                                                          borderRadius: BorderRadius.circular(4)),
                                                      child: TextCustom(
                                                        title: OrderStatus.getOrderStatusTitle(bookingModel.orderStatus.toString()),
                                                        fontSize: 12,
                                                        fontFamily: FontFamily.medium,
                                                        color: OrderStatus.getOrderStatusTitleColor(bookingModel.orderStatus.toString(), context),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                spaceH(height: 2),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/icons/ic_map_pin.svg",
                                                      color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                                    ),
                                                    spaceW(width: 4),
                                                    Expanded(
                                                      child: TextCustom(
                                                        title: bookingModel.vendorAddress!.address.toString(),
                                                        fontSize: 14,
                                                        fontFamily: FontFamily.regular,
                                                        maxLine: 1,
                                                        textAlign: TextAlign.start,
                                                        color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                  child: Divider(
                                                    color: themeChange.isDarkTheme() ? AppThemeData.grey700 : AppThemeData.grey300,
                                                  ),
                                                ),
                                                ListView.builder(
                                                    shrinkWrap: true,
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    itemCount: bookingModel.items!.length,
                                                    itemBuilder: (context, index) {
                                                      return Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.only(bottom: 4),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                FutureBuilder(
                                                                    future: FireStoreUtils.getProductByProductId(bookingModel.items![index].productId.toString()),
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
                                                                  child: TextCustom(
                                                                    title: "${bookingModel.items![index].quantity}x ${bookingModel.items![index].productName}",
                                                                    fontSize: 14,
                                                                    fontFamily: FontFamily.regular,
                                                                    textAlign: TextAlign.start,
                                                                    color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                                  ),
                                                                ),
                                                                spaceW(width: 10),
                                                                TextCustom(
                                                                  title: Constant.amountShow(amount: bookingModel.items![index].totalAmount.toString()),
                                                                  fontSize: 14,
                                                                  fontFamily: FontFamily.regular,
                                                                  color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    }),
                                                if (bookingModel.orderStatus == OrderStatus.orderComplete) ...[
                                                  Column(
                                                    children: [
                                                      spaceH(height: 20),
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Expanded(
                                                              child: RoundShapeButton(
                                                                  title: "Add Review".tr,
                                                                  buttonColor: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                                  buttonTextColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                                                  onTap: () {
                                                                    Get.to(const AddReviewScreenView(), arguments: {"bookingModel": bookingModel});
                                                                  },
                                                                  size: const Size(0, 52))),
                                                          spaceW(width: 12),
                                                          const SizedBox(width: 12),
                                                          Expanded(
                                                            child: RoundShapeButton(
                                                                title: "Re - Order".tr,
                                                                buttonColor: AppThemeData.orange300,
                                                                buttonTextColor: AppThemeData.primaryWhite,
                                                                onTap: () async {
                                                                  if (bookingModel.items != null && bookingModel.items!.isNotEmpty) {
                                                                    for (var item in bookingModel.items!) {
                                                                      CartModel cartModel = item;

                                                                      controller.cartDatabaseHelper.insertCartItem(cartModel).then((value) {
                                                                        ShowToastDialog.showToast("Item added to cart.".tr);
                                                                        DashboardScreenController dashBoardController = Get.put(DashboardScreenController());
                                                                        dashBoardController.selectedIndex.value = 0;
                                                                      }).catchError((error) {});
                                                                    }

                                                                    ShowToastDialog.showToast("Reorder placed successfully.".tr);
                                                                    Get.to(const MyCartView());
                                                                  } else {
                                                                    ShowToastDialog.showToast("No past items available for reorder.".tr);
                                                                  }
                                                                },
                                                                size: const Size(0, 52)),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ] else if (bookingModel.orderStatus == OrderStatus.orderPending) ...[
                                                  Column(
                                                    children: [
                                                      spaceH(height: 20),
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Expanded(
                                                              child: RoundShapeButton(
                                                                  title: "Cancel Order".tr,
                                                                  buttonColor: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                                                  buttonTextColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                                                  onTap: () {
                                                                    showModalBottomSheet(
                                                                        context: context,
                                                                        isScrollControlled: true,
                                                                        backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey100,
                                                                        builder: (context) {
                                                                          TrackOrderController trackOrderController = Get.put(TrackOrderController());
                                                                          return CancelReasonBottomSheet(
                                                                            onConfirm: () async {
                                                                              ShowToastDialog.showLoader("Please Wait..".tr);
                                                                              await FirebaseFirestore.instance.collection(CollectionName.orders).doc(bookingModel.id).update({
                                                                                "orderStatus": OrderStatus.orderCancel,
                                                                                "cancelledBy": FireStoreUtils.getCurrentUid(),
                                                                                "cancelledReason": trackOrderController.cancelReason[trackOrderController.selectedIndex.value] !=
                                                                                        "Other"
                                                                                    ? trackOrderController.cancelReason[trackOrderController.selectedIndex.value].toString()
                                                                                    : "${trackOrderController.cancelReason[trackOrderController.selectedIndex.value].toString()} : ${trackOrderController.otherReasonController.value.text}"
                                                                              }).whenComplete(() async {
                                                                                if (bookingModel.paymentStatus == true) {
                                                                                  WalletTransactionModel transactionModel = WalletTransactionModel(
                                                                                      id: Constant.getUuid(),
                                                                                      amount: bookingModel.totalAmount,
                                                                                      createdDate: Timestamp.now(),
                                                                                      paymentType: bookingModel.paymentStatus.toString(),
                                                                                      transactionId: Constant.getUuid(),
                                                                                      userId: FireStoreUtils.getCurrentUid(),
                                                                                      isCredit: true,
                                                                                      type: Constant.user,
                                                                                      note: "Order Cancelled");

                                                                                  await FireStoreUtils.setWalletTransaction(transactionModel).then((value) async {
                                                                                    if (value == true) {
                                                                                      await FireStoreUtils.updateUserWallet(amount: bookingModel.totalAmount.toString())
                                                                                          .then((value) async {
                                                                                        Map<String, dynamic> playLoad = <String, dynamic>{"orderId": bookingModel.id};
                                                                                        await SendNotification.sendOneNotification(
                                                                                            isPayment: bookingModel.paymentStatus ?? false,
                                                                                            isSaveNotification: false,
                                                                                            token: Constant.userModel!.fcmToken.toString(),
                                                                                            title: 'Cancel the order ❌'.tr,
                                                                                            body: 'Cancel for this order#${bookingModel.id.toString().substring(0, 5)}',
                                                                                            type: 'order',
                                                                                            orderId: bookingModel.id,
                                                                                            senderId: FireStoreUtils.getCurrentUid(),
                                                                                            customerId: FireStoreUtils.getCurrentUid(),
                                                                                            payload: playLoad,
                                                                                            isNewOrder: false);
                                                                                      });
                                                                                    }
                                                                                  });
                                                                                }
                                                                                ShowToastDialog.closeLoader();
                                                                                ShowToastDialog.showToast("Order cancelled successfully.".tr);
                                                                                Get.offAll(const OrderCancelledView());
                                                                              });
                                                                            },
                                                                          );
                                                                        });
                                                                  },
                                                                  size: const Size(0, 52))),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ] else if (bookingModel.orderStatus == OrderStatus.orderCancel || bookingModel.orderStatus == OrderStatus.orderRejected) ...[
                                                  Column(
                                                    children: [
                                                      spaceH(height: 20),
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Expanded(
                                                            child: RoundShapeButton(
                                                                title: "Re - Order".tr,
                                                                buttonColor: AppThemeData.orange300,
                                                                buttonTextColor: AppThemeData.primaryWhite,
                                                                onTap: () async {
                                                                  if (bookingModel.items != null && bookingModel.items!.isNotEmpty) {
                                                                    for (var item in bookingModel.items!) {
                                                                      CartModel cartModel = item;
                                                                      controller.cartDatabaseHelper.insertCartItem(cartModel).then((value) {
                                                                        ShowToastDialog.showToast("Item added to cart.".tr);
                                                                        DashboardScreenController dashBoardController = Get.put(DashboardScreenController());
                                                                        dashBoardController.selectedIndex.value = 0;
                                                                      }).catchError((error) {});
                                                                    }

                                                                    ShowToastDialog.showToast("Reorder placed successfully.".tr);
                                                                    Get.to(const MyCartView());
                                                                  } else {
                                                                    ShowToastDialog.showToast("No past items available for reorder.".tr);
                                                                  }
                                                                },
                                                                size: const Size(0, 52)),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ] else if (bookingModel.orderStatus == OrderStatus.driverAccepted ||
                                                    bookingModel.orderStatus == OrderStatus.orderOnReady ||
                                                    bookingModel.orderStatus == OrderStatus.driverPickup) ...[
                                                  Column(
                                                    children: [
                                                      spaceH(height: 20),
                                                      RoundShapeButton(
                                                          title: "Track Order".tr,
                                                          buttonColor: AppThemeData.orange300,
                                                          buttonTextColor: AppThemeData.primaryWhite,
                                                          onTap: () {
                                                            Get.to(const TrackOrderView(), arguments: {"bookingModel": bookingModel});
                                                          },
                                                          size: const Size(328, 52)),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
