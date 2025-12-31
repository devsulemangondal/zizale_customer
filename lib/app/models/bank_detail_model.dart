class  BankDetailsModel {
  String? id;
  String? customerId;
  String? holderName;
  String? accountNumber;
  String? swiftCode;
  String? ifscCode;
  String? bankName;
  String? branchCity;
  String? branchCountry;

  BankDetailsModel({
    this.id,
    this.customerId,
    this.holderName,
    this.accountNumber,
    this.swiftCode,
    this.ifscCode,
    this.bankName,
    this.branchCity,
    this.branchCountry,
  });

  @override
  String toString() {
    return 'BankDetailsModel{id: $id, customerId: $customerId, holderName: $holderName, accountNumber: $accountNumber, swiftCode: $swiftCode, ifscCode: $ifscCode, bankName: $bankName, branchCity: $branchCity, branchCountry: $branchCountry}';
  }

  BankDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customerId'];
    holderName = json['holderName'];
    accountNumber = json['accountNumber'];
    swiftCode = json['swiftCode'];
    ifscCode = json['ifscCode'];
    bankName = json['bankName'];
    branchCity = json['branchCity'];
    branchCountry = json['branchCountry'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['customerId'] = customerId;
    data['holderName'] = holderName;
    data['accountNumber'] = accountNumber;
    data['swiftCode'] = swiftCode;
    data['ifscCode'] = ifscCode;
    data['bankName'] = bankName;
    data['branchCity'] = branchCity;
    data['branchCountry'] = branchCountry;
    return data;
  }
}
