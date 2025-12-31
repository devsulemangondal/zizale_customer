import 'package:customer/app/modules/select_address/controllers/select_address_controller.dart';
import 'package:get/get.dart';

class SelectAddressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelectAddressController>(() => SelectAddressController());
  }
}
