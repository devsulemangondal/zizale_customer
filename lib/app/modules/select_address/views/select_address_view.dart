// ignore_for_file: deprecated_member_use, must_be_immutable, depend_on_referenced_packages

import 'dart:developer';

import 'package:customer/app/models/location_lat_lng.dart';
import 'package:customer/app/modules/home/controllers/home_controller.dart';
import 'package:customer/app/modules/my_address/controllers/my_address_controller.dart';
import 'package:customer/app/modules/my_cart/controllers/my_cart_controller.dart';
import 'package:customer/app/modules/select_address/controllers/select_address_controller.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/text_field_widget.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/constant_widgets/container_custom.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/constant_widgets/top_widget.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/common_ui.dart';
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

class SelectAddressView extends GetView<SelectAddressController> {
  bool isFromCart;

  SelectAddressView({super.key, this.isFromCart = false});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<SelectAddressController>(
        init: SelectAddressController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface.customAppBar(context, themeChange, "", backgroundColor: Colors.transparent),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildTopWidget(context, "Select Delivery Address".tr, "Add, edit, or select your delivery address for a smooth ordering experience.".tr),
                    spaceH(height: 24),
                    GestureDetector(
                      onTap: () {
                        controller.checkPermission(
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
                                controller.addAddressModel.value.isDefault = false;
                                // controller.addAddressModel.value.addressAs = "Home";
                                controller.addAddressModel.value.name = Constant.userModel!.fullNameString();

                                Get.bottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                    const AddAddressBottomSheet(
                                      addressId: "",
                                    ));
                              }
                            });
                          },
                        );
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/ic_add.svg",
                            height: 24,
                          ),
                          spaceW(width: 12),
                          TextCustom(
                            title: "Add New Address".tr,
                            fontSize: 16,
                            fontFamily: FontFamily.regular,
                            color: AppThemeData.orange300,
                          ),
                        ],
                      ),
                    ),
                    spaceH(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.addAddressModelList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                            decoration:
                                BoxDecoration(color: themeChange.isDarkTheme() ? AppThemeData.surface1000 : AppThemeData.surface50, borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 40.h,
                                      width: 40.w,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: themeChange.isDarkTheme() ? AppThemeData.grey700 : AppThemeData.grey300)),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          controller.addAddressModelList[index].addressAs == "Home"
                                              ? "assets/icons/ic_home_outline.svg"
                                              : controller.addAddressModelList[index].addressAs == "Work"
                                                  ? "assets/icons/ic_work.svg"
                                                  : controller.addAddressModelList[index].addressAs == "Friends and Family"
                                                      ? "assets/icons/ic_user.svg"
                                                      : "assets/icons/ic_location.svg",
                                          color: AppThemeData.orange300,
                                        ),
                                      ),
                                    ),
                                    spaceW(width: 12),
                                    Expanded(
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        TextCustom(
                                          title: controller.addAddressModelList[index].addressAs.toString(),
                                          textAlign: TextAlign.start,
                                          fontSize: 16,
                                          fontFamily: FontFamily.medium,
                                          color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                        ),
                                        TextCustom(
                                          title: controller.addAddressModelList[index].address.toString(),
                                          // + controller.addAddressModelList[index].locality.toString(),
                                          maxLine: 3,
                                          fontSize: 14,
                                          fontFamily: FontFamily.light,
                                          color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                          textAlign: TextAlign.start,
                                        ),
                                      ]),
                                    ),
                                    Obx(
                                      () => Radio(
                                        value: controller.addAddressModelList[index],
                                        groupValue: controller.selectedAddress.value,
                                        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                                          if (states.contains(WidgetState.selected)) {
                                            return AppThemeData.orange300;
                                          } else {
                                            return themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600;
                                          }
                                        }),
                                        onChanged: (selectedAddress) async {
                                          try {
                                            ShowToastDialog.showLoader("Please Wait..".tr);
                                            await Constant.checkZoneAvailability(selectedAddress!.location!);

                                            if (isFromCart && !Constant.isZoneAvailable) {
                                              ShowToastDialog.closeLoader();
                                              return;
                                            }

                                            controller.selectedAddress.value = selectedAddress;
                                            Constant.currentLocation = selectedAddress;

                                            if (isFromCart) {
                                              MyCartController myCartController = Get.put(MyCartController());
                                              myCartController.calculationOfDeliveryCharge();
                                              ShowToastDialog.closeLoader();
                                              Get.back();
                                            } else {
                                              for (var element in Constant.userModel!.addAddresses!) {
                                                element.isDefault = false;
                                              }

                                              Constant
                                                  .userModel!
                                                  .addAddresses![
                                                      Constant.userModel!.addAddresses!.indexWhere((element) => element.id == controller.addAddressModelList[index].id.toString())]
                                                  .isDefault = true;

                                              await FireStoreUtils.updateUser(Constant.userModel!);
                                              Constant.userModel = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()!);

                                              HomeController homeController = Get.put(HomeController());
                                              await homeController.getLocation();
                                              await homeController.getNearbyRestaurant();
                                              homeController.update();

                                              ShowToastDialog.closeLoader();
                                              Get.back();
                                            }
                                          } catch (e, stack) {
                                            log("Error in onChanged (address): $e", stackTrace: stack);
                                            ShowToastDialog.closeLoader();
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                controller.addAddressModelList[index].isDefault!
                                    ? Container(
                                        margin: const EdgeInsets.only(right: 10, bottom: 6),
                                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                        decoration: BoxDecoration(color: AppThemeData.orange300, borderRadius: BorderRadius.circular(20)),
                                        child: Text(
                                          "Default".tr,
                                          style: TextStyle(fontFamily: FontFamily.medium, fontSize: 14, color: AppThemeData.primaryWhite),
                                        ),
                                      )
                                    : SizedBox(),
                              ],
                            ));
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class AddAddressBottomSheet extends StatelessWidget {
  final String? addressId;

  const AddAddressBottomSheet({super.key, this.addressId});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: SelectAddressController(),
      builder: (controller) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Form(
            key: controller.formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  spaceH(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: AlignmentDirectional.center,
                      child: Container(
                        height: 8.h,
                        width: 72.w,
                        decoration: BoxDecoration(color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400, borderRadius: BorderRadius.circular(100)),
                      ),
                    ),
                  ),
                  spaceH(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GestureDetector(
                              onTap: () {
                                Get.back();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey100,
                                ),
                                height: 34.h,
                                width: 34.w,
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 20,
                                  color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                ),
                              ),
                            ),
                          ),
                          spaceH(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextCustom(
                              title: addressId!.isNotEmpty ? "Edit Address".tr : "Add Address".tr,
                              fontSize: 20,
                              maxLine: 2,
                              textAlign: TextAlign.start,
                              fontFamily: FontFamily.bold,
                              color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                            ),
                          ),
                          spaceH(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextCustom(
                              title: "To ensure accurate delivery or service, please provide your address details below.".tr,
                              fontSize: 16,
                              maxLine: 3,
                              fontFamily: FontFamily.regular,
                              textAlign: TextAlign.start,
                              color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                            ),
                          ),
                          spaceH(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ContainerCustom(
                              child: Row(
                                children: [
                                  Container(
                                    height: 40.h,
                                    width: 40.w,
                                    decoration: BoxDecoration(
                                      color: AppThemeData.orange300,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(child: SvgPicture.asset("assets/icons/ic_location.svg")),
                                  ),
                                  spaceW(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(
                                          title: controller.selectedAddress.value.locality.toString(),
                                          fontSize: 16,
                                          fontFamily: FontFamily.medium,
                                          color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                        ),
                                        TextCustom(
                                          title: controller.selectedAddress.value.address.toString(),
                                          fontSize: 14,
                                          fontFamily: FontFamily.light,
                                          textAlign: TextAlign.start,
                                          color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          spaceH(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextCustom(
                              title: "Save as".tr,
                              fontSize: 16,
                              fontFamily: FontFamily.medium,
                              color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                            ),
                          ),
                          spaceH(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: SizedBox(
                              height: 48.h,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  CommonTile(
                                    title: "Home".tr,
                                    icon: "assets/icons/ic_home_outline.svg",
                                    textColor: controller.addressAs.value == "Home"
                                        ? AppThemeData.primaryWhite
                                        : themeChange.isDarkTheme()
                                            ? AppThemeData.grey400
                                            : AppThemeData.grey600,
                                    iconColor: controller.addressAs.value == "Home"
                                        ? AppThemeData.primaryWhite
                                        : themeChange.isDarkTheme()
                                            ? AppThemeData.grey400
                                            : AppThemeData.grey600,
                                    backgroundColor: controller.addressAs.value == "Home"
                                        ? AppThemeData.secondary300
                                        : themeChange.isDarkTheme()
                                            ? AppThemeData.grey800
                                            : AppThemeData.grey200,
                                    onPress: () {
                                      controller.addressAs.value = "Home";
                                    },
                                  ),
                                  CommonTile(
                                    title: "Work".tr,
                                    icon: "assets/icons/ic_work.svg",
                                    textColor: controller.addressAs.value == "Work"
                                        ? AppThemeData.primaryWhite
                                        : themeChange.isDarkTheme()
                                            ? AppThemeData.grey400
                                            : AppThemeData.grey600,
                                    iconColor: controller.addressAs.value == "Work"
                                        ? AppThemeData.primaryWhite
                                        : themeChange.isDarkTheme()
                                            ? AppThemeData.grey400
                                            : AppThemeData.grey600,
                                    backgroundColor: controller.addressAs.value == "Work"
                                        ? AppThemeData.secondary300
                                        : themeChange.isDarkTheme()
                                            ? AppThemeData.grey800
                                            : AppThemeData.grey200,
                                    onPress: () {
                                      controller.addressAs.value = "Work";
                                    },
                                  ),
                                  CommonTile(
                                    title: "Friends and Family".tr,
                                    icon: "assets/icons/ic_user.svg",
                                    textColor: controller.addressAs.value == "Friends and Family"
                                        ? AppThemeData.primaryWhite
                                        : themeChange.isDarkTheme()
                                            ? AppThemeData.grey400
                                            : AppThemeData.grey600,
                                    iconColor: controller.addressAs.value == "Friends and Family"
                                        ? AppThemeData.primaryWhite
                                        : themeChange.isDarkTheme()
                                            ? AppThemeData.grey400
                                            : AppThemeData.grey600,
                                    backgroundColor: controller.addressAs.value == "Friends and Family"
                                        ? AppThemeData.secondary300
                                        : themeChange.isDarkTheme()
                                            ? AppThemeData.grey800
                                            : AppThemeData.grey200,
                                    onPress: () {
                                      controller.addressAs.value = "Friends and Family";
                                    },
                                  ),
                                  CommonTile(
                                    title: "Other".tr,
                                    icon: "assets/icons/ic_map_pin.svg",
                                    textColor: controller.addressAs.value == "Other"
                                        ? AppThemeData.primaryWhite
                                        : themeChange.isDarkTheme()
                                            ? AppThemeData.grey400
                                            : AppThemeData.grey600,
                                    iconColor: controller.addressAs.value == "Other"
                                        ? AppThemeData.primaryWhite
                                        : themeChange.isDarkTheme()
                                            ? AppThemeData.grey400
                                            : AppThemeData.grey600,
                                    backgroundColor: controller.addressAs.value == "Other"
                                        ? AppThemeData.secondary300
                                        : themeChange.isDarkTheme()
                                            ? AppThemeData.grey800
                                            : AppThemeData.grey200,
                                    onPress: () {
                                      controller.addressAs.value = "Other";
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // spaceH(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFieldWidget(
                                  title: "House / Flat / Floor / Building".tr,
                                  hintText: "House / Flat / Floor / Building".tr,
                                  controller: controller.locationController.value,
                                  onPress: () {},
                                ),
                                TextFieldWidget(
                                  title: "Area / Sector".tr,
                                  hintText: "Area / Sector".tr,
                                  controller: controller.addressController.value,
                                  onPress: () {
                                    if (controller.addressController.value.text.isEmpty) {
                                      controller.checkPermission(
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
                                              controller.addAddressModel.value.isDefault = false;
                                              // controller.addAddressModel.value.addressAs = "Home";
                                              controller.addAddressModel.value.name = Constant.userModel!.fullNameString();
                                            }
                                          });
                                        },
                                      );
                                    }
                                  },
                                ),
                                spaceH(height: 24),
                                RoundShapeButton(
                                    title: "Save".tr,
                                    buttonColor: AppThemeData.orange300,
                                    buttonTextColor: AppThemeData.primaryWhite,
                                    onTap: () {
                                      MyAddressController myAddressController = Get.put(MyAddressController());
                                      controller.addAddressModel.value.addressAs = controller.addressAs.value;
                                      if (controller.formKey.currentState!.validate()) {
                                        controller.addAddressModel.value.address = "${controller.locationController.value.text}, ${controller.addressController.value.text}";
                                      }
                                      if (addressId!.isEmpty) {
                                        controller.saveAddress();
                                        myAddressController.getData();
                                        Get.back();
                                      } else {
                                        controller.updateAddress(addressId!);
                                        myAddressController.getData();
                                        Get.back();
                                      }
                                    },
                                    size: Size(358.w, 58.h))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CommonTile extends StatelessWidget {
  String? title;
  String? icon;
  Color? backgroundColor;
  Color? textColor;
  Color? iconColor;
  Function() onPress;

  CommonTile({super.key, this.title, this.icon, this.backgroundColor, this.textColor, this.iconColor, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onPress,
        child: Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              SvgPicture.asset(
                icon!,
                color: iconColor,
              ),
              spaceW(width: 8),
              Text(
                title!,
                style: TextStyle(fontFamily: FontFamily.medium, fontSize: 14, color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
