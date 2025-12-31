import 'dart:developer' as developer;
import 'dart:ui';

import 'package:customer/app/models/language_model.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/preferences.dart';
import 'package:get/get.dart';


class LanguageScreenController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<LanguageModel> languageList = <LanguageModel>[].obs;
  Rx<LanguageModel> selectedLanguage = LanguageModel().obs;

  RxList<Color> lightModeColors = [AppThemeData.secondary50, AppThemeData.green50, AppThemeData.info50, AppThemeData.pending50].obs;

  RxList<Color> darkModeColors = [AppThemeData.secondary600, AppThemeData.green600, AppThemeData.info600, AppThemeData.pending600].obs;

  RxList<Color> activeColor = [AppThemeData.secondary300, AppThemeData.success300, AppThemeData.info300, AppThemeData.pending300].obs;

  RxList<Color> textColorLightMode = [AppThemeData.secondary400, AppThemeData.success400, AppThemeData.info400, AppThemeData.pending400].obs;

  RxList<Color> textColorDarkMode = [AppThemeData.secondary200, AppThemeData.success200, AppThemeData.info200, AppThemeData.pending200].obs;

  @override
  void onInit() {
    getLanguage();
    super.onInit();
  }

  Future<void> getLanguage() async {
    try {
      isLoading.value = true;

      final value = await FireStoreUtils.getLanguage();
      languageList.value = value;

      final savedLangCode = Preferences.getString(Preferences.languageCodeKey);
      if (savedLangCode.isNotEmpty) {
        LanguageModel pref = Constant.getLanguage();

        for (var element in languageList) {
          if (element.id == pref.id) {
            selectedLanguage.value = element;
            break;
          }
        }
      }
    } catch (e, stackTrace) {
     developer.log("Error fetching languages: ", error: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
      update();
    }
  }

}
