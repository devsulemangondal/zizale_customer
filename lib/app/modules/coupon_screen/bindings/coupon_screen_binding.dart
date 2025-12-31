import 'package:customer/app/modules/coupon_screen/controllers/coupon_screen_controller.dart';
import 'package:get/get.dart';

class CouponScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CouponScreenController>(() => CouponScreenController());
  }
}
