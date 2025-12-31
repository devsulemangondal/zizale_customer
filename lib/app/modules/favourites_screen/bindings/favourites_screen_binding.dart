import 'package:customer/app/modules/favourites_screen/controllers/favourites_screen_controller.dart';
import 'package:get/get.dart';

class FavouritesScreenBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<FavouritesScreenController>(()=>FavouritesScreenController());
  }
}
