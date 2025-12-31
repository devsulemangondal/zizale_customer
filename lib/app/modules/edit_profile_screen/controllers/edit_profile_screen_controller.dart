import 'dart:developer';
import 'dart:io';

import 'package:customer/app/modules/profile_screen/controllers/profile_screen_controller.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/extension/string_extensions.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreenController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Rx<TextEditingController> firstNameController = TextEditingController().obs;
  Rx<TextEditingController> lastNameController = TextEditingController().obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> mobileNumberController = TextEditingController().obs;
  Rx<String?> countryCode = "+91".obs;
  Rx<bool> isLoading = false.obs;
  RxString profileImage = "".obs;
  final ImagePicker imagePicker = ImagePicker();

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    firstNameController.value.text = Constant.userModel!.firstName.toString();
    lastNameController.value.text = Constant.userModel!.lastName.toString();
    emailController.value.text = Constant.userModel!.email.toString();
    mobileNumberController.value.text = Constant.userModel!.phoneNumber.toString();
    countryCode.value = Constant.userModel!.countryCode.toString();
    profileImage.value = Constant.userModel!.profilePic.toString();
  }

  Future<void> updateProfile() async {
    ShowToastDialog.showLoader("Please Wait..".tr);
    if (profileImage.value.isNotEmpty && Constant.hasValidUrl(profileImage.value) == false) {
      profileImage.value = await Constant.uploadImageToFireStorage(
        File(profileImage.value),
        "profileImage/${FireStoreUtils.getCurrentUid()}",
        File(profileImage.value).path.split('/').last,
      );
    }

    // await upLoadImageToFireStore();
    Constant.userModel!.profilePic = profileImage.value;
    Constant.userModel!.firstName = firstNameController.value.text;
    Constant.userModel!.lastName = lastNameController.value.text;
    Constant.userModel!.email = emailController.value.text;
    Constant.userModel!.countryCode = countryCode.value;
    Constant.userModel!.phoneNumber = mobileNumberController.value.text;
    Constant.userModel!.slug = Constant.fullNameString(firstNameController.value.text, lastNameController.value.text).toSlug(delimiter: "-");
    Constant.userModel!.searchNameKeywords = Constant.generateKeywords(Constant.userModel!.fullNameString());
    Constant.userModel!.searchEmailKeywords = Constant.generateKeywords(emailController.value.text);

    await FireStoreUtils.updateUser(Constant.userModel!).then((value) {
      firstNameController.value.clear();
      lastNameController.value.clear();
      emailController.value.clear();
      mobileNumberController.value.clear();
      ProfileScreenController profileScreenController = Get.put(ProfileScreenController());
      profileScreenController.getData();
      ShowToastDialog.showToast("Saved successfully.".tr);
      Get.back();
      ShowToastDialog.closeLoader();
    });
  }

  Future<void> pickFile({required ImageSource source}) async {
    isLoading.value = true;
    try {
      XFile? image = await imagePicker.pickImage(source: source, imageQuality: 100);
      if (image == null) return;

      Get.back();
      Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        image.path,
        quality: 25,
      );
      File compressedFile = File(image.path);
      await compressedFile.writeAsBytes(compressedBytes!);

      profileImage.value = compressedFile.path;
    } catch (e) {
      log("Error picking image: $e");
    }
    isLoading.value = false;
  }
}
