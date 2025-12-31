// ignore_for_file: deprecated_member_use

import 'dart:developer' as developer;

import 'package:customer/app/models/currency_model.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GlobalController extends GetxController {
  Future<void> getSettingData() async {
    await FireStoreUtils().getSettings();
    AppThemeData.orange300 = HexColor.fromHex(Constant.appColor.toString());
  }

  @override
  Future<void> onInit() async {
    await getSettingData();
    notificationInit();
    await getCurrentCurrency();
    super.onInit();
  }
}

Future<void> getCurrentCurrency() async {
  try {
    final value = await FireStoreUtils().getCurrency();
    if (value != null) {
      Constant.currencyModel = value;
    } else {
      Constant.currencyModel = CurrencyModel(
        id: "",
        code: "USD",
        decimalDigits: 2,
        enable: true,
        name: "US Dollar",
        symbol: "\$",
        symbolAtRight: false,
      );
    }
  } catch (e) {
    developer.log("Error fetching currency: $e");
    Constant.currencyModel = CurrencyModel(
      id: "",
      code: "USD",
      decimalDigits: 2,
      enable: true,
      name: "US Dollar",
      symbol: "\$",
      symbolAtRight: false,
    );
  }

  try {
    await FireStoreUtils().getSettings();
  } catch (e) {
    developer.log("Error fetching settings: $e");
  }

  try {
    await FireStoreUtils().getPayment();
  } catch (e) {
    developer.log("Error fetching payment settings: $e");
  }

  try {
    AppThemeData.orange300 = HexColor.fromHex(Constant.appColor.toString());
  } catch (e) {
    developer.log("Error setting app color: $e");
  }
}

NotificationService notificationService = NotificationService();

Future<void> notificationInit() async {
  try {
    await notificationService.initInfo();
    String token = await NotificationService.getToken();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final value = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()!);
        if (value != null) {
          UserModel userModel = value;
          userModel.fcmToken = token;
          await FireStoreUtils.updateUser(userModel);
        }
      } catch (e) {
        developer.log("Error updating user FCM token: $e");
      }
    }
  } catch (e) {
    developer.log("Error initializing notification: $e");
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      developer.log("Invalid hex color: $hexString - Error: $e");
      return Colors.transparent; // fallback to a safe default
    }
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
