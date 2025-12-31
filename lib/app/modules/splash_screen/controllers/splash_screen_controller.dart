import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:customer/app/models/language_model.dart';
import 'package:customer/app/modules/account_disabled_screen.dart';
import 'package:customer/app/modules/dashboard_screen/views/dashboard_screen_view.dart';
import 'package:customer/app/modules/intro_screen/views/intro_screen_view.dart';
import 'package:customer/app/modules/signup_screen/views/enter_location_view.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/global_controller.dart';
import 'package:customer/services/localization_service.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/preferences.dart';
import 'package:get/get.dart';

class SplashScreenController extends GetxController {
  @override
  Future<void> onInit() async {
    await getCurrentCurrency();
    checkLanguage();
    Timer(
      const Duration(seconds: 3),
      () {
        redirectScreen();
      },
    );
    super.onInit();
  }

  Future<void> redirectScreen() async {
    try {
      if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
        Get.offAll(const IntroScreenView());
        return;
      }
      bool isLogin = await FireStoreUtils.isLogin();
      if (isLogin) {
        Constant.userModel = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()!);
        if (Constant.userModel == null) {
          Get.offAll(EnterLocationView());
          return;
        }
        if (Constant.userModel!.isActive == true) {
          if (Constant.userModel!.addAddresses == null || Constant.userModel!.addAddresses!.isEmpty) {
            Get.to(EnterLocationView());
            return;
          }
          await Constant.checkZoneAvailability(
            Constant.userModel!.addAddresses!
                .firstWhere(
                  (e) => e.isDefault == true,
                  orElse: () => Constant.userModel!.addAddresses!.first,
                )
                .location!,
          );
          Get.offAll(const DashboardScreenView());
        } else {
          Get.offAll(const AccountDisabledScreen());
        }
      } else {
        Get.offAll(EnterLocationView());
      }
    } catch (e, stack) {
      developer.log("Error in redirectScreen: ", error: e, stackTrace: stack);
    }
  }

  // Future<void> redirectScreen() async {
  //   try {
  //     if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
  //       Get.offAll(const IntroScreenView());
  //     } else {
  //       bool isLogin = await FireStoreUtils.isLogin();
  //       if (isLogin == true) {
  //         if (Constant.userModel!.isActive == true) {
  //           Constant.userModel = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid());
  //           if (Constant.userModel!.addAddresses == null || Constant.userModel!.addAddresses!.isEmpty) {
  //             Get.to(EnterLocationView());
  //           } else {
  //             Get.offAll(const DashboardScreenView());
  //           }
  //         } else {
  //           Get.offAll(const AccountDisabledScreen());
  //         }
  //       } else {
  //         Get.offAll(const LandingScreenView());
  //       }
  //     }
  //   } catch (e, stack) {
  //     developer.log("Error in redirectScreen: ", error: e, stackTrace: stack);
  //   }
  // }

  Future<void> checkLanguage() async {
    try {
      if (Preferences.getString(Preferences.languageCodeKey).toString().isNotEmpty) {
        LanguageModel languageModel = Constant.getLanguage();
        LocalizationService().changeLocale(languageModel.code.toString());
      } else {
        LanguageModel languageModel = LanguageModel(
          id: "LzSABjMohyW3MA0CaxVH",
          code: "en",
          isRtl: false,
          name: "English",
        );
        Preferences.setString(Preferences.languageCodeKey, jsonEncode(languageModel.toJson()));
        LocalizationService().changeLocale(languageModel.code.toString());
      }
    } catch (e, stack) {
      developer.log("Error in checkLanguage: ", error: e, stackTrace: stack);
    }
  }
}
