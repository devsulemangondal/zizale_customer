// ignore_for_file: depend_on_referenced_packages

import 'dart:developer' as developer;

import 'package:customer/app/models/add_address_model.dart';
import 'package:customer/app/widget/permission_dialog.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class SelectAddressController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<AddAddressModel> selectedAddress = AddAddressModel().obs;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RxList<AddAddressModel> addAddressModelList = <AddAddressModel>[].obs;
  Rx<TextEditingController> addressController = TextEditingController().obs;
  Rx<TextEditingController> locationController = TextEditingController().obs;
  Rx<AddAddressModel> addAddressModel = AddAddressModel().obs;
  RxString addressAs = 'Home'.obs;

  @override
  onInit() async {
    await getData();
    if (addAddressModelList.isNotEmpty) {
      selectedAddress.value = addAddressModelList.firstWhere(
        (address) => address.isDefault == true,
        orElse: () => addAddressModelList[0], // fallback
      );
    }
    super.onInit();
  }

  Future<void> getData() async {
    isLoading.value = true;
    try {
      addAddressModelList.clear();
      if (FireStoreUtils.getCurrentUid() != null) {
        final userProfile = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()!);
        if (userProfile != null && userProfile.addAddresses != null) {
          addAddressModelList.addAll(userProfile.addAddresses!);
        }
      }
    } catch (e, stack) {
      developer.log(
        'Error getting addresses: ',
        error: e,
        stackTrace: stack,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void checkPermission(Function() onTap) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        ShowToastDialog.showToast("You have to allow location permission to use your location".tr);
      } else if (permission == LocationPermission.deniedForever) {
        showDialog(
          context: Get.context!,
          builder: (BuildContext context) {
            return const PermissionDialog();
          },
        );
      } else {
        onTap();
      }
    } catch (e, stack) {
      developer.log(
        'Error checking location permission: ',
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<void> saveAddress() async {
    isLoading.value = true;
    try {
      Constant.userModel!.addAddresses!.add(addAddressModel.value);
      bool? updated = await FireStoreUtils.updateUser(Constant.userModel!);
      ShowToastDialog.closeLoader();

      if (updated == true) {
        Constant.userModel = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()!);
      }
      await getData();
    } catch (e, stack) {
      developer.log(
        'Error saving address: ',
        error: e,
        stackTrace: stack,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAddress(String addressId) async {
    try {
      for (var element in Constant.userModel!.addAddresses!) {
        if (element.id == addressId) {
          element.address = locationController.value.text + addressController.value.text;
          element.addressAs = addressAs.value;
          element.landmark = addAddressModel.value.landmark;
          element.locality = addAddressModel.value.locality;
          element.location = addAddressModel.value.location;
          // The line 'element.isDefault = element.isDefault;' does nothing and can be removed
        }
      }
      await FireStoreUtils.updateUser(Constant.userModel!);
    } catch (e, stack) {
      developer.log(
        'Error updating address: ',
        error: e,
        stackTrace: stack,
      );
    }
  }
}
