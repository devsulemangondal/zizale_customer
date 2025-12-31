import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nb_utils/nb_utils.dart';

class ShowToastDialog {
  static void showLoader(String message) {
    try {
      EasyLoading.show(status: message);
    } catch (e) {
      developer.log("Error in showLoader: $e");
    }
  }

  static void closeLoader() {
    try {
      EasyLoading.dismiss();
    } catch (e) {
      developer.log("Error in closeLoader: $e");
    }
  }

  static void showToast(
    String? value, {
    ToastGravity? gravity,
    length = Toast.LENGTH_SHORT,
    Color? bgColor,
    Color? textColor,
    bool log = false,
  }) {
    try {
      if (value != null && value.isNotEmpty) {
        Fluttertoast.showToast(
          msg: value,
          gravity: gravity,
          toastLength: length,
          backgroundColor: bgColor,
          textColor: textColor,
        );

        if (log) {
          developer.log("Toast logged: $value");
        }
      }
    } catch (e) {
      developer.log("Error in toast: $e");
    }
  }
}
