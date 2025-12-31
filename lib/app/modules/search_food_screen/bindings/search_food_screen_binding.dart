import 'package:customer/app/modules/search_food_screen/controllers/search_food_controller.dart';
import 'package:get/get.dart';

class SearchFoodScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchFoodScreenController>(() => SearchFoodScreenController());
  }
}
