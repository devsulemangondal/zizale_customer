import 'package:get/get.dart';

import '../controllers/restaurant_by_cuisine_controller.dart';

class RestaurantByCuisineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RestaurantByCuisineController>(
      () => RestaurantByCuisineController(),
    );
  }
}
