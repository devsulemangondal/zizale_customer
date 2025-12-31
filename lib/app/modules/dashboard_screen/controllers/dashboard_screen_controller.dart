import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/models/vendor_model.dart';
import 'package:customer/app/modules/home/views/home_view.dart';
import 'package:customer/app/modules/my_wallet/views/my_wallet_view.dart';
import 'package:customer/app/modules/order_screen/views/order_screen_view.dart';
import 'package:customer/app/modules/profile_screen/views/profile_screen_view.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/order_status.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class DashboardScreenController extends GetxController {
  RxInt selectedIndex = 0.obs;
  RxList pageList = [const HomeView(), const OrderScreenView(), const MyWalletView(), const ProfileScreenView()].obs;
  Rx<OrderModel> bookingOrder = OrderModel().obs;
  Rx<VendorModel> vendorModel = VendorModel().obs;
  Timer? estimateDeliveryTimer;
  RxString estimatedDeliveryTiming = "".obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    if (FireStoreUtils.getCurrentUid() != null) {
      await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()!);
      getLatestOrder();
    }
  }

  void getLatestOrder() {
    FireStoreUtils.fireStore
        .collection(CollectionName.orders)
        .where('customerId', isEqualTo: FireStoreUtils.getCurrentUid())
        .where('orderStatus', whereIn: [
          OrderStatus.orderPending,
          OrderStatus.orderAccepted,
          OrderStatus.driverAssigned,
          OrderStatus.driverAccepted,
          OrderStatus.driverPickup,
          OrderStatus.orderOnReady,
          OrderStatus.driverRejected
        ])
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((event) async {
          if (event.docs.isNotEmpty) {
            bookingOrder.value = OrderModel.fromJson(event.docs.first.data());
            if (bookingOrder.value.vendorId != null && bookingOrder.value.vendorId!.isNotEmpty) {
              getVendorProfile();
            }
            onOrderUpdated();
          } else {
            bookingOrder.value = OrderModel();
            vendorModel.value = VendorModel();
          }
        });
  }

  void getVendorProfile() {
    FireStoreUtils.getRestaurant(bookingOrder.value.vendorId.toString()).then(
      (value) {
        if (value != null) {
          vendorModel.value = value;
        }
      },
    );
  }

  void onOrderUpdated() {
    updateEstimateDeliveryValues(); // update text immediately

    final estimatedDelivery = bookingOrder.value.estimatedDeliveryTime?.estimatedDeliveryAt;
    if (estimatedDelivery != null) {
      startEstimateDeliveryTimer();
    } else {
      stopEstimateDeliveryTimer();
    }
  }

  void startEstimateDeliveryTimer() {
    if (estimateDeliveryTimer != null && estimateDeliveryTimer!.isActive) return;

    estimateDeliveryTimer = Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        updateEstimateDeliveryValues();
      },
    );
  }

  void stopEstimateDeliveryTimer() {
    estimateDeliveryTimer?.cancel();
    estimateDeliveryTimer = null;
  }

  void updateEstimateDeliveryValues() {
    final order = bookingOrder.value;
    final eta = order.estimatedDeliveryTime;

    // 1️⃣ HANDLE ORDER STATUS FIRST
    switch (order.orderStatus) {
      case OrderStatus.orderPending:
        estimatedDeliveryTiming.value = "Waiting for restaurant to accept…";
        return;

      case OrderStatus.orderRejected:
        estimatedDeliveryTiming.value = "Order rejected by restaurant";
        return;

      case OrderStatus.orderCancel:
        estimatedDeliveryTiming.value = "Order cancelled";
        return;

      case OrderStatus.orderComplete:
        estimatedDeliveryTiming.value = "Delivered";
        return;

      case OrderStatus.driverRejected:
        estimatedDeliveryTiming.value = "No driver available";
        return;
    }

    // 2️⃣ IF NO ETA AVAILABLE YET
    if (eta == null) {
      estimatedDeliveryTiming.value = "Calculating ETA…";
      return;
    }

    // 3️⃣ EXTRACT EST ATTRIBUTES
    DateTime? estimatedAt;
    if (eta.estimatedDeliveryAt != null) {
      estimatedAt = eta.estimatedDeliveryAt!.toDate();
    }

    int totalMin = parseMinutesSafe(eta.totalMinutes);
    if (estimatedAt == null && totalMin > 0) {
      estimatedAt = DateTime.now().add(Duration(minutes: totalMin));
    }

    // 4️⃣ ETA LOGIC
    if (estimatedAt != null) {
      final now = DateTime.now();
      final diff = estimatedAt.difference(now);

      if (diff.inSeconds <= 0) {
        final lateMinutes = diff.inMinutes.abs();
        if (lateMinutes < 1) {
          estimatedDeliveryTiming.value = "Arriving now";
        } else {
          estimatedDeliveryTiming.value = 'late_minutes'.trParams({'minutes': lateMinutes.toString()});
        }
      } else if (diff.inMinutes < 1) {
        final arrivesAt = Constant.timestampToTime12Hour(Timestamp.fromDate(estimatedAt));
        estimatedDeliveryTiming.value = "arrives_at".trParams({'difference': diff.inSeconds.toString(), 'arrives_at': arrivesAt});
      } else {
        final mins = diff.inMinutes;
        final arrivesAt = Constant.timestampToTime12Hour(Timestamp.fromDate(estimatedAt));
        estimatedDeliveryTiming.value = "arrives_min".trParams({'minutes': mins.toString(), 'arrives_at': arrivesAt});
      }
    } else if (totalMin > 0) {
      estimatedDeliveryTiming.value = "total_min".trParams({'minute': totalMin.toString()});
    } else {
      estimatedDeliveryTiming.value = "";
    }
  }

  int parseMinutesSafe(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
