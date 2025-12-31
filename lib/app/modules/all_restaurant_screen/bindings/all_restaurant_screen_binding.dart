import 'package:customer/app/modules/all_restaurant_screen/controllers/all_restaurant_screen_controller.dart';
import 'package:get/get.dart';

class AllRestaurantScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllRestaurantScreenController>(() => AllRestaurantScreenController());
  }
}
