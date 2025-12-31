import 'package:customer/app/modules/order_screen/controllers/order_screen_controller.dart';
import 'package:get/get.dart';

class OrderScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderScreenController>(() => OrderScreenController());
  }
}
