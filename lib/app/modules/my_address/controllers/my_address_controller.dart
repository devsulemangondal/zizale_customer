import 'dart:developer' as developer;

import 'package:customer/app/models/add_address_model.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class MyAddressController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<AddAddressModel> addressList = <AddAddressModel>[].obs;
  Rx<AddAddressModel> addressModel = AddAddressModel().obs;

  @override
  onInit() async {
    await getData();
    super.onInit();
  }

  Future<void> getData() async {
    try {
      isLoading.value = true;
      addressList.clear();

      final user = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()!);

      if (user != null && user.addAddresses != null) {
        addressList.addAll(user.addAddresses!);
      } else {
        ShowToastDialog.showToast("No address data found.".tr);
      }
    } catch (e, stackTrace) {
      developer.log("Error in getData: $e", error: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAddress(int index) async {
    try {
      final address = Constant.userModel!.addAddresses![index];

      if (address.isDefault == true) {
        ShowToastDialog.showToast("Cannot delete default address.".tr);
        return;
      }

      Constant.userModel!.addAddresses!.removeAt(index);
      final result = await FireStoreUtils.updateUser(Constant.userModel!);

      if (result == true) {
        ShowToastDialog.showToast("Address deleted successfully.".tr);
        getData();
      } else {
        ShowToastDialog.showToast("Failed to delete address.".tr);
      }
    } catch (e, stackTrace) {
      developer.log("Error in deleteAddress: $e", error: e, stackTrace: stackTrace);
    }
  }
}
