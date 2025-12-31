// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/models/wallet_transaction_model.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/login_dialog.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/constant_widgets/top_widget.dart';
import 'package:customer/extension/date_time_extension.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../controllers/my_wallet_controller.dart';
import 'widgets/add_money_dialog_view.dart';

class MyWalletView extends StatelessWidget {
  const MyWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<MyWalletController>(
        init: MyWalletController(),
        builder: (controller) {
          return Container(
            width: Responsive.width(100, context),
            height: Responsive.height(100, context),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    stops: const [0.1, 0.3],
                    colors: themeChange.isDarkTheme() ? [const Color(0xff1A0B00), const Color(0xff1C1C22)] : [const Color(0xffFFF1E5), const Color(0xffFFFFFF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                forceMaterialTransparency: true,
                title: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/images/logo.svg",
                      color: AppThemeData.orange300,
                      width: 32,
                      height: 32,
                    ),
                    spaceW(width: 4),
                    TextCustom(
                      title: Constant.appName.value.tr,
                      fontSize: 20,
                      color: AppThemeData.orange300,
                      fontFamily: FontFamily.bold,
                    ),
                  ],
                ),
              ),
              body: Padding(
                padding: paddingEdgeInsets(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTopWidget(context, "My Wallet".tr, "Manage your personal information and settings here.".tr),
                    spaceH(height: 16),
                    Stack(children: [
                      Positioned.fill(
                        child: SvgPicture.asset(
                          "assets/images/wallet_banner.svg",
                          width: double.infinity,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextCustom(
                              title: "Total Amount".tr,
                              fontSize: 12,
                              fontFamily: FontFamily.light,
                              color: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                            ),
                            spaceH(height: 2),
                            Obx(
                              () => TextCustom(
                                title: Constant.amountShow(amount: controller.userModel.value.walletAmount ?? '0.0'),
                                color: themeChange.isDarkTheme() ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
                                fontSize: 28,
                                fontFamily: FontFamily.medium,
                              ),
                            ),
                            spaceH(height: 26),
                            RoundShapeButton(
                                title: "Add Money".tr,
                                buttonColor: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                                buttonTextColor: themeChange.isDarkTheme() ? AppThemeData.grey1000 : AppThemeData.grey50,
                                onTap: () {
                                  if (FireStoreUtils.getCurrentUid() != null) {
                                    Get.to(() => const AddMoneyDialogView());
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
                                size: Size(326.w, 50.h)),
                          ],
                        ),
                      )
                    ]),
                    spaceH(height: 32),
                    TextCustom(
                      title: "Transaction History".tr,
                      fontSize: 16,
                      fontFamily: FontFamily.medium,
                      color: themeChange.isDarkTheme() ? AppThemeData.grey50 : AppThemeData.grey1000,
                    ),
                    controller.isLoading.value
                        ? Constant.loader()
                        : controller.walletTransactionList.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 30),
                                child: Constant.showEmptyView(context, message: "No Transaction History".tr),
                              )
                            : Expanded(
                                child: SingleChildScrollView(
                                  child: ListView.builder(
                                    itemCount: controller.walletTransactionList.length,
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      WalletTransactionModel walletTransactionModel = controller.walletTransactionList[index];
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 44.w,
                                            height: 44.h,
                                            margin: const EdgeInsets.only(right: 16),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: (walletTransactionModel.isCredit ?? false)
                                                    ? themeChange.isDarkTheme()
                                                        ? AppThemeData.success600
                                                        : AppThemeData.success50
                                                    : themeChange.isDarkTheme()
                                                        ? AppThemeData.danger600
                                                        : AppThemeData.danger50),
                                            child: Center(
                                                child: (walletTransactionModel.isCredit ?? false)
                                                    ? SvgPicture.asset(
                                                        "assets/icons/ic_arrow_down.svg",
                                                        color: AppThemeData.success300,
                                                      )
                                                    : SvgPicture.asset(
                                                        "assets/icons/ic_arrow_up.svg",
                                                        color: AppThemeData.danger300,
                                                      )),
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                    width: 1,
                                                    color: themeChange.isDarkTheme() ? AppThemeData.grey800 : AppThemeData.grey100,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          walletTransactionModel.note ?? '',
                                                          style: TextStyle(
                                                            fontFamily: FontFamily.medium,
                                                            color: themeChange.isDarkTheme() ? AppThemeData.grey100 : AppThemeData.grey900,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              (walletTransactionModel.createdDate ?? Timestamp.now()).toDate().dateMonthYear(),
                                                              style: TextStyle(
                                                                fontFamily: FontFamily.regular,
                                                                color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey500,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w400,
                                                              ),
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Container(
                                                              height: 16,
                                                              decoration: ShapeDecoration(
                                                                shape: RoundedRectangleBorder(
                                                                  side: BorderSide(
                                                                    width: 1,
                                                                    strokeAlign: BorderSide.strokeAlignCenter,
                                                                    color: themeChange.isDarkTheme() ? AppThemeData.grey800 : AppThemeData.grey100,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(width: 6),
                                                            Text(
                                                              (walletTransactionModel.createdDate ?? Timestamp.now()).toDate().time(),
                                                              style: TextStyle(
                                                                fontFamily: FontFamily.regular,
                                                                color: themeChange.isDarkTheme() ? AppThemeData.grey400 : AppThemeData.grey500,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w400,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  spaceW(width: 12),
                                                  Text(
                                                    Constant.amountShow(amount: walletTransactionModel.amount ?? ''),
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                      fontFamily: FontFamily.medium,
                                                      color: (walletTransactionModel.isCredit ?? false) ? AppThemeData.success300 : AppThemeData.danger300,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
