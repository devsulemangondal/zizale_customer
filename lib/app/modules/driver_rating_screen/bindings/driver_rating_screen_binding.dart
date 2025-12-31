import 'package:customer/app/modules/driver_rating_screen/controllers/driver_rating_screen_controller.dart';
import 'package:get/get.dart';

class DriverRatingScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverRatingScreenController>(() => DriverRatingScreenController());
  }
}
