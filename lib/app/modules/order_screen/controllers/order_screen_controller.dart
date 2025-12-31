import 'dart:developer' as developer;

import 'package:customer/app/models/booking_model.dart';
import 'package:customer/services/database_helper.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class OrderScreenController extends GetxController {
  RxBool isLoading = true.obs;
  RxInt selectedOrderType = 0.obs;
  RxList<OrderModel> pendingOrderList = <OrderModel>[].obs;
  RxList<OrderModel> completedOrderList = <OrderModel>[].obs;
  RxList<OrderModel> cancelledOrderList = <OrderModel>[].obs;

  CartDatabaseHelper cartDatabaseHelper = CartDatabaseHelper();

  @override
  void onInit() {
    getData(isPendingOrderFetch: true, isCompletedOrderFetch: true, isCancelledOrderFetch: true);
    super.onInit();
  }

  Future<void> getData({
    required bool isPendingOrderFetch,
    required bool isCompletedOrderFetch,
    required bool isCancelledOrderFetch,
  }) async {
    isLoading.value = true;

    if (FireStoreUtils.getCurrentUid() == null) {
      pendingOrderList.clear();
      completedOrderList.clear();
      cancelledOrderList.clear();
      isLoading.value = false;
      return;
    }
    try {
      FireStoreUtils.getAllOrderList().listen((ordersMap) {
        try {
          pendingOrderList.value = ordersMap['pendingOrders'] ?? [];
          completedOrderList.value = ordersMap['completedOrders'] ?? [];
          cancelledOrderList.value = ordersMap['cancelledOrders'] ?? [];
          isLoading.value = false;
        } catch (e, stack) {
          developer.log("Error processing orders: $e", error: e, stackTrace: stack);
          isLoading.value = false;
        }
      }, onError: (error, stack) {
        developer.log("Error fetching orders: $error", error: error, stackTrace: stack);
        isLoading.value = false;
      });
    } catch (e, stack) {
      developer.log("Error fetching orders: $e", error: e, stackTrace: stack);
      isLoading.value = false;
    }
  }
}
