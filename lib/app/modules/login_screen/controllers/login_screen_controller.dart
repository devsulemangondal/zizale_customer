// ignore_for_file: body_might_complete_normally_catch_error, invalid_return_type_for_catch_error, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:customer/app/models/add_address_model.dart';
import 'package:customer/app/models/location_lat_lng.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/modules/account_disabled_screen.dart';
import 'package:customer/app/modules/dashboard_screen/views/dashboard_screen_view.dart';
import 'package:customer/app/modules/home/controllers/home_controller.dart';
import 'package:customer/app/modules/login_screen/views/verify_otp_view.dart';
import 'package:customer/app/modules/signup_screen/views/signup_screen_view.dart';
import 'package:customer/app/widget/permission_dialog.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:customer/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreenController extends GetxController {
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> passwordController = TextEditingController().obs;
  Rx<TextEditingController> mobileNumberController = TextEditingController().obs;
  Rx<TextEditingController> resetEmailController = TextEditingController().obs;
  Rx<TextEditingController> addressController = TextEditingController().obs;
  Rx<TextEditingController> firstNameController = TextEditingController().obs;
  Rx<TextEditingController> lastNameController = TextEditingController().obs;
  Rx<AddAddressModel> addAddressModel = AddAddressModel().obs;
  Rx<UserModel> userModel = UserModel().obs;
  RxString loginType = "".obs;
  Rx<String?> countryCode = "+91".obs;
  Rx<String> verificationId = "".obs;
  Rx<String> otpCode = "".obs;
  RxBool isPasswordVisible = true.obs;
  RxBool isVerifyOTPButtonEnabled = false.obs;
  RxBool isLoginButtonEnabled = false.obs;
  RxBool isMobileNumberButtonEnabled = false.obs;
  RxBool isVerifyButtonEnabled = false.obs;

  RxInt secondsRemaining = 20.obs;
  RxBool enableResend = false.obs;
  Timer? timer;

  void checkFieldsFilled() {
    try {
      isLoginButtonEnabled.value = emailController.value.text.isNotEmpty && passwordController.value.text.isNotEmpty;

      isMobileNumberButtonEnabled.value = mobileNumberController.value.text.isNotEmpty;
    } catch (e, stackTrace) {
      developer.log("Error in checkFieldsFilled: $e", stackTrace: stackTrace);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ShowToastDialog.showToast("Password reset email sent.".tr);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        developer.log("No user found for that email.");
      } else {
        developer.log("Something went wrong.");
      }
    } catch (e) {
      developer.log("Error in resetPassword: $e");
    }
  }

  void startTimer() {
    try {
      enableResend.value = false;
      secondsRemaining.value = 20;

      timer?.cancel();

      timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        try {
          if (secondsRemaining.value > 0) {
            secondsRemaining.value--;
          } else {
            enableResend.value = true;
            timer.cancel();
          }
        } catch (e, stackTrace) {
          developer.log("Error in timer callback: $e", stackTrace: stackTrace);
          timer.cancel();
        }
      });
    } catch (e, stackTrace) {
      developer.log("Error in startTimer: $e", stackTrace: stackTrace);
    }
  }

  Future<void> sendCode() async {
    try {
      ShowToastDialog.showLoader("Please Wait..".tr);

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: countryCode.value! + mobileNumberController.value.text,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          ShowToastDialog.closeLoader();

          if (e.code == 'invalid-phone-number') {
            ShowToastDialog.showToast("Invalid phone number entered.".tr);
          } else if (e.code == 'too-many-requests') {
            ShowToastDialog.showToast("Too many requests. Please try again later.".tr);
          } else {
            ShowToastDialog.showToast("Verification failed: ${e.message}".tr);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          ShowToastDialog.closeLoader();
          this.verificationId.value = verificationId;
          Get.to(() => VerifyOtpView());
          startTimer();
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e, stackTrace) {
      ShowToastDialog.closeLoader();
      developer.log("Error in sendCode: $e", stackTrace: stackTrace);
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> emailSignIn() async {
    ShowToastDialog.showLoader("Please Wait..".tr);

    final String email = emailController.value.text;
    final String password = passwordController.value.text;

    try {
      final userCredential = await signInWithEmailAndPassword(email, password);

      if (userCredential == null) {
        ShowToastDialog.closeLoader();
        return;
      }
      UserModel? userProfile = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()!);
      String fcmToken = await NotificationService.getToken();

      if (userProfile != null) {
        userProfile.fcmToken = fcmToken;
        await FireStoreUtils.updateUser(userProfile);
        if (userProfile.isActive == true) {
          ShowToastDialog.showToast("Logged in successfully!".tr);
          ShowToastDialog.closeLoader();
          Get.offAll(const DashboardScreenView());
        } else {
          await FirebaseAuth.instance.signOut();
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast("Contact administrator for support.".tr);
        }
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Incorrect email or password.".tr);
      }
    } on FirebaseAuthException catch (e) {
      developer.log("Firebase code : ${e.code}");
      ShowToastDialog.closeLoader();
      switch (e.code) {
        case 'invalid-email':
          ShowToastDialog.showToast("The email address is not valid.".tr);
          break;
        case 'invalid-credential':
          ShowToastDialog.showToast("Invalid email or password. Please try again.".tr);
          break;
        case 'user-disabled':
          ShowToastDialog.showToast("This user account has been disabled.".tr);
          break;
        case 'user-not-found':
          ShowToastDialog.showToast("No user found with this email.".tr);
          break;
        case 'wrong-password':
          ShowToastDialog.showToast("Incorrect password. Please try again.".tr);
          break;
        case 'too-many-requests':
          ShowToastDialog.showToast("Too many attempts. Please try again later.".tr);
          break;
        case 'network-request-failed':
          ShowToastDialog.showToast("Network error. Please check your connection.".tr);
          break;
        default:
          ShowToastDialog.showToast("${"Login failed:".tr} ${e.message}");
          break;
      }
    } catch (e) {
      developer.log("Login error", error: e);
      ShowToastDialog.closeLoader();
    }
  }

  final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  Future<void> initializeGoogleSignIn() async {
    await googleSignIn.initialize(
      serverClientId: '339012005849-mt8hkep8nt1s0l9djgfp4lbqgol4mrei.apps.googleusercontent.com',
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      initializeGoogleSignIn();
      if (!googleSignIn.supportsAuthenticate()) {
        if (kDebugMode) {
          print('This platform does not support authenticate().');
        }
        return null;
      }

      GoogleSignInAccount? googleSignInAccount = await googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleSignInAccount.authentication;

      final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      developer.log("Error in signInWithGoogle: $e");
    }
    return null;
  }

  Future<void> loginWithGoogle() async {
    ShowToastDialog.showLoader("Please Wait..".tr);

    try {
      final value = await signInWithGoogle();

      ShowToastDialog.closeLoader();

      if (value == null) {
        ShowToastDialog.showToast("Google sign-in failed.".tr);
        return;
      }

      final fcmToken = await NotificationService.getToken();

      if (value.additionalUserInfo?.isNewUser == true) {
        UserModel userModel = UserModel(
          id: value.user?.uid,
          email: value.user?.email,
          firstName: value.user?.displayName,
          profilePic: value.user?.photoURL,
          loginType: Constant.googleLoginType,
          fcmToken: fcmToken,
        );

        Get.to(SignupScreenView(), arguments: {'userModel': userModel});
      } else {
        bool userExist = await FireStoreUtils.userExistOrNot(value.user!.uid);
        ShowToastDialog.closeLoader();

        if (userExist) {
          UserModel? userModel = await FireStoreUtils.getUserProfile(value.user!.uid);

          if (userModel != null) {
            userModel.fcmToken = fcmToken;
            await FireStoreUtils.updateUser(userModel);
            if (userModel.isActive == true) {
              Get.offAll(const DashboardScreenView());
            } else {
              Get.offAll(const AccountDisabledScreen());
            }
          } else {
            ShowToastDialog.showToast("This account is not valid for this app.".tr);
          }
        } else {
          UserModel userModel = UserModel(
            id: value.user?.uid,
            email: value.user?.email,
            firstName: value.user?.displayName,
            profilePic: value.user?.photoURL,
            loginType: Constant.googleLoginType,
            fcmToken: fcmToken,
          );

          Get.to(SignupScreenView(), arguments: {'userModel': userModel});
        }
      }
    } catch (e, stackTrace) {
      developer.log("Error in loginWithGoogle: $e", stackTrace: stackTrace);
    }
  }

  Future<UserCredential?> signInWithApple() async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    } on SignInWithAppleAuthorizationException catch (e) {
      ShowToastDialog.showToast("Apple Sign-In failed.".tr);
      developer.log("Error in signInWithApple: ${e.message}", name: "Apple Sign-In Error");
    } catch (e, stackTrace) {
      developer.log("Error in signInWithApple: $e", stackTrace: stackTrace);
    }

    return null;
  }

  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    try {
      final bytes = utf8.encode(input);
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e, stackTrace) {
      developer.log("Error in sha256ofString: $e", stackTrace: stackTrace);
      return '';
    }
  }

  Future<void> loginWithApple() async {
    ShowToastDialog.showLoader("Please Wait..".tr);

    try {
      final value = await signInWithApple();

      ShowToastDialog.closeLoader();

      if (value == null) {
        ShowToastDialog.showToast("Apple Sign-In failed.".tr);
        return;
      }

      final fcmToken = await NotificationService.getToken();

      if (value.additionalUserInfo?.isNewUser == true) {
        UserModel userModel = UserModel(
          id: value.user?.uid,
          email: value.user?.email,
          loginType: Constant.appleLoginType,
          profilePic: value.user?.photoURL,
          fcmToken: fcmToken,
        );

        Get.to(SignupScreenView(), arguments: {'userModel': userModel});
      } else {
        final userExists = await FireStoreUtils.userExistOrNot(value.user!.uid);

        if (userExists) {
          final userModel = await FireStoreUtils.getUserProfile(value.user!.uid);

          if (userModel != null) {
            userModel.fcmToken = fcmToken;
            await FireStoreUtils.updateUser(userModel);
            if (userModel.isActive == true) {
              Get.offAll(const DashboardScreenView());
            } else {
              Get.offAll(const AccountDisabledScreen());
            }
          } else {
            ShowToastDialog.showToast("This account is not valid for this app.".tr);
          }
        } else {
          UserModel userModel = UserModel(
            id: value.user?.uid,
            email: value.user?.email,
            loginType: Constant.appleLoginType,
            profilePic: value.user?.photoURL,
            firstName: value.user?.displayName,
            fcmToken: fcmToken,
          );
          Get.to(SignupScreenView(), arguments: {'userModel': userModel});
        }
      }
    } catch (e, stackTrace) {
      developer.log("Error in loginWithApple: $e", stackTrace: stackTrace);
    }
  }

  Future<void> checkPermission(Function() onTap) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        ShowToastDialog.showToast("You have to allow location permission to use your location".tr);
      } else if (permission == LocationPermission.deniedForever) {
        showDialog(
          context: Get.context!,
          builder: (BuildContext context) {
            return const PermissionDialog();
          },
        );
      } else {
        onTap();
      }
    } catch (e, stackTrace) {
      developer.log("Error in checkPermission: $e", stackTrace: stackTrace);
    }
  }

  Future<void> getUserLocation() async {
    await checkPermission(() async {
      ShowToastDialog.showLoader("Please Wait...".tr);

      try {
        final position = await Utils.getCurrentLocation();

        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isEmpty) {
          throw Exception("No address found for current location".tr);
        }

        final placeMark = placemarks.first;

        final fullAddress = "${placeMark.name ?? ''}, ${placeMark.subLocality ?? ''}, "
            "${placeMark.locality ?? ''}, ${placeMark.administrativeArea ?? ''}, "
            "${placeMark.postalCode ?? ''}, ${placeMark.country ?? ''}";

        addressController.value.text = fullAddress;

        addAddressModel.value = AddAddressModel(
            id: Constant.getUuid(),
            address: fullAddress,
            landmark: placeMark.subLocality ?? '',
            locality: placeMark.locality ?? '',
            addressAs: "Home",
            isDefault: true,
            name: Constant.userModel?.fullNameString() ?? '',
            location: LocationLatLng(
              latitude: position.latitude,
              longitude: position.longitude,
            ));

        // 🔹 Update global constant
        Constant.currentLocation = addAddressModel.value;
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().selectedAddress.value = Constant.currentLocation!;
        }

        developer.log("📍 Current location set: ${Constant.currentLocation!.toJson()}");

        // 🔹 Check service zone availability
        await Constant.checkZoneAvailability(Constant.currentLocation!.location!);

        // 🔹 Save address if user logged in
        if (await FireStoreUtils.isLogin()) {
          await saveAddress();
        }

        ShowToastDialog.closeLoader();
        Get.offAll(const DashboardScreenView());
      } catch (e, stackTrace) {
        developer.log("❌ Error in getUserLocation", error: e, stackTrace: stackTrace);

        // 🔹 Fallback default location if error
        Constant.currentLocation = AddAddressModel(location: LocationLatLng(latitude: 19.228825, longitude: 72.854118));

        ShowToastDialog.closeLoader();
        Get.offAll(const DashboardScreenView());
      }
    });
  }

  Future<void> saveAddress() async {
    try {
      Constant.userModel!.addAddresses ??= [];
      Constant.userModel!.addAddresses!.add(addAddressModel.value);

      final result = await FireStoreUtils.updateUser(Constant.userModel!);

      ShowToastDialog.closeLoader();

      if (result == true) {
        Constant.userModel = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()!);
      } else {
        ShowToastDialog.showToast("Failed to save address. Please try again.".tr);
      }
    } catch (e, stackTrace) {
      developer.log("Error in saveAddress: $e", stackTrace: stackTrace);
    }
  }
}
