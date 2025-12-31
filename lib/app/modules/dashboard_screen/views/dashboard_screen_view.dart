// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:customer/app/modules/dashboard_screen/controllers/dashboard_screen_controller.dart';
import 'package:customer/app/modules/order_detail_screen/views/order_detail_screen_view.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/network_image_widget.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/login_dialog.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DashboardScreenView extends GetView<DashboardScreenController> {
  const DashboardScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<DashboardScreenController>(
      init: DashboardScreenController(),
      builder: (controller) {
        return Scaffold(
            body: Obx(() => controller.pageList[controller.selectedIndex.value]),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  controller.bookingOrder.value.id != null && controller.bookingOrder.value.id!.isNotEmpty && controller.selectedIndex.value == 0
                      ? Positioned(
                          bottom: 0,
                          child: InkWell(
                            onTap: () {
                              Get.to(
                                const OrderDetailScreenView(),
                                arguments: {"bookingModel": controller.bookingOrder.value},
                              );
                            },
                            child: Container(
                              width: Responsive.width(100, context),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: themeChange.isDarkTheme() ? AppThemeData.orange500 : AppThemeData.orange50,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  NetworkImageWidget(
                                    imageUrl: controller.vendorModel.value.logoImage.toString(),
                                    height: 50,
                                    width: 50,
                                    borderRadius: 50,
                                  ),
                                  spaceW(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(
                                          title: controller.vendorModel.value.vendorName.toString(),
                                          fontFamily: FontFamily.bold,
                                        ),
                                        const SizedBox(height: 4),
                                        Obx(
                                          () => controller.estimatedDeliveryTiming.value.isNotEmpty
                                              ? TextCustom(
                                                  title: controller.estimatedDeliveryTiming.value.tr,
                                                  fontSize: 14,
                                                  maxLine: 2,
                                                  textAlign: TextAlign.start,
                                                )
                                              : const SizedBox(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Get.to(OrderDetailScreenView(), arguments: {"bookingModel": controller.bookingOrder.value});
                                    },
                                    child: TextCustom(
                                      title: "View Order".tr,
                                      color: AppThemeData.orange300,
                                      isUnderLine: true,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                  BottomNavigationBar(
                      elevation: 0,
                      type: BottomNavigationBarType.fixed,
                      currentIndex: controller.selectedIndex.value,
                      onTap: (int index) {
                        if ((index == 1 || index == 2) && FireStoreUtils.getCurrentUid() == null) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: LoginDialog(),
                              );
                            },
                          );
                        } else {
                          controller.selectedIndex.value = index;
                        }
                      },
                      backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                      selectedItemColor: AppThemeData.orange300,
                      selectedIconTheme: IconThemeData(color: AppThemeData.orange300),
                      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      showSelectedLabels: true,
                      showUnselectedLabels: true,
                      unselectedIconTheme: IconThemeData(color: AppThemeData.grey500),
                      unselectedItemColor: AppThemeData.grey500,
                      unselectedLabelStyle: TextStyle(fontSize: 12, fontFamily: FontFamily.regular),
                      items: [
                        BottomNavigationBarItem(
                          icon: SvgPicture.asset(
                            "assets/icons/ic_home.svg",
                            color: controller.selectedIndex.value == 0 ? AppThemeData.orange300 : AppThemeData.grey500,
                            height: 20,
                            width: 20,
                          ),
                          label: "Home".tr,
                        ),
                        BottomNavigationBarItem(
                          icon: SvgPicture.asset(
                            "assets/icons/ic_order.svg",
                            color: controller.selectedIndex.value == 1 ? AppThemeData.orange300 : AppThemeData.grey500,
                            height: 20,
                            width: 20,
                          ),
                          label: "Orders".tr,
                        ),
                        BottomNavigationBarItem(
                          icon: SvgPicture.asset(
                            "assets/icons/ic_wallet2.svg",
                            color: controller.selectedIndex.value == 2 ? AppThemeData.orange300 : AppThemeData.grey500,
                            height: 20,
                            width: 20,
                          ),
                          label: "Wallet".tr,
                        ),
                        BottomNavigationBarItem(
                          icon: SvgPicture.asset(
                            "assets/icons/ic_profile.svg",
                            color: controller.selectedIndex.value == 3 ? AppThemeData.orange300 : AppThemeData.grey500,
                            height: 20,
                            width: 20,
                          ),
                          label: "Profile".tr,
                        )
                      ]),
                ],
              ),
            ));
      },
    );
  }
}
