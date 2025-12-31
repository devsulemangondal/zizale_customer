import 'package:customer/app/modules/order_detail_screen/controllers/order_detail_screen_controller.dart';
import 'package:get/get.dart';

class OrderDetailScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderDetailScreenController>(() => OrderDetailScreenController());
  }
}
