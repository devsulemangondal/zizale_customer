import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServiceUnavailableScreen extends StatelessWidget {
  final String message;

  const ServiceUnavailableScreen(
      {super.key, this.message = "It looks like our service is currently not available in your area. We’re constantly expanding and hope to reach your location soon."});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/icons/ic_location_off.png",
            width: 100,
            height: 100,
          ),
          SizedBox(height: 20),
          TextCustom(
            title: "Oops!".tr,
            maxLine: 6,
            textAlign: TextAlign.center,
            fontSize: 24,
            fontFamily: FontFamily.bold,
          ),
          SizedBox(height: 12),
          TextCustom(
            title: message,
            maxLine: 6,
            textAlign: TextAlign.center,
            fontSize: 18,
          ),
        ],
      ),
    );
  }
}
