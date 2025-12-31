// ignore_for_file: depend_on_referenced_packages

import 'dart:developer' as developer;

import 'package:customer/app/models/notification_model.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../constant/show_toast_dialog.dart';

class NotificationScreenController extends GetxController {
  RxBool isLoading = false.obs;

  RxList<NotificationModel> notificationList = <NotificationModel>[].obs;
  RxList<NotificationModel> olderNotifications = <NotificationModel>[].obs;
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  var groupedNotifications = <String, List<NotificationModel>>{}.obs;

  @override
  void onInit() {
    getNotifications();
    super.onInit();
  }

  void getNotifications() {
    isLoading.value = true;
    if (FireStoreUtils.getCurrentUid() == null) {
      notificationList.clear();
      groupedNotifications.clear();
      isLoading.value = false;
      return;
    }

    try {
      FireStoreUtils.getNotificationList().listen((snapshot) {
        try {
          List<NotificationModel> notifications = [];

          for (var doc in snapshot.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            NotificationModel notification = NotificationModel.fromJson(data);
            notifications.add(notification);
          }

          notificationList.value = notifications;
          groupNotificationsByDate();
          isLoading.value = false;
        } catch (e, stack) {
          developer.log("Error processing notifications: $e", stackTrace: stack);
          isLoading.value = false;
          ShowToastDialog.showToast("Failed to process notifications: $e");
        }
      }, onError: (error, stack) {
        developer.log("Error fetching notifications: $error", stackTrace: stack);
        isLoading.value = false;
        ShowToastDialog.showToast("Failed to load notifications: $error");
      });
    } catch (e, stack) {
      developer.log("Error fetching notifications: $e", stackTrace: stack);
      isLoading.value = false;
      ShowToastDialog.showToast("An unexpected error occurred: $e");
    }
  }

  void groupNotificationsByDate() {
    try {
      Map<String, List<NotificationModel>> tempGroupedNotifications = {};

      for (var notification in notificationList) {
        if (notification.createdAt != null) {
          String formattedDate = DateFormat('dd/MM/yyyy').format(notification.createdAt!.toDate());
          tempGroupedNotifications.putIfAbsent(formattedDate, () => []);
          tempGroupedNotifications[formattedDate]!.add(notification);
        }
      }

      groupedNotifications.value = tempGroupedNotifications;
    } catch (e, stack) {
      developer.log("Error grouping notifications: $e", stackTrace: stack);
      ShowToastDialog.showToast("Failed to group notifications: $e");
    }
  }

  Future<void> deleteNotification(NotificationModel notification) async {
    try {
      await fireStore.collection(CollectionName.notification).doc(notification.id).delete();

      notificationList.removeWhere((n) => n.id == notification.id);
      groupNotificationsByDate();

      ShowToastDialog.showToast("Notification deleted successfully.".tr);
    } catch (e, stack) {
      developer.log("Error deleting notification: $e", stackTrace: stack);
      ShowToastDialog.showToast("Failed to delete notification: $e");
    }
  }
}
