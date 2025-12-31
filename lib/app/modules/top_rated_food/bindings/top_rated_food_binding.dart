import 'package:get/get.dart';

import '../controllers/top_rated_food_controller.dart';

class TopRatedFoodBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TopRatedFoodController>(
      () => TopRatedFoodController(),
    );
  }
}
