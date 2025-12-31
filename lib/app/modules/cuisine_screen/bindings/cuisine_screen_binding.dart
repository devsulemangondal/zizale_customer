import 'package:customer/app/modules/cuisine_screen/controllers/cuisine_screen_controller.dart';
import 'package:get/get.dart';

class CuisineScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CuisineScreenController>(() => CuisineScreenController());
  }
}
