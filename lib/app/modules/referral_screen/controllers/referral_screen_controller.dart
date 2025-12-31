import 'package:customer/app/models/referral_model.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';

class ReferralScreenController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<ReferralModel> referralModel = ReferralModel().obs;
  Rx<UserModel> userModel = UserModel().obs;

  @override
  void onInit() {
    getReferralCode();
    super.onInit();
  }

  Future<void> getReferralCode() async {
    try {
      await FireStoreUtils.getReferral().then((value) {
        if (value != null) {
          referralModel.value = value;
          isLoading.value = false;
        } else {
          isLoading.value = false;
        }
      });
    } catch (e) {
      isLoading.value = false;
    }
  }

  Future<void> createReferEarnCode() async {
    isLoading.value = true;
    await FireStoreUtils.fireStore.collection(CollectionName.customers).doc(FireStoreUtils.getCurrentUid()).get().then((value) {
      if (value.exists) {
        userModel.value = UserModel.fromJson(value.data()!);
      }
    });

    String firstTwoChar = userModel.value.slug!.substring(0, 2).toUpperCase();

    ReferralModel referralModel =
        ReferralModel(userId: FireStoreUtils.getCurrentUid(), role: Constant.user, referralRole: "", referralBy: "", referralCode: Constant.getReferralCode(firstTwoChar));
    await FireStoreUtils.referralAdd(referralModel);
    await getReferralCode();
    isLoading.value = false;
  }
}
