// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:customer/app/modules/my_wallet/controllers/my_wallet_controller.dart';
import 'package:customer/app/widget/global_widgets.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../../themes/screen_size.dart';

class AddMoneyDialogView extends StatelessWidget {
  const AddMoneyDialogView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<MyWalletController>(
        init: MyWalletController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface.customAppBar(context, themeChange, "", backgroundColor: Colors.transparent),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: RoundShapeButton(
                title: "Add Money".tr,
                buttonColor: AppThemeData.orange300,
                buttonTextColor: AppThemeData.primaryWhite,
                onTap: () async {
                  if (controller.selectedPaymentMethod.value.isNotEmpty) {
                    if (controller.amountController.value.text.isNotEmpty) {
                      if (double.parse(controller.amountController.value.text) >= Constant.minimumAmountToDeposit.toString().toDouble()) {
                        ShowToastDialog.showLoader("Please Wait..".tr);
                        if (controller.selectedPaymentMethod.value == Constant.paymentModel!.paypal!.name) {
                          await controller.payPalPayment(amount: controller.amountController.text);
                          Get.back();
                        } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.strip!.name) {
                          await controller.stripeMakePayment(amount: controller.amountController.text);
                          Get.back();
                        } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.razorpay!.name) {
                          await controller.razorpayMakePayment(amount: controller.amountController.text);
                          Get.back();
                        } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.flutterWave!.name) {
                          if (Constant.userModel!.email!.isEmpty || Constant.userModel!.email == '') {
                            ShowToastDialog.closeLoader();
                            return ShowToastDialog.showToast("Add your email address in your profile.".tr);
                          } else {
                            await controller.flutterWaveInitiatePayment(context: context, amount: controller.amountController.text);
                          }
                          Get.back();
                        } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.payStack!.name) {
                          await controller.payStackPayment(controller.amountController.text);
                          Get.back();
                        } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.mercadoPago!.name) {
                          controller.mercadoPagoMakePayment(context: context, amount: controller.amountController.text);
                          Get.back();
                        } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.payFast!.name) {
                          controller.payFastPayment(context: context, amount: controller.amountController.text);
                          Get.back();
                        } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.midtrans!.name) {
                          controller.midtransPayment(context: context, amount: controller.amountController.text);
                          Get.back();
                        } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.xendit!.name) {
                          controller.xenditPayment(context: context, amount: controller.amountController.text);
                          Get.back();
                        }
                        ShowToastDialog.closeLoader();
                      } else {
                        ShowToastDialog.showToast("${"Please enter the minimum required amount".tr} ${Constant.amountShow(amount: Constant.minimumAmountToDeposit)}");
                      }
                    } else {
                      ShowToastDialog.showToast("Enter the amount.".tr);
                    }
                  } else {
                    ShowToastDialog.showToast("Select a payment method.".tr);
                  }
                },
                size: Size(358.w, ScreenSize.height(6, context)),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTopWidget(context, "Add Money".tr, "Top up your wallet by adding funds from your bank account or card.".tr),
                    spaceH(height: 10),
                    TextFormField(
                      controller: controller.amountController,
                      cursorColor: AppThemeData.orange300,
                      validator: (value) => value != null && value.isNotEmpty ? null : "This field required".tr,
                      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                      ],
                      onChanged: (value) {
                        controller.selectedAddAmountTags.value = value;
                      },
                      decoration: InputDecoration(
                        errorStyle: const TextStyle(fontFamily: FontFamily.regular),
                        isDense: true,
                        filled: true,
                        enabled: true,
                        fillColor: themeChange.isDarkTheme() ? AppThemeData.grey900 : AppThemeData.grey50,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        prefix: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/ic_currency_dollar.svg",
                              color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: TextCustom(
                                title: "|",
                                fontSize: 16,
                                fontFamily: FontFamily.light,
                                color: themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey400,
                              ),
                            )
                          ],
                        ),
                        labelText: "Enter Amount".tr,
                        labelStyle: TextStyle(fontSize: 14, color: themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800, fontFamily: FontFamily.regular),
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
                      ),
                    ),
                    TextCustom(
                      title: "MinimumAmountTo_Deposit".trParams({"minimumAmountToDeposit": Constant.amountShow(amount: Constant.minimumAmountToDeposit)})
                      //"Min. Add money amount will be a \$ ${Constant.amountShow(amount: Constant.minimumAmountToDeposit)}"
                      ,
                      color: AppThemeData.info300,
                      fontSize: 14,
                      fontFamily: FontFamily.italic,
                    ),
                    spaceH(height: 16),
                    TextCustom(
                      title: "Recommended".tr,
                      fontSize: 16,
                      fontFamily: FontFamily.medium,
                      color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                    ),
                    spaceH(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.start,
                      alignment: WrapAlignment.start,
                      children: List.generate(
                        controller.addMoneyTagList.length,
                        (index) {
                          return GestureDetector(
                            onTap: () {
                              controller.amountController.text = controller.addMoneyTagList[index];
                              controller.selectedAddAmountTags.value = controller.addMoneyTagList[index];
                            },
                            child: Obx(
                              () => Padding(
                                padding: const EdgeInsets.only(bottom: 8, right: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: controller.selectedAddAmountTags.value == controller.addMoneyTagList[index]
                                        ? AppThemeData.secondary300
                                        : themeChange.isDarkTheme()
                                            ? AppThemeData.grey800
                                            : AppThemeData.grey200,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: TextCustom(
                                    fontSize: 14,
                                    title: '+ ${Constant.amountShow(amount: controller.addMoneyTagList[index])}',
                                    color: controller.selectedAddAmountTags.value == controller.addMoneyTagList[index]
                                        ? AppThemeData.grey50
                                        : themeChange.isDarkTheme()
                                            ? AppThemeData.grey400
                                            : AppThemeData.grey600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    spaceH(height: 28),
                    TextCustom(
                      title: "Payment Method".tr,
                      fontSize: 16,
                      fontFamily: FontFamily.medium,
                      color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                    ),
                    spaceH(height: 8),
                    ContainerCustom(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Visibility(
                            visible: controller.paymentModel.value.paypal != null && controller.paymentModel.value.paypal!.isActive == true,
                            child: Column(
                              children: [
                                Container(
                                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                                  child: RadioListTile(
                                    value: Constant.paymentModel!.paypal!.name.toString(),
                                    groupValue: controller.selectedPaymentMethod.value,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppThemeData.orange300,
                                    title: Row(
                                      children: [
                                        Container(
                                          height: 50.h,
                                          width: 50.w,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                          ),
                                          child: Image.asset(
                                            "assets/images/ig_paypal.png",
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        TextCustom(
                                          title: Constant.paymentModel!.paypal!.name ?? "",
                                          fontSize: 16,
                                          fontFamily: FontFamily.medium,
                                          color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                        ),
                                      ],
                                    ),
                                    onChanged: (value) {
                                      controller.selectedPaymentMethod.value = Constant.paymentModel!.paypal!.name.toString();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: controller.paymentModel.value.strip != null && controller.paymentModel.value.strip!.isActive == true,
                            child: Column(
                              children: [
                                Container(
                                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                                  child: RadioListTile(
                                    value: Constant.paymentModel!.strip!.name.toString(),
                                    groupValue: controller.selectedPaymentMethod.value,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppThemeData.orange300,
                                    title: Row(
                                      children: [
                                        Container(
                                          height: 50.h,
                                          width: 50.w,
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                          ),
                                          child: Image.asset(
                                            "assets/images/ig_stripe.png",
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        TextCustom(
                                          title: Constant.paymentModel!.strip!.name ?? "",
                                          fontSize: 16,
                                          fontFamily: FontFamily.medium,
                                          color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                        ),
                                      ],
                                    ),
                                    onChanged: (value) {
                                      controller.selectedPaymentMethod.value = Constant.paymentModel!.strip!.name.toString();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: controller.paymentModel.value.razorpay != null && controller.paymentModel.value.razorpay!.isActive == true,
                            child: Column(
                              children: [
                                Container(
                                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                                  child: RadioListTile(
                                    value: Constant.paymentModel!.razorpay!.name.toString(),
                                    groupValue: controller.selectedPaymentMethod.value,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppThemeData.orange300,
                                    title: Row(
                                      children: [
                                        Container(
                                          height: 50.h,
                                          width: 50.w,
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                          ),
                                          child: Image.asset(
                                            "assets/images/ig_razorpay.png",
                                            // fit: BoxFit.fill,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        TextCustom(
                                          title: Constant.paymentModel!.razorpay!.name ?? "",
                                          fontSize: 16,
                                          fontFamily: FontFamily.medium,
                                          color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                        ),
                                      ],
                                    ),
                                    onChanged: (value) {
                                      controller.selectedPaymentMethod.value = Constant.paymentModel!.razorpay!.name.toString();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: controller.paymentModel.value.flutterWave != null && controller.paymentModel.value.flutterWave!.isActive == true,
                            child: Column(
                              children: [
                                Container(
                                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                                  child: RadioListTile(
                                    value: Constant.paymentModel!.flutterWave!.name.toString(),
                                    groupValue: controller.selectedPaymentMethod.value,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppThemeData.orange300,
                                    title: Row(
                                      children: [
                                        Container(
                                          height: 50.h,
                                          width: 50.w,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                          ),
                                          child: Image.asset(
                                            "assets/images/ig_flutterwave.png",
                                            // fit: BoxFit.fill,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        TextCustom(
                                          title: Constant.paymentModel!.flutterWave!.name ?? "",
                                          fontSize: 16,
                                          fontFamily: FontFamily.medium,
                                          color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                        ),
                                      ],
                                    ),
                                    onChanged: (value) {
                                      controller.selectedPaymentMethod.value = Constant.paymentModel!.flutterWave!.name.toString();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: controller.paymentModel.value.payStack != null && controller.paymentModel.value.payStack!.isActive == true,
                            child: Column(
                              children: [
                                Container(
                                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                                  child: RadioListTile(
                                    value: Constant.paymentModel!.payStack!.name.toString(),
                                    groupValue: controller.selectedPaymentMethod.value,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppThemeData.orange300,
                                    title: Row(
                                      children: [
                                        Container(
                                          height: 50.h,
                                          width: 50.w,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                          ),
                                          child: Image.asset(
                                            "assets/images/ig_paystack.png",
                                            // fit: BoxFit.fill,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        TextCustom(
                                          title: Constant.paymentModel!.payStack!.name ?? "",
                                          fontSize: 16,
                                          fontFamily: FontFamily.medium,
                                          color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                        ),
                                      ],
                                    ),
                                    onChanged: (value) {
                                      controller.selectedPaymentMethod.value = Constant.paymentModel!.payStack!.name.toString();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: controller.paymentModel.value.mercadoPago != null && controller.paymentModel.value.mercadoPago!.isActive == true,
                            child: Column(
                              children: [
                                Container(
                                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                                  child: RadioListTile(
                                    value: Constant.paymentModel!.mercadoPago!.name.toString(),
                                    groupValue: controller.selectedPaymentMethod.value,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppThemeData.orange300,
                                    title: Row(
                                      children: [
                                        Container(
                                          height: 50.h,
                                          width: 50.w,
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                          ),
                                          child: Image.asset(
                                            "assets/images/ig_marcadopago.png",
                                            // fit: BoxFit.fill,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        TextCustom(
                                          title: Constant.paymentModel!.mercadoPago!.name ?? "",
                                          fontSize: 16,
                                          fontFamily: FontFamily.medium,
                                          color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                        ),
                                      ],
                                    ),
                                    onChanged: (value) {
                                      controller.selectedPaymentMethod.value = Constant.paymentModel!.mercadoPago!.name.toString();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: controller.paymentModel.value.payFast != null && controller.paymentModel.value.payFast!.isActive == true,
                            child: Column(
                              children: [
                                Container(
                                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                                  child: RadioListTile(
                                    value: Constant.paymentModel!.payFast!.name.toString(),
                                    groupValue: controller.selectedPaymentMethod.value,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppThemeData.orange300,
                                    title: Row(
                                      children: [
                                        Container(
                                          height: 50.h,
                                          width: 50.w,
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                          ),
                                          child: Image.asset(
                                            "assets/images/ig_payfast.png",
                                            // fit: BoxFit.fill,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        TextCustom(
                                          title: Constant.paymentModel!.payFast!.name ?? "",
                                          fontSize: 16,
                                          fontFamily: FontFamily.medium,
                                          color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                        ),
                                      ],
                                    ),
                                    onChanged: (value) {
                                      controller.selectedPaymentMethod.value = Constant.paymentModel!.payFast!.name.toString();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: controller.paymentModel.value.midtrans != null && controller.paymentModel.value.midtrans!.isActive == true,
                            child: Column(
                              children: [
                                Container(
                                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                                  child: RadioListTile(
                                    value: Constant.paymentModel!.midtrans!.name.toString(),
                                    groupValue: controller.selectedPaymentMethod.value,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppThemeData.orange300,
                                    title: Row(
                                      children: [
                                        Container(
                                          height: 50.h,
                                          width: 50.w,
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                          ),
                                          child: Image.asset(
                                            "assets/images/ig_midtrans.png",
                                            // fit: BoxFit.fill,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        TextCustom(
                                          title: Constant.paymentModel!.midtrans!.name ?? "",
                                          fontSize: 16,
                                          fontFamily: FontFamily.medium,
                                          color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                        ),
                                      ],
                                    ),
                                    onChanged: (value) {
                                      controller.selectedPaymentMethod.value = Constant.paymentModel!.midtrans!.name.toString();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: controller.paymentModel.value.xendit != null && controller.paymentModel.value.xendit!.isActive == true,
                            child: Column(
                              children: [
                                Container(
                                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                                  child: RadioListTile(
                                    value: Constant.paymentModel!.xendit!.name.toString(),
                                    groupValue: controller.selectedPaymentMethod.value,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppThemeData.orange300,
                                    title: Row(
                                      children: [
                                        Container(
                                          height: 50.h,
                                          width: 50.w,
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                          ),
                                          child: Image.asset(
                                            "assets/images/ig_xendit.png",
                                            // fit: BoxFit.fill,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        TextCustom(
                                          title: Constant.paymentModel!.xendit!.name ?? "",
                                          fontSize: 16,
                                          fontFamily: FontFamily.medium,
                                          color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                        ),
                                      ],
                                    ),
                                    onChanged: (value) {
                                      controller.selectedPaymentMethod.value = Constant.paymentModel!.xendit!.name.toString();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
