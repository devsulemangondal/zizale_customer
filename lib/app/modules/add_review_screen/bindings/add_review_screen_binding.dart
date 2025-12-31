import 'package:customer/app/modules/add_review_screen/controllers/add_review_screen_controller.dart';
import 'package:get/get.dart';

class AddReviewScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddReviewScreenController>(() => AddReviewScreenController());
  }
}
