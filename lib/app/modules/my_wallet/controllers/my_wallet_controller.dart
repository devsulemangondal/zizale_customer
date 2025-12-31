// ignore_for_file: unnecessary_overrides, invalid_use_of_protected_member, non_constant_identifier_names, depend_on_referenced_packages
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as maths;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/models/payment_method_model.dart';
import 'package:customer/app/models/payment_model/stripe_failed_model.dart';
import 'package:customer/app/models/transaction_log_model.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/models/wallet_transaction_model.dart';
import 'package:customer/app/modules/my_wallet/views/widgets/complete_add_money.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/payments/flutter_wave/flutter_wave.dart';
import 'package:customer/payments/marcado_pago/mercado_pago_screen.dart';
import 'package:customer/payments/pay_fast/pay_fast_screen.dart';
import 'package:customer/payments/pay_stack/pay_stack_screen.dart';
import 'package:customer/payments/pay_stack/pay_stack_url_model.dart';
import 'package:customer/payments/pay_stack/paystack_url_generator.dart';
import 'package:customer/payments/paypal/PaypalPayment.dart';
import 'package:customer/payments/xendit/xendit_model.dart';
import 'package:customer/payments/xendit/xendit_payment_screen.dart';
import 'package:customer/services/email_template_service.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mercadopago_sdk/mercadopago_sdk.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart' as razor_pay_flutter;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../payments/midtrans/midtrans_payment_screen.dart';

class MyWalletController extends GetxController {
  RxBool isLoading = true.obs;

/*
  RxList<String> defaultAmount = ['10', '50', '100', '150', '200'].obs;
*/
  RxList<String> addMoneyTagList = <String>['50', '100', '200', '500'].obs;
  TextEditingController amountController = TextEditingController();
  TextEditingController withdrawalAmountController = TextEditingController(text: "100");
  TextEditingController withdrawalNoteController = TextEditingController();
  Rx<PaymentModel> paymentModel = PaymentModel().obs;
  Rx<TransactionLogModel> transactionLogModel = TransactionLogModel().obs;
  RxString selectedPaymentMethod = "".obs;
  RxString currencyCode = "INR".obs;
  razor_pay_flutter.Razorpay _razorpay = razor_pay_flutter.Razorpay();
  Rx<UserModel> userModel = UserModel().obs;
  RxList<WalletTransactionModel> walletTransactionList = <WalletTransactionModel>[].obs;
  RxInt selectedTabIndex = 0.obs;
  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;
  RxString selectedAddAmountTags = ''.obs; // Add this line

  @override
  void onInit() {
    getPayments();
    currencyCode.value = Constant.currencyModel!.code.toString();
    super.onInit();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  Future<void> getPayments() async {
    if (FireStoreUtils.getCurrentUid() != null) {
      await getProfileData();
    }
    await FireStoreUtils().getPayment().then((value) {
      if (value != null) {
        paymentModel.value = value;
        if (paymentModel.value.strip!.isActive == true) {
          Stripe.publishableKey = paymentModel.value.strip!.clientPublishableKey.toString();
          Stripe.merchantIdentifier = 'Go4Food';
          Stripe.instance.applySettings();
        }
        if (paymentModel.value.flutterWave!.isActive == true) {
          setRef();
        }
        if (paymentModel.value.paypal!.isActive == true) {
          // initPayPal();
        }
      }
    });
    await getWalletTransactions();
    currencyCode.value = Constant.currencyModel!.code.toString();
    ShowToastDialog.closeLoader();
  }

  Future<void> getWalletTransactions() async {
    if (FireStoreUtils.getCurrentUid() != null) {
      await FireStoreUtils.getWalletTransaction().then((value) {
        walletTransactionList.value = value;
      });
    } else {
      walletTransactionList.clear();
    }

    isLoading.value = false;
  }

  Future<void> getProfileData() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()!).then((value) {
      if (value != null) {
        userModel.value = value;
      }
    });
  }

  Future<void> completeOrder(String transactionId) async {
    WalletTransactionModel transactionModel = WalletTransactionModel(
        id: Constant.getUuid(),
        amount: amountController.value.text,
        createdDate: Timestamp.now(),
        paymentType: selectedPaymentMethod.value,
        transactionId: transactionId,
        userId: FireStoreUtils.getCurrentUid(),
        isCredit: true,
        type: Constant.user,
        note: "Added to wallet");
    ShowToastDialog.showLoader("Please Wait..".tr);
    await FireStoreUtils.setWalletTransaction(transactionModel).then((value) async {
      if (value == true) {
        await FireStoreUtils.updateUserWallet(amount: amountController.value.text).then((value) async {
          if (FireStoreUtils.getCurrentUid() != null) {
            await getProfileData();
          }
          await getWalletTransactions();
          await EmailTemplateService.sendEmail(
            type: 'wallet_topup',
            toEmail: userModel.value.email.toString(),
            variables: {
              'name': "${userModel.value.firstName} ${userModel.value.lastName}",
              'amount': Constant.amountShow(amount: amountController.value.text),
              'balance': Constant.amountShow(amount: userModel.value.walletAmount.toString()),
            },
          );
        });
      }
    });
    ShowToastDialog.closeLoader();
    ShowToastDialog.showToast("Amount successfully added to your wallet.".tr);

    // HomeController homeController = Get.put(HomeController());
    // homeController.getUserData();
    // homeController.isLoading.value = false;
  }

  Future<void> setTransactionLog({
    required String transactionId,
    dynamic transactionLog,
    required bool isCredit,
  }) async {
    transactionLogModel.value.amount = amountController.text;
    transactionLogModel.value.transactionId = transactionId;
    transactionLogModel.value.id = transactionId;
    transactionLogModel.value.transactionLog = transactionLog.toString();
    transactionLogModel.value.isCredit = isCredit;
    transactionLogModel.value.createdAt = Timestamp.now();
    transactionLogModel.value.userId = FireStoreUtils.getCurrentUid();
    transactionLogModel.value.paymentType = selectedPaymentMethod.value;
    transactionLogModel.value.type = 'wallet';
    await FireStoreUtils.setTransactionLog(transactionLogModel.value);
  }

  // ::::::::::::::::::::::::::::::::::::::::::::Stripe::::::::::::::::::::::::::::::::::::::::::::::::::::
  Future<void> stripeMakePayment({required String amount}) async {
    try {
      try {
        Map<String, dynamic>? paymentIntentData = await createStripeIntent(amount: amount);
        if (paymentIntentData!.containsKey("error")) {
          Get.back();
          ShowToastDialog.showToast("An error occurred. Please contact support.".tr);
        } else {
          await Stripe.instance.initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntentData['client_secret'],
                  allowsDelayedPaymentMethods: false,
                  googlePay: PaymentSheetGooglePay(
                    merchantCountryCode: 'US',
                    testEnv: true,
                    currencyCode: currencyCode.value,
                  ),
                  style: ThemeMode.system,
                  appearance: PaymentSheetAppearance(
                    colors: PaymentSheetAppearanceColors(
                      primary: AppThemeData.orange300,
                    ),
                  ),
                  merchantDisplayName: 'Go4Food'));
          displayStripePaymentSheet(amount: amount, client_secret: paymentIntentData['client_secret']);
        }
      } catch (e, s) {
        ShowToastDialog.showToast("exception:$e \n$s");
      }
    } catch (e) {
      ShowToastDialog.showToast('Existing in stripeMakePayment: $e');
    }
  }

  Future<void> displayStripePaymentSheet({required String amount, required String client_secret}) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        ShowToastDialog.showToast("Payment processed successfully.".tr);
        await Stripe.instance.retrievePaymentIntent(client_secret).then(
          (value) {
            completeOrder(value.id);
            setTransactionLog(isCredit: true, transactionId: value.id, transactionLog: value);
          },
        );
        Get.offAll(const CompleteAddMoneyView());
      });
    } on StripeException catch (e) {
      var lo1 = jsonEncode(e);
      var lo2 = jsonDecode(lo1);
      StripePayFailedModel lom = StripePayFailedModel.fromJson(lo2);
      ShowToastDialog.showToast(lom.error.message);
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }
  }

  Future createStripeIntent({required String amount}) async {
    try {
      Map<String, dynamic> body = {
        'amount': ((double.parse(amount) * 100).round()).toString(),
        'currency': currencyCode.value,
        'payment_method_types[]': 'card',
        "description": "Strip Payment",
        "shipping[name]": userModel.value.firstName,
        "shipping[address][line1]": "510 Townsend St",
        "shipping[address][postal_code]": "98140",
        "shipping[address][city]": "San Francisco",
        "shipping[address][state]": "CA",
        "shipping[address][country]": "US",
      };
      var stripeSecret = paymentModel.value.strip!.stripeSecret;
      var response = await http.post(Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body, headers: {'Authorization': 'Bearer $stripeSecret', 'Content-Type': 'application/x-www-form-urlencoded'});

      return jsonDecode(response.body);
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }
  }

  // ::::::::::::::::::::::::::::::::::::::::::::PayPal::::::::::::::::::::::::::::::::::::::::::::::::::::
  Future<void> payPalPayment({required String amount}) async {
    ShowToastDialog.closeLoader();
    await Get.to(() => PaypalPayment(
          onFinish: (result) {
            if (result != null) {
              Get.back();
              ShowToastDialog.showToast("Payment successful.".tr);

              completeOrder(result['orderId']);
              setTransactionLog(isCredit: true, transactionId: result['orderId'], transactionLog: result);
            } else {
              ShowToastDialog.showToast("Payment was canceled or failed.".tr);
            }
          },
          price: amount,
          currencyCode: currencyCode.value,
          title: "Add Money".tr,
          description: "Add Balance in Wallet",
        ));
  }

  // ::::::::::::::::::::::::::::::::::::::::::::RazorPay::::::::::::::::::::::::::::::::::::::::::::::::::::

  Future<void> razorpayMakePayment({required String amount}) async {
    try {
      var options = {
        'key': paymentModel.value.razorpay!.razorpayKey,
        "razorPaySecret": paymentModel.value.razorpay!.razorpaySecret,
        'amount': double.parse(amount) * 100,
        "currency": currencyCode.value,
        'name': userModel.value.firstName,
        "isSandBoxEnabled": paymentModel.value.razorpay!.isSandbox,
        'external': {
          'wallets': ['paytm']
        },
        'send_sms_hash': true,
        'prefill': {'contact': userModel.value.phoneNumber, 'email': userModel.value.email},
      };

      _razorpay.open(options);
      _razorpay.on(razor_pay_flutter.Razorpay.EVENT_PAYMENT_SUCCESS, (response) {
        _handlePaymentSuccess(response);
      });
      _razorpay.on(razor_pay_flutter.Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(razor_pay_flutter.Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    } catch (e) {
      ShowToastDialog.showToast("Something went wrong while initiating payment. Please try again.".tr);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Payment success logic
    ShowToastDialog.showToast("Payment processed successfully.".tr);
    completeOrder(response.paymentId ?? DateTime.now().millisecondsSinceEpoch.toString());
    setTransactionLog(
        isCredit: true,
        transactionId: response.paymentId.toString(),
        transactionLog: {response.paymentId, response.paymentId, response.data, response.orderId, response.signature});

    Get.offAll(const CompleteAddMoneyView());
    _razorpay.clear();
    _razorpay = razor_pay_flutter.Razorpay();
    ShowToastDialog.closeLoader();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Payment failure logic
    ShowToastDialog.showToast("Payment could not be completed. Please try again.".tr);
    ShowToastDialog.closeLoader();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // External wallet selection logic
    ShowToastDialog.closeLoader();
  }

  // ::::::::::::::::::::::::::::::::::::::::::::FlutterWave::::::::::::::::::::::::::::::::::::::::::::::::::::
  Future<Null> flutterWaveInitiatePayment({required BuildContext context, required String amount}) async {
    final url = Uri.parse('https://api.flutterwave.com/v3/payments');
    final headers = {
      'Authorization': 'Bearer ${paymentModel.value.flutterWave!.secretKey}',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "tx_ref": _ref,
      "amount": amount,
      "currency": currencyCode.value,
      "redirect_url": '${Constant.paymentCallbackURL}/success',
      "payment_options": "ussd, card, barter, payattitude",
      "customer": {
        "email": userModel.value.email.toString(),
        "phonenumber": userModel.value.phoneNumber,
        "name": userModel.value.firstName! + userModel.value.lastName!,
      },
      "customizations": {
        "title": "Payment for Services",
        "description": "Payment for XYZ services",
      }
    });
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      ShowToastDialog.closeLoader();
      await Get.to(FlutterWaveScreen(initialURl: data['data']['link']))!.then((value) {
        if (value != null && value is Map<String, dynamic>) {
          if (value["status"] == true) {
            ShowToastDialog.showToast("Payment successful.".tr);
            completeOrder(value['transaction_id'] ?? '');
            setTransactionLog(isCredit: true, transactionId: value['transaction_id'], transactionLog: value);
          } else {
            ShowToastDialog.showToast("Payment was unsuccessful.".tr);
          }
        } else {
          ShowToastDialog.showToast("Payment was unsuccessful.".tr);
        }
      });
    } else {
      if (response.statusCode == 400) {
        ShowToastDialog.closeLoader();
        Get.back();
      }

      return null;
    }
  }

  String? _ref;

  void setRef() {
    maths.Random numRef = maths.Random();
    int year = DateTime.now().year;
    int refNumber = numRef.nextInt(20000);
    if (Platform.isAndroid) {
      _ref = "AndroidRef$year$refNumber";
      _ref = "IOSRef$year$refNumber";
    }
  }

  // ::::::::::::::::::::::::::::::::::::::::::::PayStack::::::::::::::::::::::::::::::::::::::::::::::::::::

  Future<void> payStackPayment(String totalAmount) async {
    await PayStackURLGen.payStackURLGen(
            amount: (double.parse(totalAmount) * 100).toString(), currency: "NGN", secretKey: paymentModel.value.payStack!.payStackSecret.toString(), userModel: userModel.value)
        .then((value) async {
      if (value != null) {
        PayStackUrlModel payStackModel = value;
        Get.to(PayStackScreen(
          secretKey: paymentModel.value.payStack!.payStackSecret.toString(),
          callBackUrl: Constant.paymentCallbackURL.toString(),
          initialURl: payStackModel.data.authorizationUrl,
          amount: totalAmount,
          reference: payStackModel.data.reference,
        ))!
            .then((value) {
          if (value) {
            ShowToastDialog.showToast("Payment successful.".tr);
            completeOrder(DateTime.now().millisecondsSinceEpoch.toString());
            Get.offAll(const CompleteAddMoneyView());
          } else {
            ShowToastDialog.showToast("Payment was unsuccessful.".tr);
          }
        });
      } else {
        ShowToastDialog.showToast("An error occurred. Please contact support.".tr);
      }
    });
  }

  // ::::::::::::::::::::::::::::::::::::::::::::Mercado Pago::::::::::::::::::::::::::::::::::::::::::::::::::::

  void mercadoPagoMakePayment({required BuildContext context, required String amount}) {
    makePreference(amount).then((result) async {
      try {
        if (result.isNotEmpty) {
          if (result['status'] == 200) {
            Get.to(MercadoPagoScreen(initialURl: result['response']['init_point']))!.then((value) {
              if (value) {
                ShowToastDialog.showToast("Payment successful.".tr);
                completeOrder(value['transaction_id'] ?? '');
                setTransactionLog(isCredit: true, transactionId: value['transaction_id'], transactionLog: value);
                Get.offAll(const CompleteAddMoneyView());
              } else {
                ShowToastDialog.showToast("Payment could not be completed.".tr);
              }
            });
          } else {
            ShowToastDialog.showToast("Transaction error occurred.".tr);
          }
        } else {
          ShowToastDialog.showToast("Transaction error occurred.".tr);
        }
      } catch (e) {
        if (kDebugMode) {}
      }
    });
  }

  Future<Map<String, dynamic>> makePreference(String amount) async {
    final mp = MP.fromAccessToken(paymentModel.value.mercadoPago!.mercadoPagoAccessToken);

    var pref = {
      "items": [
        {
          "title": "Wallet TopUp",
          "quantity": 1,
          // "currency_id": "NGN", // Add currency
          "currency_id": currencyCode.value, // Add currency
          "unit_price": double.parse(amount)
        }
      ],
      "payer": {
        "email": "customer@example.com" // Add payer email
      },
      "auto_return": "all",
      "back_urls": {"failure": "${Constant.paymentCallbackURL}/failure", "pending": "${Constant.paymentCallbackURL}/pending", "success": "${Constant.paymentCallbackURL}/success"}
    };

    // var pref = {
    //   "items": [
    //     {"title": "Wallet TopUp", "quantity": 1, "unit_price": double.parse(amount)}
    //   ],
    //   "auto_return": "all",
    //   "back_urls": {"failure": "${Constant.paymentCallbackURL}/failure", "pending": "${Constant.paymentCallbackURL}/pending", "success": "${Constant.paymentCallbackURL}/success"},
    // };

    var result = await mp.createPreference(pref);

    return result;
  }

  // ::::::::::::::::::::::::::::::::::::::::::::Pay Fast::::::::::::::::::::::::::::::::::::::::::::::::::::

  void payFastPayment({required BuildContext context, required String amount}) {
    PayStackURLGen.getPayHTML(payFastSettingData: paymentModel.value.payFast!, amount: amount.toString(), userModel: userModel.value).then((String? value) async {
      bool isDone = await Get.to(PayFastScreen(htmlData: value!, payFastSettingData: paymentModel.value.payFast!));
      if (isDone) {
        Get.back();
        ShowToastDialog.showToast("Payment processed successfully.".tr);
        completeOrder(DateTime.now().millisecondsSinceEpoch.toString());
        Get.offAll(const CompleteAddMoneyView());
      } else {
        Get.back();
        ShowToastDialog.showToast("Payment could not be completed.".tr);
      }
    });
  }

  // :::::::::::::::::::::::::::::::::::::::::::: Xendit ::::::::::::::::::::::::::::::::::::::::::::::::::::
  Future<void> xenditPayment({required BuildContext context, required String amount}) async {
    await createXenditInvoice(amount: double.parse(amount)).then((value) {
      if (value != null) {
        Get.to(
          () => XenditPaymentScreen(
            apiKey: Constant.paymentModel!.xendit!.xenditSecretKey.toString(),
            transId: value.id,
            invoiceUrl: value.invoiceUrl,
          ),
        )!
            .then((value) {
          if (value == true) {
            Get.back();
            ShowToastDialog.showToast("Payment processed successfully.".tr);
            completeOrder(DateTime.now().millisecondsSinceEpoch.toString());
            Get.offAll(const CompleteAddMoneyView());
          } else {
            log("====>Payment Faild");
          }
        });
      }
    });
  }

  Future<XenditModel?> createXenditInvoice({required num amount}) async {
    const url = 'https://api.xendit.co/v2/invoices';

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': generateBasicAuthHeader(Constant.paymentModel!.xendit!.xenditSecretKey.toString()),
    };

    final body = jsonEncode({
      'external_id': const Uuid().v1(),
      'amount': amount,
      'payer_email': userModel.value.email.toString(),
      'description': 'Wallet Topup',
      'currency': 'IDR',
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      log(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return XenditModel.fromJson(jsonDecode(response.body));
      } else {
        log("❌ Xendit Error: ${response.body}");
        return null;
      }
    } catch (e) {
      log("⚠️ Exception: $e");
      return null;
    }
  }

  String generateBasicAuthHeader(String apiKey) {
    String credentials = '$apiKey:';
    String base64Encoded = base64Encode(utf8.encode(credentials));
    return 'Basic $base64Encoded';
  }

// :::::::::::::::::::::::::::::::::::::::::::: MidTrans ::::::::::::::::::::::::::::::::::::::::::::::::::::

  Future<void> midtransPayment({required BuildContext context, required String amount}) async {
    final url = await createMidtransPaymentLink(
      orderId: 'order-${DateTime.now().millisecondsSinceEpoch}',
      amount: double.parse(amount),
      customerEmail: userModel.value.email.toString(),
    );

    if (url != null) {
      final result = await Get.to(() => MidtransPaymentScreen(paymentUrl: url));
      if (result == true) {
        Get.back();
        ShowToastDialog.showToast("Payment processed successfully.".tr);
        completeOrder(DateTime.now().millisecondsSinceEpoch.toString());
        Get.offAll(const CompleteAddMoneyView());
      } else {
        if (kDebugMode) {
          print("Payment Failed or Cancelled");
        }
      }
    }
  }

  Future<String?> createMidtransPaymentLink({required String orderId, required double amount, required String customerEmail}) async {
    final String ordersId = orderId.isNotEmpty ? orderId : const Uuid().v1();

    final Uri url = Uri.parse('https://api.sandbox.midtrans.com/v1/payment-links'); // Use production URL for live

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': generateBasicAuthHeader(Constant.paymentModel!.midtrans!.midtransSecretKey.toString()),
    };

    final Map<String, dynamic> body = {
      'transaction_details': {'order_id': ordersId, 'gross_amount': amount.toInt()},
      'item_details': [
        {'id': 'item-1', 'name': 'Sample Product', 'price': amount.toInt(), 'quantity': 1},
      ],
      'customer_details': {'first_name': 'John', 'last_name': 'Doe', 'email': customerEmail, 'phone': '081234567890'},
      'redirect_url': 'https://www.google.com?merchant_order_id=$ordersId',
      'usage_limit': 2,
    };

    final response = await http.post(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['payment_url'];
    } else {
      if (kDebugMode) {
        print('Error creating payment link: ${response.body}');
      }
      return null;
    }
  }
}
