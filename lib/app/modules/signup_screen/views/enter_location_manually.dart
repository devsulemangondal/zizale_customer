// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:customer/app/models/location_lat_lng.dart';
import 'package:customer/app/modules/dashboard_screen/views/dashboard_screen_view.dart';
import 'package:customer/app/modules/home/controllers/home_controller.dart';
import 'package:customer/app/modules/login_screen/controllers/login_screen_controller.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constant/place_picker/location_picker_screen.dart';
import '../../../../constant/place_picker/selected_location_model.dart';
import '../../../../themes/common_ui.dart';

// ignore: must_be_immutable
class EnterLocationManuallyView extends GetView<LoginScreenController> {
  EnterLocationManuallyView({super.key});

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
      init: LoginScreenController(),
      builder: (controller) {
        return Scaffold(
          appBar: UiInterface.customAppBar(context, themeChange, "", backgroundColor: Colors.transparent),
          backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTopWidget(context),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        validator: (value) => value != null && value.isNotEmpty ? null : "This field required".tr,
                        textCapitalization: TextCapitalization.sentences,
                        controller: controller.addressController.value,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        onTap: () async {
                          await controller.checkPermission(
                            () async {
                              Get.to(LocationPickerScreen())!.then((value) async {
                                SelectedLocationModel selectedLocation = value!;
                                final placeMark = await placemarkFromCoordinates(selectedLocation.latLng!.latitude, selectedLocation.latLng!.longitude);
                                if (placeMark.isNotEmpty) {
                                  final result = placeMark.first;
                                  controller.addressController.value.text =
                                      "${result.name}, ${result.locality}, ${result.administrativeArea}, ${result.postalCode}, ${result.country}";
                                  controller.addAddressModel.value.locality = result.locality;
                                  controller.addAddressModel.value.landmark = result.subLocality;
                                  controller.addAddressModel.value.location =
                                      LocationLatLng(latitude: selectedLocation.latLng!.latitude, longitude: selectedLocation.latLng!.longitude);
                                  controller.addAddressModel.value.address = controller.addressController.value.text;
                                  controller.addAddressModel.value.id = Constant.getUuid();
                                  controller.addAddressModel.value.isDefault = true;
                                  controller.addAddressModel.value.addressAs = "Home";
                                  controller.addAddressModel.value.name = FireStoreUtils.getCurrentUid() != null ? Constant.userModel!.fullNameString() : "";

                                  Constant.currentLocation = controller.addAddressModel.value;
                                  if (Get.isRegistered<HomeController>()) {
                                    Get.find<HomeController>().selectedAddress.value = Constant.currentLocation!;
                                  }

                                  await Constant.checkZoneAvailability(Constant.currentLocation!.location!);

                                  if (FireStoreUtils.getCurrentUid() != null) {
                                    controller.saveAddress();
                                  }

                                  Get.offAll(const DashboardScreenView());
                                }
                              });
                            },
                          );
                        },
                        textAlignVertical: TextAlignVertical.top,
                        style: TextStyle(
                            //color: AppColors.grey800,
                            color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800,
                            fontFamily: FontFamily.regular,
                            fontSize: 14),
                        decoration: InputDecoration(
                            errorStyle: const TextStyle(fontFamily: FontFamily.regular),
                            fillColor: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey100,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            prefixIcon: Row(
                              children: [
                                spaceW(width: 16),
                                SvgPicture.asset(
                                  "assets/icons/ic_search.svg",
                                  color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800,
                                  height: 19.h,
                                  width: 19.w,
                                ),
                                spaceW(width: 16)
                              ],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400, width: 1),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400, width: 1),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400, width: 1),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppThemeData.danger300, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: AppThemeData.orange300, width: 1),
                            ),
                            hintText: "try digital valley, mota varachha".tr,
                            hintStyle: TextStyle(fontSize: 14, color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600, fontFamily: FontFamily.regular)),
                      ),
                      spaceH(height: 16),
                      GestureDetector(
                        onTap: () {
                          controller.getUserLocation();
                        },
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              "assets/icons/ic_arrow.svg",
                              color: AppThemeData.orange300,
                            ),
                            spaceW(width: 8),
                            TextCustom(
                              title: "Use my current location".tr,
                              fontSize: 16,
                              fontFamily: FontFamily.medium,
                              color: AppThemeData.orange300,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  SizedBox buildTopWidget(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SizedBox(
      child: Text("Enter your area or apartment name here".tr,
          maxLines: 2,
          style: TextStyle(
            fontFamily: FontFamily.bold,
            fontSize: 28,
            color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
          )),
    );
  }
}
