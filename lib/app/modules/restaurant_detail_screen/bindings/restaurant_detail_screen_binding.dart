import 'package:customer/app/modules/restaurant_detail_screen/controllers/restaurant_detail_screen_controller.dart';
import 'package:get/get.dart';

class RestaurantDetailScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RestaurantDetailScreenController>(() => RestaurantDetailScreenController());
  }
}
