import 'dart:developer' as developer;
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProfileScreenController extends GetxController {
  Rx<UserModel> userModel = UserModel().obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    try {
      if (FireStoreUtils.getCurrentUid() != null) {
        userModel.value = Constant.userModel!;
        update();
      }
    } catch (e, stack) {
      developer.log("Error getting user data: $e", stackTrace: stack);
    }
  }

  Future<void> deleteUserAccount() async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.customers).doc(FireStoreUtils.getCurrentUid()).delete();

      await FirebaseAuth.instance.currentUser!.delete();
    } on FirebaseAuthException catch (error) {
      log("Firebase Auth Exception : $error");
    } catch (error) {
      log("Error : $error");
    }
  }
}
