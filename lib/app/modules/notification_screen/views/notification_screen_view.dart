// ignore_for_file: deprecated_member_use
import 'package:customer/app/models/notification_model.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/common_ui.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import '../controllers/notification_screen_controller.dart';
import 'widget/notification_widget.dart';

class NotificationScreenView extends StatelessWidget {
  const NotificationScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<NotificationScreenController>(
        autoRemove: false,
        init: NotificationScreenController(),
        builder: (controller) {
          return Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    stops: const [0.1, 0.3],
                    colors: themeChange.isDarkTheme() ? [const Color(0xff1C1C22), const Color(0xff1C1C22)] : [const Color(0xffFDE7E7), const Color(0xffFFFFFF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)),
            child: Scaffold(
                backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                appBar: UiInterface.customAppBar(context, themeChange, "", backgroundColor: Colors.transparent),
                body: Obx(
                  () => Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextCustom(
                            title: "Notification".tr,
                            fontSize: 28,
                            maxLine: 2,
                            color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey1000,
                            fontFamily: FontFamily.bold,
                            textAlign: TextAlign.start,
                          ),
                          2.height,
                          TextCustom(
                            title: "Stay updated with the latest offers, order updates, and important notifications.".tr,
                            fontSize: 16,
                            maxLine: 2,
                            color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                            fontFamily: FontFamily.regular,
                            textAlign: TextAlign.start,
                          ),
                          spaceH(height: 22),
                          controller.isLoading.value
                              ? Constant.loader()
                              : controller.notificationList.isEmpty
                                  ? Center(
                                      child:  TextCustom(
                                      title: "No Available Notification".tr,
                                    ))
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ListView.builder(
                                          physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: controller.groupedNotifications.length,
                                          itemBuilder: (context, index) {
                                            String date = controller.groupedNotifications.keys.elementAt(index);
                                            List<NotificationModel> notifications = controller.groupedNotifications[date]!;

                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Date Header
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    date,
                                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                // Notifications for this date
                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  itemCount: notifications.length,
                                                  itemBuilder: (context, subIndex) {
                                                    NotificationModel notification = notifications[subIndex];
                                                    return NotificationTile(
                                                      notification: notification,
                                                      onDelete: (NotificationModel value) {
                                                        controller.deleteNotification(value);
                                                        // Find the index of the notification in the olderNotifications list
                                                        int index = controller.olderNotifications.indexOf(notification);

                                                        if (index != -1) {
                                                          // Remove the notification if the index is valid
                                                          controller.olderNotifications.removeAt(index);
                                                          controller.groupNotificationsByDate(); // Update the grouped notifications
                                                        } else {
                                                          // Optionally, handle the case where the notification is not found
                                                        }
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                        ],
                      ),
                    ),
                  ),
                )),
          );
        });
  }
}
