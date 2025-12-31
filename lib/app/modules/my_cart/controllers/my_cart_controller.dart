// ignore_for_file: non_constant_identifier_names, depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:developer';
import 'dart:io';
import 'dart:math' as maths;
import 'package:customer/app/models/owner_model.dart';
import 'package:customer/app/models/payment_model/stripe_failed_model.dart';
import 'package:customer/app/models/transaction_log_model.dart';
import 'package:customer/constant/order_status.dart';
import 'package:customer/constant/send_notification.dart';
import 'package:customer/payments/flutter_wave/flutter_wave.dart';
import 'package:customer/payments/marcado_pago/mercado_pago_screen.dart';
import 'package:customer/payments/pay_fast/pay_fast_screen.dart';
import 'package:customer/payments/pay_stack/pay_stack_screen.dart';
import 'package:customer/payments/pay_stack/paystack_url_generator.dart';
import 'package:customer/payments/xendit/xendit_model.dart';
import 'package:customer/services/email_template_service.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/models/cart_model.dart';
import 'package:customer/app/models/coupon_model.dart';
import 'package:customer/app/models/payment_method_model.dart';
import 'package:customer/app/models/product_model.dart';
import 'package:customer/app/models/vendor_model.dart';
import 'package:customer/app/models/tax_model.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/models/wallet_transaction_model.dart';
import 'package:customer/app/modules/my_cart/views/widget/order_placed_view.dart';
import 'package:customer/app/modules/select_address/controllers/select_address_controller.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/payments/paypal/PaypalPayment.dart';
import 'package:customer/services/database_helper.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mercadopago_sdk/mercadopago_sdk.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart' as razor_pay_flutter;
import 'package:uuid/uuid.dart';
import '../../../../payments/midtrans/midtrans_payment_screen.dart';
import '../../../../payments/xendit/xendit_payment_screen.dart';

class MyCartController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<CartModel> cartItems = <CartModel>[].obs;
  Rx<TextEditingController> deliveryInstruction = TextEditingController().obs;
  Rx<TextEditingController> cookingInstruction = TextEditingController().obs;
  final CartDatabaseHelper cartDatabaseHelper = CartDatabaseHelper();

  RxList<ProductModel> productList = <ProductModel>[].obs;
  Rx<ProductModel> productModel = ProductModel().obs;
  Rx<UserModel> userModel = UserModel().obs;
  Rx<OrderModel> orderModel = OrderModel().obs;
  Rx<PaymentModel> paymentModel = PaymentModel().obs;
  RxString selectedPaymentMethod = "".obs;
  RxString currencyCode = "INR".obs;
  Rx<TransactionLogModel> transactionLogModel = TransactionLogModel().obs;
  RxDouble couponAmount = 0.0.obs;
  RxInt deliveryFee = 0.obs;
  Rx<CouponModel> selectedCoupon = CouponModel().obs;
  RxString couponCode = "".obs;
  RxString selectedDeliveryType = 'home_delivery'.obs;

  Rx<OwnerModel> ownerModel = OwnerModel().obs;
  Rx<VendorModel> restaurantModel = VendorModel().obs;

  RxList<TaxModel> allTaxList = (Constant.taxList ?? []).obs;
  RxList<TaxModel> restaurantTaxList = <TaxModel>[].obs;
  RxList<TaxModel> packagingTaxList = <TaxModel>[].obs;
  RxList<TaxModel> deliveryTaxList = <TaxModel>[].obs;

  RxList<String> tipAmountList = <String>['20', '30', '50', 'other'].obs;
  RxString selectedTip = "".obs;
  Rx<TextEditingController> deliveryTipAmountController = TextEditingController().obs;

  razor_pay_flutter.Razorpay _razorpay = razor_pay_flutter.Razorpay();

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  Future<void> getData() async {
    isLoading.value = true;
    try {
      await getCartItems();
      await getProduct();
      await getPayments();
      await getTax();
      currencyCode.value = Constant.currencyModel?.code ?? "";
    } catch (e, stackTrace) {
      developer.log("Error in MyCartController: $e", stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getRestaurantData() async {
    try {
      if (cartItems.isEmpty) {
        return;
      }
      final restaurant = await FireStoreUtils.getRestaurant(cartItems[0].vendorId!);
      if (restaurant != null) {
        restaurantModel.value = restaurant;

        final owner = await FireStoreUtils.getOwnerProfile(restaurant.ownerId.toString());
        if (owner != null) {
          ownerModel.value = owner;
        }

        calculationOfDeliveryCharge();
      } else {
        ShowToastDialog.showToast("Restaurant not found.".tr);
      }
    } catch (e, stackTrace) {
      developer.log("Error fetching restaurant data: $e", stackTrace: stackTrace);
    }
  }

  void calculationOfDeliveryCharge() {
    try {
      SelectAddressController addressController = Get.put(SelectAddressController());
      final userLocation = addressController.selectedAddress.value.location;
      final restaurantLocation = restaurantModel.value.address?.location;

      if (userLocation == null || restaurantLocation == null) {
        throw Exception("Location data is missing.".tr);
      }

      double totalKm = double.parse(Constant.calculateDistanceInKm(
        userLocation.latitude!,
        userLocation.longitude!,
        restaurantLocation.latitude!,
        restaurantLocation.longitude!,
      ));

      if (selectedDeliveryType.value != "take_away") {
        if (totalKm <= (double.parse(Constant.driverDeliveryChargeModel!.minimumChargeWithinKm.toString()))) {
          double fareMinimumCharge = double.parse(Constant.driverDeliveryChargeModel!.fareMinimumCharge.toString());
          deliveryFee.value = (fareMinimumCharge * totalKm).round();
        } else {
          double perKmCharge = double.parse(Constant.driverDeliveryChargeModel!.farPerKm.toString());
          deliveryFee.value = (perKmCharge * totalKm).round();
        }
      } else {
        deliveryFee.value = 0;
      }
    } catch (e, stackTrace) {
      developer.log("Error calculating delivery fee: $e", stackTrace: stackTrace);
      deliveryFee.value = 0;
    }
  }

  Future<void> getCartItems() async {
    isLoading.value = true;
    try {
      cartItems.clear();
      if (FireStoreUtils.getCurrentUid() != null) {
        cartItems.value = await cartDatabaseHelper.getAllCartItems(FireStoreUtils.getCurrentUid()!);
        await getRestaurantData();
      }
    } catch (e, stackTrace) {
      developer.log("Error fetching cart items: $e", stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getProduct() async {
    try {
      if (cartItems.isNotEmpty) {
        String? restaurantId = cartItems[0].vendorId;
        var value = await FireStoreUtils.getProductRestaurantWise(restaurantId);
        productList.value = value;
      }
    } catch (e, stackTrace) {
      developer.log("Error fetching products: $e", stackTrace: stackTrace);
    }
  }

  Future<void> getTax() async {
    try {
      var value = await FireStoreUtils().getTaxList();
      Constant.taxList = value;
      allTaxList.value = value;
      restaurantTaxList.value = allTaxList.where((tax) => tax.type == 'restaurant' && tax.active == true).toList();
      packagingTaxList.value = allTaxList.where((tax) => tax.type == 'packaging' && tax.active == true).toList();
      deliveryTaxList.value = allTaxList.where((tax) => tax.type == 'delivery' && tax.active == true).toList();
      log("Fetched ${allTaxList.length} tax entries.");
    } catch (e, stackTrace) {
      developer.log("Error fetching tax data: $e", stackTrace: stackTrace);
    }
  }

  void removeItem(CartModel cartModel) async {
    isLoading.value = true;
    try {
      await cartDatabaseHelper.deleteCartItem(cartModel.id!);
      cartItems.remove(cartModel);
    } catch (e, stackTrace) {
      developer.log("Error removing item from cart: $e", stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  void updateQuantity(CartModel cartModel, int newQuantity) async {
    try {
      int index = cartItems.indexWhere((item) => item.productId == cartModel.productId);
      if (index != -1) {
        cartItems[index].quantity = newQuantity;
        cartItems[index].totalAmount = (cartItems[index].itemPrice! * cartItems[index].quantity!);
        cartItems.refresh();
      }
      await cartDatabaseHelper.updateCartItem(cartModel);
      calculateDiscount();
    } catch (e, stackTrace) {
      developer.log("Error updating quantity: $e", stackTrace: stackTrace);
    }
  }

  double calculateItemTotal() {
    double subTotal = 0.0;
    try {
      for (var item in cartItems) {
        subTotal += (item.totalAmount ?? 0.0);
      }
    } catch (e, stackTrace) {
      developer.log("Error calculating item total: $e", stackTrace: stackTrace);
    }
    return subTotal;
  }

  void calculateDiscount() {
    try {
      double subTotal = calculateItemTotal();

      if (selectedCoupon.value.code?.isNotEmpty == true) {
        double minAmount = double.tryParse(selectedCoupon.value.minAmount.toString()) ?? 0.0;

        if (subTotal < minAmount) {
          ShowToastDialog.showToast("Coupon removed: Minimum amount not added in your cart.".tr);
          selectedCoupon.value = CouponModel();
          couponAmount.value = 0.0;
          couponCode.value = "";
          update();
        } else {
          double amount = double.tryParse(selectedCoupon.value.amount.toString()) ?? 0.0;
          if (selectedCoupon.value.isFix == true) {
            couponAmount.value = amount;
          } else {
            couponAmount.value = subTotal * amount / 100;
          }
        }
      }

      calculateFinalAmount();
    } catch (e, stackTrace) {
      developer.log("Error calculating discount: $e", stackTrace: stackTrace);
    }
  }

  RxDouble subTotal = 0.0.obs;
  RxDouble restaurantTaxAmount = 0.0.obs;
  RxDouble packagingTaxAmount = 0.0.obs;
  RxDouble deliveryTaxAmount = 0.0.obs;
  RxDouble packagingFee = 0.0.obs;
  RxDouble platformFee = 0.0.obs;

  double calculateFinalAmount() {
    double finalAmount = 0.0;
    try {
      subTotal.value = 0.0;
      restaurantTaxAmount.value = 0.0;
      packagingTaxAmount.value = 0.0;
      deliveryTaxAmount.value = 0.0;
      packagingFee.value = 0.0;
      platformFee.value = 0.0;
      subTotal.value = calculateItemTotal();

      double amountAfterDiscount = subTotal.value - couponAmount.value;

      for (var taxes in restaurantTaxList) {
        restaurantTaxAmount.value += Constant.calculateTax(
          amount: amountAfterDiscount.toString(),
          taxModel: taxes,
        );
      }

      if (Constant.platFormFeeSetting!.packagingFeeActive == true) {
        if (restaurantModel.value.packagingFee!.active == true && restaurantModel.value.packagingFee!.price != null) {
          packagingFee.value = double.tryParse(restaurantModel.value.packagingFee!.price ?? "0") ?? 0.0;
          for (var taxes in packagingTaxList) {
            packagingTaxAmount.value += Constant.calculateTax(
              amount: packagingFee.value.toString(),
              taxModel: taxes,
            );
          }
        }
      }

      for (var taxes in deliveryTaxList) {
        deliveryTaxAmount.value += Constant.calculateTax(
          amount: deliveryFee.value.toString(),
          taxModel: taxes,
        );
      }

      if (Constant.platFormFeeSetting != null && Constant.platFormFeeSetting!.platformFeeActive == true) {
        platformFee.value = double.tryParse(Constant.platFormFeeSetting!.platformFee ?? "0") ?? 0.0;
      }

      double tipAmount = double.tryParse(selectedTip.value) ?? 0.0;

      finalAmount = amountAfterDiscount +
          restaurantTaxAmount.value +
          packagingTaxAmount.value +
          deliveryTaxAmount.value +
          deliveryFee.value +
          platformFee.value +
          packagingFee.value +
          tipAmount;
    } catch (e, stackTrace) {
      developer.log("Error calculating final amount: $e", stackTrace: stackTrace);
    }
    return finalAmount;
  }

  Future<void> getPayments() async {
    try {
      final value = await FireStoreUtils().getPayment();
      if (value != null) {
        paymentModel.value = value;

        if (paymentModel.value.strip?.isActive == true) {
          Stripe.publishableKey = paymentModel.value.strip!.clientPublishableKey.toString();
          Stripe.merchantIdentifier = 'Go4Food';
          Stripe.instance.applySettings();
        }

        if (paymentModel.value.paypal?.isActive == true) {}

        if (paymentModel.value.flutterWave?.isActive == true) {
          setRef();
        }
      }

      await getProfileData();
    } catch (e, stackTrace) {
      developer.log("Error fetching payment settings: $e", stackTrace: stackTrace);
    } finally {
      ShowToastDialog.closeLoader();
    }
  }

  Future<void> getProfileData() async {
    try {
      if (FireStoreUtils.getCurrentUid() != null) {
        final value = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()!);
        if (value != null) {
          userModel.value = value;
        }
      }
    } catch (e, stackTrace) {
      developer.log("Error fetching user profile: $e", stackTrace: stackTrace);
    }
  }

  Future<void> completeOrder(String transactionId, bool? isPayment) async {
    try {
      ShowToastDialog.showLoader("Please Wait..".tr);

      orderModel.value.paymentStatus = isPayment ?? false;
      orderModel.value.transactionPaymentId = transactionId;

      await FireStoreUtils.setOrder(orderModel.value).then((value) async {
        ShowToastDialog.showToast("Order placed successfully!".tr);
        ShowToastDialog.showLoader("Please Wait..".tr);

        Map<String, dynamic> playLoad = <String, dynamic>{"orderId": orderModel.value.id};
        await SendNotification.sendOneNotification(
          isPayment: orderModel.value.paymentStatus ?? false,
          token: ownerModel.value.fcmToken.toString(),
          isSaveNotification: true,
          title: 'New Order Request 🛎️'.tr,
          body: 'New Order Available #${orderModel.value.id.toString().substring(0, 4)}',
          type: 'order',
          orderId: orderModel.value.id,
          senderId: FireStoreUtils.getCurrentUid(),
          ownerId: ownerModel.value.id,
          payload: playLoad,
          isNewOrder: true,
        );

        cartDatabaseHelper.clearCart();
        ShowToastDialog.closeLoader();
        Get.offAll(() => const OrderPlacedView(), arguments: {"bookingModel": orderModel.value});
        cartDatabaseHelper.clearCart();

        await EmailTemplateService.sendEmail(type: 'order_confirmed', toEmail: userModel.value.email.toString(), variables: {
          'name': "${userModel.value.firstName} ${userModel.value.lastName}",
          "order_id": orderModel.value.id.toString(),
          'restaurant_name': restaurantModel.value.vendorName.toString(),
          "total_amount": Constant.amountShow(amount: Constant.calculateFinalAmount(orderModel.value).toString()),
          "delivery_address": orderModel.value.customerAddress!.address.toString(),
          "sub_total": Constant.amountShow(amount: orderModel.value.subTotal.toString()),
          'discount': Constant.amountShow(amount: orderModel.value.discount ?? '0'),
          'coupon_code': orderModel.value.coupon?.code ?? '—',
          'delivery_charge': Constant.amountShow(amount: orderModel.value.deliveryCharge ?? '0'),
          "delivery_type": orderModel.value.deliveryType == 'home_delivery' ? 'Home Delivery' : 'Take Away',
          "delivery_instruction": orderModel.value.deliveryInstruction ?? "-",
          "payment_type": orderModel.value.paymentType.toString(),
          'payment_status': orderModel.value.paymentStatus == true ? 'Paid' : 'Unpaid',
          "transaction_id": orderModel.value.transactionPaymentId.toString(),
          "order_date": DateFormat('dd MMM yyyy, hh:mm a').format(orderModel.value.createdAt!.toDate()),
          "order_status": OrderStatus.getOrderStatusTitle(orderModel.value.orderStatus.toString()),
          'items': orderModel.value.items!.map((item) => '''
      <tr>
        <td style="padding:8px; border-bottom:1px solid #eee;">${item.productName}</td>
        <td align="center" style="padding:8px; border-bottom:1px solid #eee;">${item.quantity}</td>
        <td align="right" style="padding:8px; border-bottom:1px solid #eee;">${Constant.amountShow(amount: item.totalAmount.toString())}</td>
      </tr>
    ''').join(''),

          // 🧾 Tax table rows
          'tax_list': (orderModel.value.taxList ?? []).map((tax) {
            double subTotal = double.tryParse(orderModel.value.subTotal.toString()) ?? 0.0;
            double taxAmount = Constant.calculateTax(
              amount: subTotal.toString(),
              taxModel: tax,
            );
            return '''
        <tr>
          <td align="right" style="padding: 8px 0; border-bottom: 1px solid #eee;">
            <b>${tax.name} : </b>
          </td>
          <td align="right" style="padding: 8px 0; border-bottom: 1px solid #eee;">
            ${Constant.amountShow(amount: taxAmount.toString())}
          </td>
        </tr>
      ''';
          }).join(''),
          "app_name": Constant.appName.value
        });
      });
    } catch (e, stackTrace) {
      ShowToastDialog.closeLoader();
      developer.log("Error completing order: $e", stackTrace: stackTrace);
    }
  }

  Future<void> setTransactionLog({
    required String transactionId,
    required String amount,
    dynamic transactionLog,
    required bool isCredit,
  }) async {
    try {
      transactionLogModel.value.amount = amount;
      transactionLogModel.value.transactionId = transactionId;
      transactionLogModel.value.id = transactionId;
      transactionLogModel.value.transactionLog = transactionLog.toString();
      transactionLogModel.value.isCredit = isCredit;
      transactionLogModel.value.createdAt = Timestamp.now();
      transactionLogModel.value.userId = FireStoreUtils.getCurrentUid();
      transactionLogModel.value.paymentType = selectedPaymentMethod.value;
      transactionLogModel.value.type = 'order';

      await FireStoreUtils.setTransactionLog(transactionLogModel.value);
    } catch (e, stackTrace) {
      developer.log("Error saving transaction log: $e", stackTrace: stackTrace);
    }
  }

  // ::::::::::::::::::::::::::::::::::::::::::::Wallet::::::::::::::::::::::::::::::::::::::::::::::::::::
  Future<void> walletPayment() async {
    try {
      ShowToastDialog.showLoader("Please Wait..".tr);

      orderModel.value.paymentStatus = true;

      WalletTransactionModel walletTransactionModel = WalletTransactionModel(
        id: Constant.getUuid(),
        amount: calculateFinalAmount().toString(),
        paymentType: selectedPaymentMethod.value,
        transactionId: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: FireStoreUtils.getCurrentUid(),
        isCredit: false,
        type: Constant.user,
        note: "Order Amount Debited",
        createdDate: Timestamp.now(),
      );

      final result = await FireStoreUtils.setWalletTransaction(walletTransactionModel);
      if (result == true) {
        final updateResult = await FireStoreUtils.updateUserWallet(
          amount: "-${Constant.calculateFinalAmount(orderModel.value)}",
        );
        if (updateResult) {
          await getProfileData();
        }
      }

      ShowToastDialog.closeLoader();
      await completeOrder(DateTime.now().millisecondsSinceEpoch.toString(), true);
    } catch (e, stackTrace) {
      developer.log("Error during wallet payment: $e", stackTrace: stackTrace);
    }
  }

  // ::::::::::::::::::::::::::::::::::::::::::::Stripe::::::::::::::::::::::::::::::::::::::::::::::::::::
  Future<void> stripeMakePayment({required String amount}) async {
    try {
      Map<String, dynamic>? paymentIntentData = await createStripeIntent(amount: amount);

      if (paymentIntentData == null || paymentIntentData.containsKey("error")) {
        Get.back();
        ShowToastDialog.showToast("An error occurred while creating payment intent. Please contact support.".tr);
        return;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          allowsDelayedPaymentMethods: false,
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true,
            currencyCode: 'USD',
          ),
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: AppThemeData.primary500,
            ),
          ),
          merchantDisplayName: 'Go4Food',
        ),
      );

      displayStripePaymentSheet(
        amount: amount,
        client_secret: paymentIntentData['client_secret'],
      );
    } catch (e, s) {
      developer.log("Error during Stripe payment: $e", stackTrace: s);
    }
  }

  Future<void> displayStripePaymentSheet({
    required String amount,
    required String client_secret,
  }) async {
    try {
      await Stripe.instance.presentPaymentSheet();

      ShowToastDialog.showToast("Payment processed successfully.".tr);

      try {
        final paymentIntent = await Stripe.instance.retrievePaymentIntent(client_secret);

        await completeOrder(paymentIntent.id, true);

        await setTransactionLog(
          isCredit: true,
          transactionId: paymentIntent.id,
          transactionLog: paymentIntent,
          amount: amount,
        );
      } catch (e, stack) {
        developer.log("Error retrieving payment intent: $e", stackTrace: stack);
      }
    } on StripeException catch (e, stack) {
      developer.log("StripeException: $e", stackTrace: stack);
      try {
        final decoded = jsonDecode(jsonEncode(e));
        final failedModel = StripePayFailedModel.fromJson(decoded);
        ShowToastDialog.showToast(failedModel.error.message);
      } catch (e, stack) {
        developer.log("Error decoding Stripe exception: $e", stackTrace: stack);
      }
    } catch (e, stack) {
      developer.log("Error displaying Stripe payment sheet: $e", stackTrace: stack);
    }
  }

  Future<Map<String, dynamic>?> createStripeIntent({required String amount}) async {
    try {
      Map<String, dynamic> body = {
        'amount': ((double.parse(amount) * 100).round()).toString(),
        'currency': currencyCode.value,
        'payment_method_types[]': 'card',
        "description": "Stripe Payment",
        "shipping[name]": "${userModel.value.firstName!} ${userModel.value.lastName!}",
        "shipping[address][line1]": "510 Townsend St",
        "shipping[address][postal_code]": "98140",
        "shipping[address][city]": "San Francisco",
        "shipping[address][state]": "CA",
        "shipping[address][country]": "US",
      };

      final stripeSecret = paymentModel.value.strip!.stripeSecret;

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer $stripeSecret',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode != 200 || responseData.containsKey('error')) {
        return {'error': responseData['error']['message'] ?? 'Stripe error occurred'};
      }

      return responseData;
    } catch (e, stack) {
      developer.log("Error creating Stripe payment intent: $e", stackTrace: stack);
      return {'error': 'Failed to create payment intent: ${e.toString()}'};
    }
  }

  // ::::::::::::::::::::::::::::::::::::::::::::PayPal::::::::::::::::::::::::::::::::::::::::::::::::::::
  Future<void> payPalPayment({required String amount}) async {
    try {
      ShowToastDialog.closeLoader();
      await Get.to(() => PaypalPayment(
            onFinish: (result) {
              try {
                if (result != null) {
                  Get.back();
                  ShowToastDialog.showToast("Payment successful.".tr);
                  completeOrder(result['orderId'], true);
                  setTransactionLog(
                    isCredit: true,
                    transactionId: result['orderId'],
                    transactionLog: result,
                    amount: amount,
                  );
                } else {
                  ShowToastDialog.showToast("Payment was canceled or failed.".tr);
                }
              } catch (e, stackTrace) {
                developer.log("Error processing PayPal payment: $e", stackTrace: stackTrace);
              }
            },
            price: amount,
            currencyCode: currencyCode.value,
            title: "Add Money",
            description: "Add Balance in Wallet",
          ));
    } catch (e, stackTrace) {
      developer.log("Error during PayPal payment: $e", stackTrace: stackTrace);
    }
  }

  Future<void> razorpayMakePayment({required String amount}) async {
    try {
      var options = {
        'key': paymentModel.value.razorpay!.razorpayKey,
        "razorPaySecret": paymentModel.value.razorpay!.razorpayKey,
        'amount': double.parse(amount) * 100,
        "currency": currencyCode.value,
        'name': userModel.value.firstName! + userModel.value.lastName!,
        "isSandBoxEnabled": paymentModel.value.razorpay!.isSandbox,
        'external': {
          'wallets': ['paytm']
        },
        'send_sms_hash': true,
        'prefill': {
          'contact': userModel.value.phoneNumber,
          'email': userModel.value.email,
        },
      };

      _razorpay.open(options);

      _razorpay.on(razor_pay_flutter.Razorpay.EVENT_PAYMENT_SUCCESS, (response) {
        _handlePaymentSuccess(response, amount);
      });

      _razorpay.on(razor_pay_flutter.Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

      _razorpay.on(razor_pay_flutter.Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    } catch (e, stackTrace) {
      developer.log("Error during Razorpay payment: $e", stackTrace: stackTrace);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response, String amount) {
    try {
      ShowToastDialog.showToast("Payment processed successfully.".tr);

      _razorpay.clear();
      _razorpay = razor_pay_flutter.Razorpay();

      final transactionId = response.paymentId ?? DateTime.now().millisecondsSinceEpoch.toString();

      completeOrder(transactionId, true);

      setTransactionLog(
        isCredit: true,
        transactionId: transactionId,
        transactionLog: {
          "paymentId": response.paymentId,
          "orderId": response.orderId,
          "signature": response.signature,
          "data": response.data,
        },
        amount: amount,
      );
    } catch (e, stackTrace) {
      developer.log("Error in _handlePaymentSuccess: $e", stackTrace: stackTrace);
    } finally {
      ShowToastDialog.closeLoader();
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    try {
      ShowToastDialog.showToast("Payment could not be completed. Please try again.".tr);
    } catch (e) {
      developer.log("Error in _handlePaymentError: $e");
    } finally {
      ShowToastDialog.closeLoader();
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    try {} catch (e) {
      developer.log("Error in _handleExternalWallet: $e");
    } finally {
      ShowToastDialog.closeLoader();
    }
  }

  // ::::::::::::::::::::::::::::::::::::::::::::FlutterWave::::::::::::::::::::::::::::::::::::::::::::::::::::
  Future<void> flutterWaveInitiatePayment({required BuildContext context, required String amount}) async {
    try {
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

        final result = await Get.to(
          FlutterWaveScreen(initialURl: data['data']['link']),
        );

        if (result != null && result is Map<String, dynamic>) {
          if (result["status"] == true) {
            ShowToastDialog.showToast("Payment successful.".tr);
            completeOrder(result['transaction_id'], true);
            setTransactionLog(
              isCredit: true,
              transactionId: result['transaction_id'],
              transactionLog: result,
              amount: amount,
            );
          } else {
            ShowToastDialog.showToast("Payment was unsuccessful.".tr);
          }
        } else {
          ShowToastDialog.showToast("Payment was unsuccessful.".tr);
        }
      } else {
        if (response.statusCode == 400) {
          ShowToastDialog.closeLoader();
          Get.back();
        } else {
          ShowToastDialog.showToast("Failed to initiate payment. Please try again.".tr);
        }
      }
    } catch (e, stackTrace) {
      developer.log("Error during Flutterwave payment: $e", stackTrace: stackTrace);
      Get.back();
    } finally {
      ShowToastDialog.closeLoader();
    }
  }

  String? _ref;

  void setRef() {
    try {
      final numRef = maths.Random();
      final year = DateTime.now().year;
      final refNumber = numRef.nextInt(20000);

      if (Platform.isAndroid) {
        _ref = "AndroidRef$year$refNumber";
      } else if (Platform.isIOS) {
        _ref = "IOSRef$year$refNumber";
      } else {
        _ref = "OtherRef$year$refNumber";
      }
    } catch (e, stackTrace) {
      developer.log("Error generating reference: $e", stackTrace: stackTrace);
      _ref = "UnknownRef${DateTime.now().millisecondsSinceEpoch}";
    }
  }

  // ::::::::::::::::::::::::::::::::::::::::::::PayStack::::::::::::::::::::::::::::::::::::::::::::::::::::

  Future<void> payStackPayment({required String totalAmount}) async {
    try {
      final amountInKobo = (double.parse(totalAmount) * 100).toString();
      final secretKey = paymentModel.value.payStack!.payStackSecret.toString();

      final payStackModel = await PayStackURLGen.payStackURLGen(
        amount: amountInKobo,
        currency: currencyCode.value,
        secretKey: secretKey,
        userModel: userModel.value,
      );

      if (payStackModel != null) {
        final result = await Get.to(PayStackScreen(
          secretKey: secretKey,
          callBackUrl: Constant.paymentCallbackURL.toString(),
          initialURl: payStackModel.data.authorizationUrl,
          amount: totalAmount,
          reference: payStackModel.data.reference,
        ));

        if (result == true) {
          ShowToastDialog.showToast("Payment successful.".tr);
          completeOrder(DateTime.now().millisecondsSinceEpoch.toString(), true);
        } else {
          ShowToastDialog.showToast("Payment was unsuccessful.".tr);
        }
      } else {
        ShowToastDialog.showToast("An error occurred. Please contact support.".tr);
      }
    } catch (e, stackTrace) {
      developer.log("Error during PayStack payment: $e", stackTrace: stackTrace);
    }
  }

  // ::::::::::::::::::::::::::::::::::::::::::::Mercado Pago::::::::::::::::::::::::::::::::::::::::::::::::::::

  Future<void> mercadoPagoMakePayment({required BuildContext context, required String amount}) async {
    try {
      final result = await makePreference(amount);

      if (result.isNotEmpty) {
        if (result['status'] == 200) {
          final String initUrl = result['response']['init_point'];

          final value = await Get.to(
            MercadoPagoScreen(initialURl: initUrl),
          );

          if (value == true) {
            ShowToastDialog.showToast("Payment successful.".tr);
            completeOrder(DateTime.now().millisecondsSinceEpoch.toString(), true);
          } else {
            ShowToastDialog.showToast("Payment could not be completed.".tr);
          }
        } else {
          ShowToastDialog.showToast("Transaction error occurred.".tr);
        }
      } else {
        ShowToastDialog.showToast("Transaction error occurred.".tr);
      }
    } catch (e, stackTrace) {
      developer.log("Error during Mercado Pago payment: $e", stackTrace: stackTrace);
    }
  }

  Future<Map<String, dynamic>> makePreference(String amount) async {
    try {
      final mp = MP.fromAccessToken(paymentModel.value.mercadoPago!.mercadoPagoAccessToken);

      final pref = {
        "items": [
          {
            "title": "Wallet TopUp",
            "quantity": 1,
            "unit_price": double.parse(amount),
          }
        ],
        "auto_return": "all",
        "back_urls": {
          "failure": "${Constant.paymentCallbackURL}/failure",
          "pending": "${Constant.paymentCallbackURL}/pending",
          "success": "${Constant.paymentCallbackURL}/success",
        },
      };

      final result = await mp.createPreference(pref);
      return result;
    } catch (e, stackTrace) {
      developer.log("Error creating Mercado Pago preference: $e", stackTrace: stackTrace);
      return {};
    }
  }

  // ::::::::::::::::::::::::::::::::::::::::::::Pay Fast::::::::::::::::::::::::::::::::::::::::::::::::::::

  Future<void> payFastPayment({required BuildContext context, required String amount}) async {
    try {
      final htmlData = await PayStackURLGen.getPayHTML(
        payFastSettingData: paymentModel.value.payFast!,
        amount: amount.toString(),
        userModel: userModel.value,
      );

      if (htmlData.isNotEmpty) {
        final isDone = await Get.to(
          PayFastScreen(
            htmlData: htmlData,
            payFastSettingData: paymentModel.value.payFast!,
          ),
        );
        Get.back();
        if (isDone == true) {
          ShowToastDialog.showToast("Payment processed successfully.".tr);
          completeOrder(DateTime.now().millisecondsSinceEpoch.toString(), true);
        } else {
          ShowToastDialog.showToast("Payment could not be completed.".tr);
        }
      } else {
        ShowToastDialog.showToast("Unable to load payment gateway.".tr);
      }
    } catch (e, stackTrace) {
      developer.log("Error during PayFast payment: $e", stackTrace: stackTrace);
      Get.back();
    }
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
            ShowToastDialog.showToast("Payment successful.".tr);
            completeOrder(DateTime.now().millisecondsSinceEpoch.toString(), true);
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
        ShowToastDialog.showToast("Payment successful.".tr);
        completeOrder(DateTime.now().millisecondsSinceEpoch.toString(), true);
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
