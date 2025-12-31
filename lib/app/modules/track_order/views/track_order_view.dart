// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:customer/app/models/driver_user_model.dart';
import 'package:customer/app/modules/track_order/controllers/track_order_controller.dart';
import 'package:customer/app/modules/track_order/views/widget/cancel_reason_bottom_sheet.dart';
import 'package:customer/app/modules/track_order/views/widget/order_cancelled_view.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/network_image_widget.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/order_status.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/constant_widgets/container_custom.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../themes/screen_size.dart';

class TrackOrderView extends GetView {
  const TrackOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<TrackOrderController>(
        init: TrackOrderController(),
        builder: (controller) {
          return Scaffold(
            body: Obx(
              () => Stack(
                children: [
                  SizedBox(
                    height: Responsive.height(100, context),
                    child: GoogleMap(
                      zoomControlsEnabled: false,
                      myLocationEnabled: false,
                      initialCameraPosition: CameraPosition(target: LatLng(Constant.currentLocation!.location!.latitude!, Constant.currentLocation!.location!.longitude!), zoom: 5),
                      padding: const EdgeInsets.only(
                        top: 22.0,
                      ),
                      polylines: Set<Polyline>.of(controller.polyLines.values),
                      markers: Set<Marker>.of(controller.markers.values),
                      onMapCreated: (GoogleMapController mapController) {
                        controller.mapController = mapController;
                      },
                    ),
                  ),
                  Positioned(
                    left: 15,
                    top: 30,
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey200,
                        ),
                        height: 40.h,
                        width: 40.w,
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                        ),
                      ),
                    ),
                  ),
                  controller.isLoading.value
                      ? Constant.loader()
                      : Column(
                          children: [
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: ContainerCustom(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          NetworkImageWidget(
                                            imageUrl: controller.restaurantModel.value.logoImage.toString(),
                                            height: 44.h,
                                            width: 44.h,
                                            borderRadius: 200.r,
                                            fit: BoxFit.cover,
                                          ),
                                          spaceW(width: 6.w),
                                          SizedBox(
                                            width: 200.w,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 190.w,
                                                  child: TextCustom(
                                                    title: controller.restaurantModel.value.vendorName.toString(),
                                                    fontSize: 16,
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                                TextCustom(
                                                  textAlign: TextAlign.start,
                                                  title: controller.restaurantModel.value.address!.address!.toString(),
                                                  fontSize: 14,
                                                  maxLine: 4,
                                                ),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              final fullPhoneNumber = '${controller.ownerModel.value.countryCode}${controller.ownerModel.value.phoneNumber}';
                                              final url = 'tel:$fullPhoneNumber';
                                              if (await canLaunch(url)) {
                                                await launch(url);
                                              } else {}
                                            },
                                            child: Container(
                                              height: 34.h,
                                              width: 34.w,
                                              alignment: Alignment.center,
                                              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppThemeData.secondary300),
                                              child: SvgPicture.asset(
                                                'assets/icons/ic_call.svg',
                                                height: 16.h,
                                                width: 16.w,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    spaceH(height: 20.h),
                                    RoundShapeButton(
                                        size: Size(326.w, ScreenSize.height(6, context)),
                                        title: "View Details".tr,
                                        buttonColor: AppThemeData.orange300,
                                        buttonTextColor: AppThemeData.primaryWhite,
                                        onTap: () {
                                          orderDetailsBottomSheet(context, controller, themeChange);
                                        }),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                ],
              ),
            ),
          );
        });
  }

  void orderDetailsBottomSheet(BuildContext context, TrackOrderController controller, DarkThemeProvider themeChange) {
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 4.h),
                      width: 72.w,
                      height: 8.h,
                      decoration: BoxDecoration(color: AppThemeData.grey400, borderRadius: BorderRadius.circular(100)),
                    ),
                  ),
                ),

                spaceH(height: 24),
                if (controller.orderModel.value.orderStatus == OrderStatus.orderPending) ...{
                  TextCustom(
                    title: "Assigning a driver to pick it up shortly...".tr,
                    fontSize: 16,
                    fontFamily: FontFamily.regular,
                    color: AppThemeData.info300,
                    maxLine: 2,
                    textAlign: TextAlign.start,
                  ),
                } else if (controller.orderModel.value.orderStatus == OrderStatus.driverAccepted || controller.orderModel.value.orderStatus == OrderStatus.orderOnReady) ...{
                  TextCustom(
                    title: "${controller.driverUserModel.value.firstName} ${"is on the way to the restaurant to pick up your order.".tr}",
                    fontSize: 16,
                    fontFamily: FontFamily.regular,
                    color: AppThemeData.info300,
                    maxLine: 2,
                    textAlign: TextAlign.start,
                  ),
                } else if (controller.orderModel.value.orderStatus == OrderStatus.driverPickup) ...{
                  TextCustom(
                    title: "${controller.driverUserModel.value.firstName} ${"has picked up your order and is on the way to your location".tr}",
                    fontSize: 16,
                    fontFamily: FontFamily.regular,
                    color: AppThemeData.info300,
                    maxLine: 2,
                    textAlign: TextAlign.start,
                  ),
                } else ...{
                  TextCustom(
                    title: "Your order has been delivered. Enjoy your meal!".tr,
                    fontSize: 16,
                    fontFamily: FontFamily.regular,
                    color: AppThemeData.info300,
                    maxLine: 2,
                    textAlign: TextAlign.start,
                  ),
                },
                spaceH(height: 24),
                SizedBox(
                  height: 90.h,
                  width: MediaQuery.of(context).size.width,
                  child: Timeline.tileBuilder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    theme: TimelineThemeData(
                      direction: Axis.horizontal,
                      nodePosition: 0.1,
                      indicatorPosition: 0.5,
                    ),
                    builder: TimelineTileBuilder.connected(
                      itemCount: 4,
                      contentsAlign: ContentsAlign.basic,
                      indicatorBuilder: (context, index) {
                        bool isActive = false;

                        if (index == 0) {
                          isActive = controller.orderModel.value.orderStatus == OrderStatus.driverAccepted ||
                              controller.orderModel.value.orderStatus == OrderStatus.orderAccepted ||
                              controller.orderModel.value.orderStatus == OrderStatus.driverPickup ||
                              controller.orderModel.value.orderStatus == OrderStatus.orderOnReady ||
                              controller.orderModel.value.orderStatus == OrderStatus.orderComplete;
                        } else if (index == 1) {
                          isActive = controller.orderModel.value.foodIsReadyToPickup == true;
                        } else if (index == 2) {
                          isActive = controller.orderModel.value.orderStatus == OrderStatus.driverPickup || controller.orderModel.value.orderStatus == OrderStatus.orderComplete;
                        } else if (index == 3) {
                          isActive = controller.orderModel.value.orderStatus == OrderStatus.orderComplete;
                        }

                        List<String> iconPaths = [
                          "assets/icons/order_received.svg",
                          "assets/icons/order_prepaid.svg",
                          "assets/icons/order_pickup.svg",
                          "assets/icons/order_delivered.svg",
                        ];

                        return Container(
                            height: 40.h,
                            width: 40.w,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive
                                    ? AppThemeData.orange300
                                    : themeChange.isDarkTheme()
                                        ? AppThemeData.grey900
                                        : AppThemeData.grey100),
                            child: Center(
                                child: SvgPicture.asset(iconPaths[index],
                                    color: isActive
                                        ? AppThemeData.primaryWhite
                                        : themeChange.isDarkTheme()
                                            ? AppThemeData.grey400
                                            : AppThemeData.grey600)));
                      },
                      connectorBuilder: (context, index, connectorType) {
                        bool isConnectorActive = false;
                        if (index == 0) {
                          isConnectorActive = controller.orderModel.value.orderStatus == OrderStatus.driverAccepted ||
                              controller.orderModel.value.orderStatus == OrderStatus.orderAccepted ||
                              controller.orderModel.value.orderStatus == OrderStatus.driverPickup ||
                              controller.orderModel.value.orderStatus == OrderStatus.orderOnReady ||
                              controller.orderModel.value.orderStatus == OrderStatus.orderComplete;
                        } else if (index == 1) {
                          isConnectorActive = controller.orderModel.value.foodIsReadyToPickup == true;
                        } else if (index == 2) {
                          isConnectorActive =
                              controller.orderModel.value.orderStatus == OrderStatus.driverPickup || controller.orderModel.value.orderStatus == OrderStatus.orderComplete;
                        }
                        return SizedBox(
                          width: 25.w,
                          child: SolidLineConnector(
                            thickness: 1,
                            endIndent: 0,
                            color: isConnectorActive
                                ? AppThemeData.orange300 // Active connector color
                                : (themeChange.isDarkTheme()
                                    ? AppThemeData.grey400 // Inactive dark theme
                                    : AppThemeData.grey600),
                          ),
                        );
                      },
                      contentsBuilder: (context, index) {
                        List<String> labels = ["Received", "Prepaid", "Pickup", "Delivered"];
                        bool isActive = false;

                        if (index == 0) {
                          isActive = controller.orderModel.value.orderStatus == OrderStatus.driverAccepted ||
                              controller.orderModel.value.orderStatus == OrderStatus.orderAccepted ||
                              controller.orderModel.value.orderStatus == OrderStatus.driverPickup ||
                              controller.orderModel.value.orderStatus == OrderStatus.orderOnReady ||
                              controller.orderModel.value.orderStatus == OrderStatus.orderComplete;
                        } else if (index == 1) {
                          isActive = controller.orderModel.value.foodIsReadyToPickup == true;
                        } else if (index == 2) {
                          isActive = controller.orderModel.value.orderStatus == OrderStatus.driverPickup || controller.orderModel.value.orderStatus == OrderStatus.orderComplete;
                        } else if (index == 3) {
                          isActive = controller.orderModel.value.orderStatus == OrderStatus.orderComplete;
                        }
                        return SizedBox(
                          width: 80.w,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextCustom(
                                title: labels[index].tr,
                                fontSize: 14,
                                fontFamily: FontFamily.light,
                                color: isActive
                                    ? AppThemeData.orange300
                                    : themeChange.isDarkTheme()
                                        ? AppThemeData.grey400
                                        : AppThemeData.grey600,
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                //Driver Details
                if (controller.orderModel.value.driverId != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      spaceH(height: 24),
                      TextCustom(
                          title: "Driver Assign".tr, fontSize: 16, fontFamily: FontFamily.medium, color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: themeChange.isDarkTheme() ? AppThemeData.surface1000 : AppThemeData.surface50),
                        child: FutureBuilder<DriverUserModel?>(
                          future: FireStoreUtils.getDriverUserProfile(controller.orderModel.value.driverId.toString()),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }
                            DriverUserModel driverModel = snapshot.data ?? DriverUserModel();
                            return Row(
                              children: [
                                SizedBox(
                                  height: 46.h,
                                  width: 46.w,
                                  child: NetworkImageWidget(
                                    imageUrl: driverModel.profileImage.toString(),
                                    borderRadius: 50,
                                  ),
                                ),
                                spaceW(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextCustom(
                                        title: driverModel.fullNameString(),
                                        fontSize: 16,
                                        fontFamily: FontFamily.bold,
                                        color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                      ),
                                      TextCustom(
                                        title: "${driverModel.countryCode} ${driverModel.phoneNumber}",
                                        fontSize: 14,
                                        fontFamily: FontFamily.regular,
                                        color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                      )
                                    ],
                                  ),
                                ),
                                spaceW(width: 8),
                                GestureDetector(
                                  onTap: () async {
                                    final fullPhoneNumber = '${controller.ownerModel.value.countryCode}${controller.ownerModel.value.phoneNumber}';
                                    final url = 'tel:$fullPhoneNumber';
                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    } else {}
                                  },
                                  child: Container(
                                    height: 38.h,
                                    width: 38.w,
                                    decoration: const BoxDecoration(
                                      color: AppThemeData.secondary300,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(child: SvgPicture.asset("assets/icons/ic_phone_call.svg")),
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                //Delivery address
                TextCustom(
                    title: "Delivery Address".tr, fontSize: 16, fontFamily: FontFamily.medium, color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000),
                spaceH(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: themeChange.isDarkTheme() ? AppThemeData.surface1000 : AppThemeData.surface50),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        controller.orderModel.value.customerAddress?.addressAs == "Home"
                            ? "assets/icons/ic_home2.svg"
                            : controller.orderModel.value.customerAddress?.addressAs == "Work"
                                ? "assets/icons/ic_work.svg"
                                : controller.orderModel.value.customerAddress?.addressAs == "Friends and Family"
                                    ? "assets/icons/ic_user.svg"
                                    : "assets/icons/ic_location.svg",
                        color: AppThemeData.orange300,
                      ),
                      spaceW(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextCustom(
                              title: "${controller.orderModel.value.customerAddress?.addressAs}",
                              fontSize: 14,
                              fontFamily: FontFamily.light,
                              textAlign: TextAlign.start,
                              color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800,
                            ),
                            TextCustom(
                              title: "${controller.orderModel.value.customerAddress?.address}",
                              fontSize: 16,
                              fontFamily: FontFamily.medium,
                              textAlign: TextAlign.start,
                              color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                spaceH(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: themeChange.isDarkTheme() ? AppThemeData.surface1000 : AppThemeData.surface50),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                                height: 45.h,
                                width: 45.h,
                                child: NetworkImageWidget(
                                  imageUrl: controller.restaurantModel.value.coverImage.toString(),
                                  borderRadius: 50,
                                )),
                            spaceW(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextCustom(
                                    title: controller.restaurantModel.value.vendorName.toString(),
                                    fontSize: 16,
                                    fontFamily: FontFamily.bold,
                                    textAlign: TextAlign.start,
                                    color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                  ),
                                  TextCustom(
                                    title: controller.restaurantModel.value.address!.address.toString(),
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
                          final fullPhoneNumber = '${controller.ownerModel.value.countryCode}${controller.ownerModel.value.phoneNumber}';
                          final url = 'tel:$fullPhoneNumber';
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {}
                        },
                        child: Container(
                          height: 38.h,
                          width: 38.w,
                          decoration: const BoxDecoration(
                            color: AppThemeData.secondary300,
                            shape: BoxShape.circle,
                          ),
                          child: Center(child: SvgPicture.asset("assets/icons/ic_phone_call.svg")),
                        ),
                      )
                    ],
                  ),
                ),
                spaceH(height: 42),
                controller.orderModel.value.orderStatus == OrderStatus.orderPending
                    ? RoundShapeButton(
                        title: "Cancel".tr,
                        buttonColor: AppThemeData.danger300,
                        buttonTextColor: AppThemeData.primaryWhite,
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey100,
                              builder: (context) {
                                return CancelReasonBottomSheet(
                                  onConfirm: () async {
                                    bool isCancelled = await controller.cancelBooking(controller.orderModel.value);
                                    if (isCancelled) {
                                      ShowToastDialog.showToast("Order cancelled successfully.".tr);
                                      Get.off(const OrderCancelledView());
                                    } else {
                                      ShowToastDialog.showToast("Something went wrong.".tr);
                                    }
                                  },
                                );
                              });
                        },
                        size: Size(358.w, ScreenSize.height(6, context)))
                    : Container(),
              ],
            ),
          );
        });
  }
}
