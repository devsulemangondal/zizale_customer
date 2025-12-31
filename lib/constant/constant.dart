// ignore_for_file: non_constant_identifier_names, deprecated_member_use, depend_on_referenced_packages, strict_top_level_inference

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/models/add_address_model.dart';
import 'package:customer/app/models/admin_commission.dart';
import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/models/currency_model.dart';
import 'package:customer/app/models/driver_delivery_charge_model.dart';
import 'package:customer/app/models/language_model.dart';
import 'package:customer/app/models/location_lat_lng.dart';
import 'package:customer/app/models/payment_method_model.dart';
import 'package:customer/app/models/platform_fee_setting_model.dart';
import 'package:customer/app/models/product_model.dart';
import 'package:customer/app/models/tax_model.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/models/vendor_model.dart';
import 'package:customer/app/models/zone_model.dart';
import 'package:customer/app/modules/home/controllers/home_controller.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class Constant {
  static UserModel? userModel;
  static VendorModel? vendorModel;
  static CurrencyModel? currencyModel;
  static PaymentModel? paymentModel;
  static PlatFormFeeSettingModel? platFormFeeSetting;
  static AdminCommission? adminCommissionDriver;
  static AdminCommission? adminCommissionVendor;

  static String googleLoginType = 'google';
  static String phoneLoginType = 'phone';
  static String appleLoginType = 'apple';
  static String emailLoginType = 'email';
  static String restaurant = 'restaurant';
  static String owner = 'owner';
  static String user = 'user';
  static String driver = 'driver';
  static RxString appName = "".obs;
  static String? appColor;
  static String? countryCode;
  static String senderId = "";
  static String jsonFileURL = "";
  static String? referralAmount = "0.0";
  static String minimumAmountToWithdrawal = "0";
  static String minimumAmountToDeposit = "100";
  static String radius = "0";
  static String restaurantRadius = "5000";
  static String restaurantDistanceType = "0";
  static String googleMapKey = "";
  static String notificationServerKey = "";
  static String termsAndConditions = "";
  static String privacyPolicy = "";
  static String aboutApp = "";
  static String supportEmail = "";
  static String phoneNumber = "";
  static int driverKmCharges = 0;
  static bool extraCharge_GST = false;
  static List<TaxModel>? taxList;
  static DriverDeliveryChargeModel? driverDeliveryChargeModel;

  static List<dynamic> cancellationReason = [];

  static const userPlaceHolder = "assets/images/user_place_holder.png";
  static const placeLogo = "assets/images/place_holder.png";
  static String paymentCallbackURL = 'https://elaynetech.com/callback';

  static AddAddressModel? currentLocation;
  static String? country;

  static ZoneModel? selectedZone;
  static bool isZoneAvailable = false;

  static String fullNameString(String? firstName, String? lastName) {
    try {
      return '$firstName $lastName';
    } catch (e, stack) {
      developer.log(
        'Error in fullNameString: ',
        error: e,
        stackTrace: stack,
      );
      return '';
    }
  }

  static String getUuid() {
    try {
      return const Uuid().v4();
    } catch (e, stack) {
      developer.log(
        'Error generating UUID: ',
        error: e,
        stackTrace: stack,
      );
      return '';
    }
  }

  static Widget loader() {
    try {
      return Center(
        child: CircularProgressIndicator(color: AppThemeData.orange300),
      );
    } catch (e, stack) {
      developer.log(
        'Error in loader widget: ',
        error: e,
        stackTrace: stack,
      );
      return const SizedBox();
    }
  }

  static double calculateReview(double reviewSum, double reviewCount) {
    try {
      if (reviewCount == 0) {
        return 0;
      }
      double averageRating = reviewSum / reviewCount;
      return (averageRating / 5) * 5;
    } catch (e, stack) {
      developer.log(
        'Error calculating review: ',
        error: e,
        stackTrace: stack,
      );
      return 0.0;
    }
  }

  static String getReferralCode(String firstTwoChar) {
    var rng = math.Random();
    return firstTwoChar + (rng.nextInt(9000) + 1000).toString();
  }

  static double safeParse(String? value, {double fallback = 0.0}) {
    try {
      if (value == null || value.isEmpty) return fallback;
      return double.tryParse(value) ?? fallback;
    } catch (e, stack) {
      developer.log(
        'Error parsing double value: ',
        error: e,
        stackTrace: stack,
      );
      return fallback;
    }
  }

  static String maskMobileNumber({String? mobileNumber, String? countryCode}) {
    try {
      if (mobileNumber == null ||
          countryCode == null ||
          mobileNumber.length < 4) {
        return "";
      }
      String firstTwoDigits = mobileNumber.substring(0, 2);
      String lastTwoDigits = mobileNumber.substring(mobileNumber.length - 2);
      String maskedNumber =
          firstTwoDigits + 'x' * (mobileNumber.length - 4) + lastTwoDigits;

      return "$countryCode $maskedNumber";
    } catch (e, stack) {
      developer.log(
        'Error masking mobile number: ',
        error: e,
        stackTrace: stack,
      );
      return "";
    }
  }

  static String maskEmail({String? email}) {
    try {
      if (email == null || !email.contains('@')) {
        throw ArgumentError("Invalid email address".tr);
      }
      List<String> parts = email.split('@');
      if (parts.length != 2) {
        throw ArgumentError("Invalid email address".tr);
      }
      String username = parts[0];
      String domain = parts[1];
      String maskedUsername =
          username.substring(0, 2) + 'x' * (username.length - 2);
      return '$maskedUsername@$domain';
    } catch (e, stack) {
      developer.log(
        'Error masking email: ',
        error: e,
        stackTrace: stack,
      );
      return email ?? '';
    }
  }

  static LanguageModel getLanguage() {
    try {
      final String user = Preferences.getString(Preferences.languageCodeKey);
      Map<String, dynamic> userMap = jsonDecode(user);
      return LanguageModel.fromJson(userMap);
    } catch (e) {
      developer.log(
        'Error getting language: ',
        error: e,
      );
      return LanguageModel(
          id: "LzSABjMohyW3MA0CaxVH",
          code: "en",
          isRtl: false,
          name: "English");
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    try {
      ByteData data = await rootBundle.load(path);
      ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
          targetWidth: width);
      ui.FrameInfo fi = await codec.getNextFrame();
      return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
          .buffer
          .asUint8List();
    } catch (e) {
      developer.log(
        'Error loading asset image: ',
        error: e,
      );
      return Uint8List(0);
    }
  }

  static double calculateAdminCommission(
      {String? amount, AdminCommission? adminCommission}) {
    double taxAmount = 0.0;
    try {
      if (adminCommission != null && adminCommission.active == true) {
        if (adminCommission.isFix == true) {
          taxAmount = double.parse(adminCommission.value.toString());
        } else {
          taxAmount = (double.parse(amount.toString()) *
                  double.parse(adminCommission.value!.toString())) /
              100;
        }
      }
    } catch (e) {
      developer.log(
        'Error calculating admin commission: ',
        error: e,
      );
    }
    return taxAmount;
  }

  static String? validateEmail(String? value) {
    try {
      String pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regExp = RegExp(pattern);
      if (value == null || value.isEmpty) {
        return "Email is Required";
      } else if (!regExp.hasMatch(value)) {
        return "Invalid Email";
      }
    } catch (e) {
      developer.log(
        'Error validating email: ',
        error: e,
      );
      return "Invalid Email";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    try {
      if (value == null || value.isEmpty || value.length < 6) {
        return "Minimum password length should be 6";
      }
    } catch (e) {
      developer.log(
        'Error validating password: ',
        error: e,
      );
      return "Invalid Password";
    }
    return null;
  }

  static Widget showEmptyView(BuildContext context, {required String message}) {
    try {
      final themeChange = Provider.of<DarkThemeProvider>(context);
      return Center(
        child: TextCustom(
          title: message.tr,
          fontFamily: FontFamily.medium,
          fontSize: 16,
          color: themeChange.isDarkTheme()
              ? AppThemeData.grey200
              : AppThemeData.grey800,
        ),
      );
    } catch (e) {
      developer.log(
        'Error showing empty view: ',
        error: e,
      );
      return Center(child: Text("Something went wrong".tr));
    }
  }

  static Future<String> uploadImageToFireStorage(
      File image, String filePath, String fileName) async {
    try {
      Reference upload =
          FirebaseStorage.instance.ref().child('$filePath/$fileName');
      UploadTask uploadTask = upload.putFile(image);
      var downloadUrl =
          await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
      return downloadUrl.toString();
    } catch (e) {
      developer.log(
        'Error uploading image to Firestore: ',
        error: e,
      );
      rethrow;
    }
  }

  static Future<List<String>> uploadProductImage(List<String> images) async {
    try {
      var imageUrls = await Future.wait(
        images.map((image) => uploadImageToFireStorage(
              File(image),
              "productImages/${FireStoreUtils.getCurrentUid()}",
              File(image).path.split("/").last,
            )),
      );
      return imageUrls;
    } catch (e) {
      developer.log(
        'Error uploading product images: ',
        error: e,
      );
      return [];
    }
  }

  static Future<String> uploadRestaurantImage(
      String image, String restaurantId) async {
    try {
      var imageUrl = await uploadImageToFireStorage(
        File(image),
        "restaurantImages/$restaurantId",
        File(image).path.split("/").last,
      );
      return imageUrl;
    } catch (e) {
      developer.log(
        'Error uploading restaurant image: ',
        error: e,
      );
      rethrow;
    }
  }

  static bool hasValidUrl(String value) {
    try {
      String pattern =
          r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
      RegExp regExp = RegExp(pattern);
      if (value.isEmpty) {
        return false;
      } else if (!regExp.hasMatch(value)) {
        return false;
      }
      return true;
    } catch (e) {
      developer.log(
        'Error validating URL: ',
        error: e,
      );
      return false;
    }
  }

  Future<void> commonLaunchUrl(String url,
      {LaunchMode launchMode = LaunchMode.inAppWebView}) async {
    try {
      await launchUrl(Uri.parse(url), mode: launchMode);
    } catch (e) {
      developer.log(
        'Error launching URL: ',
        error: e,
      );
      ShowToastDialog.showToast('Invalid URL: $url');
    }
  }

  void launchCall(String? url) {
    try {
      if (url.validate().isNotEmpty) {
        if (isIOS) {
          commonLaunchUrl('tel://${url!}',
              launchMode: LaunchMode.externalApplication);
        } else {
          commonLaunchUrl('tel:${url!}',
              launchMode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      developer.log(
        'Error initiating call: ',
        error: e,
      );
      ShowToastDialog.showToast("Failed to initiate call.".tr);
    }
  }

  static Future<DateTime?> selectDate(BuildContext context) async {
    try {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppThemeData.orange300,
                onPrimary: AppThemeData.grey500,
                onSurface: AppThemeData.grey500,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppThemeData.grey500,
                ),
              ),
            ),
            child: child!,
          );
        },
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2101),
      );
      return pickedDate;
    } catch (e) {
      developer.log(
        'Error selecting date: ',
        error: e,
      );
      ShowToastDialog.showToast("Failed to open date picker.".tr);
      return null;
    }
  }

  static Future<TimeOfDay?> selectTime(BuildContext context) async {
    try {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialEntryMode: TimePickerEntryMode.dial,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: Theme(
              data: Theme.of(context).copyWith(
                timePickerTheme: TimePickerThemeData(
                  dayPeriodColor: WidgetStateColor.resolveWith((states) =>
                      states.contains(WidgetState.selected)
                          ? AppThemeData.orange300
                          : AppThemeData.orange300.withOpacity(0.4)),
                  dayPeriodShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  hourMinuteColor: WidgetStateColor.resolveWith((states) =>
                      states.contains(WidgetState.selected)
                          ? AppThemeData.orange300
                          : AppThemeData.orange300.withOpacity(0.4)),
                ),
                colorScheme: ColorScheme.light(
                  primary: AppThemeData.orange300,
                  onPrimary: AppThemeData.grey500,
                  onSurface: AppThemeData.grey500,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: AppThemeData.grey500,
                  ),
                ),
              ),
              child: child!,
            ),
          );
        },
      );
      return pickedTime;
    } catch (e) {
      developer.log(
        'Error selecting time: ',
        error: e,
      );
      return null;
    }
  }

  static String amountShow({required String? amount}) {
    try {
      if (Constant.currencyModel!.symbolAtRight == true) {
        return "${double.parse(amount.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)} ${Constant.currencyModel!.symbol.toString()}";
      } else {
        return "${Constant.currencyModel!.symbol.toString()}${double.parse(amount.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)}";
      }
    } catch (e) {
      developer.log(
        'Error formatting amount: ',
        error: e,
      );
      return "${Constant.currencyModel!.symbol.toString()}0.00";
    }
  }

  static double amountBeforeTax(OrderModel bookingModel) {
    try {
      return (double.parse(bookingModel.subTotal ?? '0.0') -
          double.parse((bookingModel.discount ?? '0.0').toString()));
    } catch (e) {
      developer.log(
        'Error calculating amount before tax: ',
        error: e,
      );
      return 0.0;
    }
  }

  static double calculateTax({String? amount, TaxModel? taxModel}) {
    double taxAmount = 0.0;
    try {
      if (taxModel != null && taxModel.active == true) {
        if (taxModel.isFix == true) {
          taxAmount = double.parse(taxModel.value.toString());
        } else {
          taxAmount = (double.parse(amount.toString()) *
                  double.parse(taxModel.value!.toString())) /
              100;
        }
      }
    } catch (e) {
      developer.log(
        'Error calculating tax: ',
        error: e,
      );
      taxAmount = 0.0;
    }
    return taxAmount;
  }

  static double calculateFinalAmount(OrderModel bookingModel) {
    try {
      double deliveryCharge =
          double.parse(bookingModel.deliveryCharge ?? '0.0');
      double platformFee =
          double.tryParse(bookingModel.platFormFee ?? '0.0') ?? 0.0;
      double deliveryTip = double.parse(bookingModel.deliveryTip ?? '0.0');
      double packagingFee = double.parse(bookingModel.packagingFee ?? '0.0');

      final double subTotal =
          double.tryParse(bookingModel.subTotal ?? '0') ?? 0.0;
      final double discount =
          double.tryParse(bookingModel.discount?.toString() ?? '0') ?? 0.0;

      double taxAmount = 0.0;
      for (var element in (bookingModel.taxList ?? [])) {
        taxAmount += Constant.calculateTax(
          amount: (subTotal - discount).toString(),
          taxModel: element,
        );
      }

      double deliveryTaxAmount = 0.0;
      if (bookingModel.deliveryCharge != null &&
          bookingModel.deliveryCharge != "0" &&
          bookingModel.deliveryCharge != "0.0") {
        for (var element in (bookingModel.deliveryTaxList ?? [])) {
          deliveryTaxAmount += Constant.calculateTax(
            amount: deliveryCharge.toString(),
            taxModel: element,
          );
        }
      }

      double packagingTaxAmount = 0.0;
      if (bookingModel.packagingFee != null &&
          bookingModel.packagingFee != "0" &&
          bookingModel.packagingFee != "0.0") {
        for (var element in (bookingModel.packagingTaxList ?? [])) {
          packagingTaxAmount += Constant.calculateTax(
            amount: packagingFee.toString(),
            taxModel: element,
          );
        }
      }

      double finalAmount = (subTotal - discount) +
          taxAmount +
          deliveryCharge +
          deliveryTaxAmount +
          packagingFee +
          packagingTaxAmount +
          platformFee +
          deliveryTip;

      return double.parse(
        finalAmount.toStringAsFixed(Constant.currencyModel!.decimalDigits!),
      );
    } catch (e) {
      developer.log(
        'Error calculating final amount: ',
        error: e,
      );
      return 0.0;
    }
  }

  static double getDiscountedPrice(ProductModel productModel) {
    try {
      RxString discountedPrice = "0.0".obs;
      if (productModel.discountType == "Fixed") {
        discountedPrice.value = (double.parse(productModel.price.toString()) -
                double.parse(productModel.discount.toString()))
            .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
      } else {
        discountedPrice.value = (double.parse(productModel.price.toString()) -
                (double.parse(productModel.discount.toString()) *
                    double.parse(productModel.price.toString()) /
                    100))
            .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
      }
      return double.parse(discountedPrice.value);
    } catch (e) {
      developer.log(
        'Error calculating discounted price: ',
        error: e,
      );
      return 0.0;
    }
  }

  static String showId(String id) {
    try {
      return '#${id.substring(0, 5)}';
    } catch (e) {
      developer.log(
        'Error formatting ID: ',
        error: e,
      );
      return "#00000";
    }
  }

  static Padding showFoodType({required String name}) {
    try {
      final themeChange = Provider.of<DarkThemeProvider>(Get.context!);
      return name == "Both"
          ? Padding(
              padding: paddingEdgeInsets(horizontal: 0, vertical: 8),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: themeChange.isDarkTheme()
                          ? AppThemeData.grey900
                          : AppThemeData.grey50,
                    ),
                    height: 16.h,
                    width: 16.w,
                    child: Center(
                      child: SvgPicture.asset(
                        "assets/icons/ic_food_type.svg",
                        color: themeChange.isDarkTheme()
                            ? AppThemeData.success200
                            : AppThemeData.success400,
                      ),
                    ),
                  ),
                  spaceW(width: 4),
                  TextCustom(
                    title: "Veg.".tr,
                    fontSize: 16,
                    fontFamily: FontFamily.medium,
                    color: themeChange.isDarkTheme()
                        ? AppThemeData.success200
                        : AppThemeData.success400,
                  ),
                  spaceW(width: 4),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: themeChange.isDarkTheme()
                          ? AppThemeData.grey900
                          : AppThemeData.grey50,
                    ),
                    height: 16.h,
                    width: 16.w,
                    child: Center(
                      child: SvgPicture.asset(
                        "assets/icons/ic_food_type.svg",
                        color: AppThemeData.danger300,
                      ),
                    ),
                  ),
                  spaceW(width: 4),
                  TextCustom(
                    title: "Non veg".tr,
                    fontSize: 16,
                    fontFamily: FontFamily.medium,
                    color: AppThemeData.danger300,
                  ),
                ],
              ),
            )
          : Padding(
              padding: paddingEdgeInsets(horizontal: 0, vertical: 8),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: themeChange.isDarkTheme()
                          ? AppThemeData.grey900
                          : AppThemeData.grey50,
                    ),
                    height: 16.h,
                    width: 16.w,
                    child: Center(
                      child: SvgPicture.asset(
                        "assets/icons/ic_food_type.svg",
                        color: name == "Veg"
                            ? (themeChange.isDarkTheme()
                                ? AppThemeData.success200
                                : AppThemeData.success400)
                            : AppThemeData.danger300,
                      ),
                    ),
                  ),
                  spaceW(width: 4),
                  TextCustom(
                    title: name == "Veg" ? "Veg.".tr : "Non veg".tr,
                    fontSize: 16,
                    fontFamily: FontFamily.medium,
                    color: name == "Veg"
                        ? (themeChange.isDarkTheme()
                            ? AppThemeData.success200
                            : AppThemeData.success400)
                        : AppThemeData.danger300,
                  ),
                ],
              ),
            );
    } catch (e) {
      developer.log("showFoodType error: ", error: e);
      return Padding(
        padding: paddingEdgeInsets(horizontal: 0, vertical: 8),
        child: TextCustom(
          title: "Invalid food type".tr,
          fontSize: 16,
          fontFamily: FontFamily.medium,
          color: AppThemeData.danger300,
        ),
      );
    }
  }

  static String timestampToDate(Timestamp timestamp) {
    try {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('dd MMMM yyyy').format(dateTime);
    } catch (e) {
      developer.log("timestampToDate error: ", error: e);
      return '';
    }
  }

  static String timestampToTime(Timestamp timestamp) {
    try {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('HH:mm aa').format(dateTime);
    } catch (e) {
      developer.log("timestampToTime error: ", error: e);
      return '';
    }
  }

  static String timestampToTime12Hour(Timestamp timestamp) {
    try {
      DateTime dateTime = timestamp.toDate();
      return DateFormat.jm().format(dateTime);
    } catch (e) {
      developer.log("timestampToTime12Hour error: ", error: e);
      return '';
    }
  }

  static String timeOfDayToTime12Hour(BuildContext context, TimeOfDay time) {
    try {
      final localizations = MaterialLocalizations.of(context);
      return localizations.formatTimeOfDay(time, alwaysUse24HourFormat: false);
    } catch (e) {
      developer.log("timeOfDayToTime12Hour error: ", error: e);
      return '';
    }
  }

  static TimeOfDay stringToTimeOfDay(String time) {
    try {
      final period = time.split(' ')[1];
      final parts = time.split(' ')[0].split(':');
      int hour = int.parse(parts[0]);
      final int minute = int.parse(parts[1]);

      if (period.toUpperCase() == 'PM' && hour != 12) {
        hour += 12;
      } else if (period.toUpperCase() == 'AM' && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      developer.log("stringToTimeOfDay error: ", error: e);
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  static String timeAgo(Timestamp timestamp) {
    try {
      Duration diff = DateTime.now().difference(timestamp.toDate());

      if (diff.inDays > 365) {
        final years = (diff.inDays / 365).floor();
        return "$years ${years == 1 ? "year" : "years"} ago";
      }
      if (diff.inDays > 30) {
        final months = (diff.inDays / 30).floor();
        return "$months ${months == 1 ? "month" : "months"} ago";
      }
      if (diff.inDays > 7) {
        final weeks = (diff.inDays / 7).floor();
        return "$weeks ${weeks == 1 ? "week" : "weeks"} ago";
      }
      if (diff.inDays > 0) {
        return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
      }
      if (diff.inHours > 0) {
        return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
      }
      if (diff.inMinutes > 0) {
        return "${diff.inMinutes} ${diff.inMinutes == 1 ? "min" : "min"} ago";
      }
      return "just now";
    } catch (e) {
      developer.log("timeAgo error: ", error: e);
      return "just now";
    }
  }

  static bool isRestaurantOpen(VendorModel restaurantModel) {
    try {
      final DateTime now = DateTime.now();
      final String today = DateFormat('EEEE').format(now);
      final String yesterday =
          DateFormat('EEEE').format(now.subtract(const Duration(days: 1)));

      // 1. Check today's hours. This handles opening today and closing later today OR after midnight.
      if (_isOpenForDay(restaurantModel, today, now, isYesterday: false)) {
        return true;
      }

      // 2. Check yesterday's hours. This handles the critical case where the restaurant
      //    opened yesterday and is closing early today (e.g., opened Monday 9 PM, closes Tuesday 11:59 AM,
      //    and 'now' is Tuesday 10 AM).
      return _isOpenForDay(restaurantModel, yesterday, now, isYesterday: true);
    } catch (e) {
      developer.log("isRestaurantOpen error: ", error: e);
      return false;
    }
  }

  static bool _isOpenForDay(
    VendorModel restaurantModel,
    String day,
    DateTime now, {
    required bool isYesterday,
  }) {
    try {
      final hours = restaurantModel.openingHoursList?.firstWhere(
        (h) => h.day == day && h.isOpen == true,
        orElse: () => OpeningHoursModel(),
      );

      if (hours == null ||
          hours.openingHours == null ||
          hours.closingHours == null) return false;

      final String openStr = hours.openingHours!.trim();
      final String closeStr = hours.closingHours!.trim();

      if (openStr.isEmpty || closeStr.isEmpty) return false;

      // Helper function to parse both formats
      DateTime parseTime(String timeStr) {
        try {
          return DateFormat('HH:mm').parse(timeStr); // try 24-hour format
        } catch (_) {
          return DateFormat('h:mm a')
              .parse(timeStr); // fallback to 12-hour format
        }
      }

      final DateTime openTime = parseTime(openStr);
      final DateTime closeTime = parseTime(closeStr);

      final DateTime baseDate =
          isYesterday ? now.subtract(const Duration(days: 1)) : now;

      DateTime openingDateTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        openTime.hour,
        openTime.minute,
      );

      DateTime closingDateTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        closeTime.hour,
        closeTime.minute,
      );

      if (openingDateTime == closingDateTime) return false;

      // Handle overnight closing (e.g., open 20:00, close 02:00)
      if (closingDateTime.isBefore(openingDateTime)) {
        closingDateTime = closingDateTime.add(const Duration(days: 1));
      }

      return now.isAfter(openingDateTime) && now.isBefore(closingDateTime);
    } catch (e) {
      developer.log("Error checking restaurant hours for $day: ", error: e);
      return false;
    }
  }

  // static bool _isOpenForDay(VendorModel restaurantModel, String day, DateTime now, {required bool isYesterday}) {
  //   try {
  //     final hours = restaurantModel.openingHoursList?.firstWhere(
  //       (h) => h.day == day && h.isOpen == true,
  //       // Assuming OpeningHoursModel has a default constructor or factory returning an empty model
  //       orElse: () => OpeningHoursModel(),
  //     );

  //     // Check if hours were found or if times are missing
  //     if (hours == null || hours.openingHours == null || hours.closingHours == null) return false;

  //     final String openStr = hours.openingHours!.trim();
  //     final String closeStr = hours.closingHours!.trim();

  //     if (openStr.isEmpty || closeStr.isEmpty) return false;

  //     // FIX: Use 'h:mm a' to correctly parse 12-hour time (e.g., "12:00 PM", "11:59 AM")
  //     final DateTime openTime = DateFormat('h:mm a').parse(openStr);
  //     final DateTime closeTime = DateFormat('h:mm a').parse(closeStr);

  //     final DateTime baseDate = isYesterday ? now.subtract(const Duration(days: 1)) : now;

  //     // Construct the full DateTime object for the opening time on the baseDate
  //     DateTime openingDateTime = DateTime(
  //       baseDate.year,
  //       baseDate.month,
  //       baseDate.day,
  //       openTime.hour,
  //       openTime.minute,
  //     );

  //     // Construct the full DateTime object for the closing time on the baseDate
  //     DateTime closingDateTime = DateTime(
  //       baseDate.year,
  //       baseDate.month,
  //       baseDate.day,
  //       closeTime.hour,
  //       closeTime.minute,
  //     );

  //     if (openingDateTime == closingDateTime) return false;

  //     // Logic for day crossing: If the closing time is numerically before the opening time
  //     // on the same day's date (e.g., Open 12:00 PM, Close 11:59 AM), it means the close
  //     // time must be on the next day. This correctly handles "12:00 AM" and "11:59 AM" closings.
  //     if (closingDateTime.isBefore(openingDateTime)) {
  //       closingDateTime = closingDateTime.add(const Duration(days: 1));
  //     }

  //     // Check if current time ('now') falls within the determined window
  //     return now.isAfter(openingDateTime) && now.isBefore(closingDateTime);
  //   } catch (e) {
  //     developer.log("Error checking restaurant hours for $day: ", error: e);
  //     return false;
  //   }
  // }

  static String getNextOpeningTime(VendorModel restaurantModel) {
    try {
      final DateTime now = DateTime.now();
      final String today = DateFormat('EEEE').format(now);

      // 1. Check today first
      final OpeningHoursModel? todayHours =
          restaurantModel.openingHoursList?.firstWhere(
        (h) => h.day == today && h.isOpen == true,
        orElse: () => OpeningHoursModel(),
      );

      if (todayHours != null && todayHours.openingHours != null) {
        // FIX: Ensure 'h:mm a' is used to correctly parse 12-hour time
        DateTime openTime =
            DateFormat('h:mm a').parse(todayHours.openingHours!);

        DateTime openingDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          openTime.hour,
          openTime.minute,
        );

        // Check if the opening time is still in the future today
        if (openingDateTime.isAfter(now)) {
          return todayHours.openingHours!;
        }
      }

      // 2. Check next open day (loop 7 days)
      for (int i = 1; i <= 7; i++) {
        final DateTime nextDay = now.add(Duration(days: i));
        final String nextDayName = DateFormat('EEEE').format(nextDay);

        final OpeningHoursModel? nextHours =
            restaurantModel.openingHoursList?.firstWhere(
          (h) => h.day == nextDayName && h.isOpen == true,
          orElse: () => OpeningHoursModel(),
        );

        if (nextHours != null && nextHours.openingHours != null) {
          return "$nextDayName, ${nextHours.openingHours!}";
        }
      }

      return "N/A";
    } catch (e) {
      developer.log("getNextOpeningTime error: ", error: e);
      return "N/A";
    }
  }

  static String calculateDistanceInKm(double startLatitude,
      double startLongitude, double endLatitude, double endLongitude) {
    try {
      double distanceInMeters = Geolocator.distanceBetween(
          startLatitude, startLongitude, endLatitude, endLongitude);
      double distanceInKm = distanceInMeters / 1000;
      return distanceInKm.toStringAsFixed(2);
    } catch (e) {
      developer.log("calculateDistanceInKm error: ", error: e);
      return "0.00";
    }
  }

  static bool isPointInPolygon(LatLng point, List<dynamic> polygon) {
    int crossings = 0;
    for (int i = 0; i < polygon.length; i++) {
      int next = (i + 1) % polygon.length;
      if (polygon[i].latitude <= point.latitude &&
              polygon[next].latitude > point.latitude ||
          polygon[i].latitude > point.latitude &&
              polygon[next].latitude <= point.latitude) {
        double edgeLong = polygon[next].longitude - polygon[i].longitude;
        double edgeLat = polygon[next].latitude - polygon[i].latitude;
        double interpol = (point.latitude - polygon[i].latitude) / edgeLat;
        if (point.longitude < polygon[i].longitude + interpol * edgeLong) {
          crossings++;
        }
      }
    }
    return (crossings % 2 != 0);
  }

  static Future<void> checkZoneAvailability(LocationLatLng location) async {
    try {
      Constant.isZoneAvailable = false;
      Constant.selectedZone = null;

      final zones = await FireStoreUtils.getZoneList();

      for (var zone in zones) {
        if (Constant.isPointInPolygon(
          LatLng(location.latitude!, location.longitude!),
          zone.area!,
        )) {
          Constant.selectedZone = zone;
          Constant.isZoneAvailable = true;
          break;
        }
      }

      // ✅ Update UI if needed
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().update();
      }
    } catch (e, stack) {
      developer.log("Error checking zone availability: $e", stackTrace: stack);
    }
  }

  static InputDecoration DefaultInputDecoration(BuildContext context) {
    try {
      final themeChange = Provider.of<DarkThemeProvider>(context);
      return InputDecoration(
        iconColor: AppThemeData.primary500,
        isDense: true,
        filled: true,
        fillColor: themeChange.isDarkTheme()
            ? AppThemeData.grey1000
            : AppThemeData.grey50,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        disabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          borderSide: BorderSide(
            color: themeChange.isDarkTheme()
                ? AppThemeData.grey900
                : AppThemeData.grey50,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          borderSide: BorderSide(
            color: themeChange.isDarkTheme()
                ? AppThemeData.grey900
                : AppThemeData.grey50,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          borderSide: BorderSide(
            color: themeChange.isDarkTheme()
                ? AppThemeData.grey900
                : AppThemeData.grey50,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          borderSide: BorderSide(
            color: themeChange.isDarkTheme()
                ? AppThemeData.grey900
                : AppThemeData.grey50,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          borderSide: BorderSide(
            color: themeChange.isDarkTheme()
                ? AppThemeData.grey900
                : AppThemeData.grey50,
          ),
        ),
        hintText: "Select time".tr,
        hintStyle: TextStyle(
          fontSize: 16,
          color: themeChange.isDarkTheme()
              ? AppThemeData.grey50
              : AppThemeData.grey900,
          fontWeight: FontWeight.w500,
        ),
      );
    } catch (e) {
      developer.log("DefaultInputDecoration error: ", error: e);
      return const InputDecoration();
    }
  }

  static List<String> generateKeywords(String text) {
    if (text.isEmpty) return [];

    final lower = text.toLowerCase().trim();
    final List<String> keywords = [];

    final words = lower.split(' ').where((w) => w.isNotEmpty).toList();

    for (int i = 0; i < words.length; i++) {
      for (int j = i + 1; j <= words.length; j++) {
        keywords.add(words.sublist(i, j).join(' '));
      }
    }

    for (var word in words) {
      for (int i = 1; i <= word.length; i++) {
        keywords.add(word.substring(0, i));
      }
    }

    for (int i = 1; i <= lower.length; i++) {
      keywords.add(lower.substring(0, i));
    }

    return keywords.toSet().toList();
  }
}
