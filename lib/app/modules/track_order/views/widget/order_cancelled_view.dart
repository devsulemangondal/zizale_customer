import 'package:customer/app/modules/dashboard_screen/views/dashboard_screen_view.dart';
import 'package:customer/app/modules/track_order/controllers/track_order_controller.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../themes/screen_size.dart';

class OrderCancelledView extends GetView {
  const OrderCancelledView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<TrackOrderController>(
        init: TrackOrderController(),
        builder: (controller) {
          return Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: themeChange.isDarkTheme() ? [const Color(0xffD61600), const Color(0xffE45C4C)] : [const Color(0xffD61600), const Color(0xff980F00)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("assets/animation/order_cancelled.gif"),
                      TextCustom(
                        title: "Order Cancelled".tr,
                        fontSize: 28,
                        fontFamily: FontFamily.bold,
                        color: themeChange.isDarkTheme() ? AppThemeData.surface1000 : AppThemeData.surface50,
                      ),
                      spaceH(height: 4),
                      TextCustom(
                        title: "Your order has been successfully cancelled. We hope to serve you better next time.".tr,
                        fontSize: 14,
                        maxLine: 4,
                        fontFamily: FontFamily.light,
                        color: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey100,
                      ),
                      spaceH(height: 42),
                      RoundShapeButton(
                          title: "Back to Home".tr,
                          textSize: 18,
                          buttonColor: themeChange.isDarkTheme() ? AppThemeData.surface50 : AppThemeData.surface1000,
                          buttonTextColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                          onTap: () {
                            Get.offAll(const DashboardScreenView());
                          },
                          size: Size(358.w, ScreenSize.height(6, context)))
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
