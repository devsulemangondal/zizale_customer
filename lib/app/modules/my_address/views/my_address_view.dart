// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:customer/app/models/add_address_model.dart';
import 'package:customer/app/models/location_lat_lng.dart';
import 'package:customer/app/modules/my_address/controllers/my_address_controller.dart';
import 'package:customer/app/modules/select_address/controllers/select_address_controller.dart';
import 'package:customer/app/modules/select_address/views/select_address_view.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/place_picker/location_picker_screen.dart';
import 'package:customer/constant/place_picker/selected_location_model.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/constant_widgets/login_dialog.dart';
import 'package:customer/constant_widgets/top_widget.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/common_ui.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../home/controllers/home_controller.dart';

class MyAddressView extends GetView {
  const MyAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    SelectAddressController addressController = Get.put(SelectAddressController());
    return GetX<MyAddressController>(
        init: MyAddressController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface.customAppBar(context, themeChange, "", backgroundColor: Colors.transparent),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Column(
                  children: [
                    buildTopWidget(context, "My Address".tr, "Add, edit, or select your delivery address for a smooth ordering experience.".tr),
                    spaceH(height: 24),
                    GestureDetector(
                      onTap: () {
                        if (FireStoreUtils.getCurrentUid() != null) {
                          addressController.addressAs.value = "Home";
                          addressController.addressController.value.clear();

                          addressController.checkPermission(
                            () async {
                              try {
                                final value = await Get.to(LocationPickerScreen());
                                if (value == null || value.latLng == null) {
                                  ShowToastDialog.showToast("Location not selected properly. Please try again.".tr);
                                  return;
                                }

                                SelectedLocationModel selectedLocation = value;
                                final latLng = selectedLocation.latLng!;

                                final placeMark = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

                                if (placeMark.isNotEmpty) {
                                  final result = placeMark.first;

                                  addressController.addressController.value.text =
                                      "${result.name}, ${result.locality}, ${result.administrativeArea}, ${result.postalCode}, ${result.country}";

                                  addressController.addAddressModel.value.locality = result.locality;
                                  addressController.addAddressModel.value.landmark = result.subLocality;
                                  addressController.addAddressModel.value.location = LocationLatLng(latitude: latLng.latitude, longitude: latLng.longitude);
                                  addressController.addAddressModel.value.address = addressController.addressController.value.text;
                                  addressController.addAddressModel.value.id = Constant.getUuid();
                                  addressController.addAddressModel.value.isDefault = false;
                                  addressController.addAddressModel.value.name = Constant.userModel!.fullNameString();

                                  Get.bottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                    const AddAddressBottomSheet(addressId: ""),
                                  );
                                } else {
                                  ShowToastDialog.showToast("Could not determine address from coordinates.".tr);
                                }
                              } catch (e) {
                                ShowToastDialog.showToast("Something went wrong while fetching address.".tr);
                              }
                            },
                          );
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: LoginDialog(),
                                );
                              });
                        }
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
                    controller.isLoading.value
                        ? Constant.loader()
                        : controller.addressList.isEmpty
                            ?  Center(
                                child: TextCustom(
                                title: "No Address Added".tr,
                              ))
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: controller.addressList.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  AddAddressModel address = controller.addressList[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                        color: themeChange.isDarkTheme() ? AppThemeData.surface1000 : AppThemeData.surface50, borderRadius: BorderRadius.circular(12)),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: themeChange.isDarkTheme() ? AppThemeData.grey700 : AppThemeData.grey300)),
                                          child: SvgPicture.asset(
                                            address.addressAs == "Home"
                                                ? "assets/icons/ic_home_outline.svg"
                                                : address.addressAs == "Work"
                                                    ? "assets/icons/ic_work.svg"
                                                    : address.addressAs == "Friends and Family"
                                                        ? "assets/icons/ic_user.svg"
                                                        : "assets/icons/ic_location.svg",
                                            color: AppThemeData.orange300,
                                          ),
                                        ),
                                        spaceW(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextCustom(
                                                title: address.addressAs.toString(),
                                                fontSize: 16,
                                                fontFamily: FontFamily.medium,
                                                color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                              ),
                                              TextCustom(
                                                title: address.address.toString(),
                                                fontSize: 14,
                                                maxLine: 3,
                                                fontFamily: FontFamily.light,
                                                textAlign: TextAlign.start,
                                                color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey600,
                                              ),
                                              // spaceH(height: 8),
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      addressController.addressAs.value = address.addressAs.toString();
                                                      addressController.addressController.value.text = address.address.toString();
                                                      Get.bottomSheet(
                                                          isScrollControlled: true,
                                                          backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                                          AddAddressBottomSheet(
                                                            addressId: address.id,
                                                          ));
                                                    },
                                                    child: SvgPicture.asset("assets/icons/ic_edit_2.svg"),
                                                  ),
                                                  spaceW(width: 12),
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (controller.addressList.length == 1) {
                                                        ShowToastDialog.showToast("Unable to delete this address.".tr);
                                                      } else {
                                                        controller.deleteAddress(index);
                                                        ShowToastDialog.showToast("Address deleted successfully.".tr);
                                                        controller.getData();
                                                      }
                                                    },
                                                    child: SvgPicture.asset("assets/icons/ic_delete.svg"),
                                                  ),
                                                  Spacer(),
                                                  address.isDefault!
                                                      ? Container(
                                                          margin: const EdgeInsets.only(right: 10, bottom: 6),
                                                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                                          decoration: BoxDecoration(color: AppThemeData.orange300, borderRadius: BorderRadius.circular(20)),
                                                          child: Text(
                                                            "Default".tr,
                                                            style: TextStyle(fontFamily: FontFamily.medium, fontSize: 14, color: AppThemeData.primaryWhite),
                                                          ),
                                                        )
                                                      : PopupMenuButton(
                                                          padding: EdgeInsets.zero,
                                                          icon: const Icon(Icons.more_vert),
                                                          offset: const Offset(-15, 35),
                                                          itemBuilder: (BuildContext context) {
                                                            return [
                                                              PopupMenuItem<String>(
                                                                height: 24,
                                                                value: "Default".tr,
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                      "Set as Default".tr,
                                                                      style: TextStyle(
                                                                        fontFamily: FontFamily.regular,
                                                                        color: themeChange.isDarkTheme() ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
                                                                        fontSize: 14,
                                                                        fontWeight: FontWeight.w400,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ];
                                                          },
                                                          onSelected: (value) async {
                                                            if (value == "Default") {
                                                              ShowToastDialog.showLoader("Please Wait..".tr);
                                                              await Constant.checkZoneAvailability(address.location!);

                                                              if (!Constant.isZoneAvailable) {
                                                                HomeController homeController = Get.put(HomeController());
                                                                await homeController.getLocation();
                                                                await homeController.getNearbyRestaurant();
                                                                homeController.update();
                                                                ShowToastDialog.closeLoader();
                                                                Get.back();
                                                                return;
                                                              }
                                                              for (var element in Constant.userModel!.addAddresses!) {
                                                                element.isDefault = false;
                                                              }
                                                              Constant
                                                                  .userModel!
                                                                  .addAddresses![Constant.userModel!.addAddresses!.indexWhere((element) => element.id == address.id.toString())]
                                                                  .isDefault = true;
                                                              await FireStoreUtils.updateUser(Constant.userModel!);
                                                              Constant.userModel = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()!);
                                                              HomeController homeController = Get.put(HomeController());
                                                              await homeController.getLocation();
                                                              await homeController.getNearbyRestaurant();
                                                              controller.getData();
                                                              homeController.update();

                                                              ShowToastDialog.closeLoader();
                                                              Get.back();
                                                            }
                                                          },
                                                        ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                })
                  ],
                ),
              ),
            ),
          );
        });
  }
}
