// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/models/add_address_model.dart';

class UserModel {
  String? firstName;
  String? lastName;
  String? slug;
  String? id;
  String? email;
  String? password;
  String? loginType;
  String? userType;
  String? profilePic;
  String? dateOfBirth;
  String? fcmToken;
  String? countryCode;
  String? phoneNumber;
  String? walletAmount;
  bool? isActive;
  Timestamp? createdAt;
  List<AddAddressModel>? addAddresses;
  List<dynamic>? searchNameKeywords;
  List<dynamic>? searchEmailKeywords;

  UserModel({
    this.firstName,
    this.lastName,
    this.slug,
    this.id,
    this.isActive,
    this.dateOfBirth,
    this.email,
    this.password,
    this.loginType,
    this.userType,
    this.profilePic,
    this.fcmToken,
    this.countryCode,
    this.phoneNumber,
    this.walletAmount,
    this.createdAt,
    this.addAddresses,
    this.searchNameKeywords,
    this.searchEmailKeywords,
  });


  String fullNameString() {
    String fullName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    return fullName.isEmpty ? "N/A" : fullName;
  }

  UserModel.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    slug = json['slug'];
    id = json['id'];
    email = json['email'];
    password = json['password'];
    loginType = json['loginType'];
    userType = json['userType'];
    profilePic = json['profilePic'];
    fcmToken = json['fcmToken'];
    countryCode = json['countryCode'];
    phoneNumber = json['phoneNumber'];
    walletAmount = json['walletAmount'] ?? "0";
    createdAt = json['createdAt'];
    dateOfBirth = json['dateOfBirth'] ?? '';
    isActive = json['isActive'];
    searchNameKeywords = json['searchNameKeywords'] ?? [];
    searchEmailKeywords = json['searchEmailKeywords'] ?? [];
    if (json['customerAddresses'] != null) {
      if (json['customerAddresses'] is List) {
        addAddresses = List<AddAddressModel>.from(json['customerAddresses'].map((x) => AddAddressModel.fromJson(x)));
      } else {
        addAddresses = [];
      }
    } else {
      addAddresses = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['slug'] = slug;
    data['id'] = id;
    data['email'] = email;
    data['loginType'] = loginType;
    data['userType'] = userType;
    data['profilePic'] = profilePic;
    data['fcmToken'] = fcmToken;
    data['countryCode'] = countryCode;
    data['phoneNumber'] = phoneNumber;
    data['walletAmount'] = walletAmount;
    data['createdAt'] = createdAt;
    data['dateOfBirth'] = dateOfBirth;
    data['isActive'] = isActive;
    data['searchNameKeywords'] = searchNameKeywords;
    data['searchEmailKeywords'] = searchEmailKeywords;
    if (addAddresses != null) {
      data['customerAddresses'] = addAddresses!.map((address) => address.toJson()).toList();
    }
    return data;
  }
}