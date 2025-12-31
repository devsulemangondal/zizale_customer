import 'package:customer/lang/app_ar.dart';
import 'package:customer/lang/app_en.dart';
import 'package:customer/lang/app_hi.dart';
import 'package:customer/lang/app_fr.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocalizationService extends Translations {
  // Default locale
  static const locale = Locale('en', 'US');

  static final locales = [
    const Locale('en'),
    const Locale('hi'),
    const Locale('ar'),
    // const Locale('es'),
    const Locale('fr'),
  ];

  // Keys and their translations
  // Translations are separated maps in `lang` file
  @override
  Map<String, Map<String, String>> get keys =>
      {
        'en': enUS,
        'hi': hiIN,
        'ar': lnAr,
        // 'es': esES,
        'fr': frFR,
      };

  // Gets locale from language, and updates the locale
  void changeLocale(String lang) {
    Get.updateLocale(Locale(lang));
  }
}
