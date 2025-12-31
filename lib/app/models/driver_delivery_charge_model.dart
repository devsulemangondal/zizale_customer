class DriverDeliveryChargeModel {
  String? farPerKm;
  String? minimumChargeWithinKm;
  String? fareMinimumCharge;

  DriverDeliveryChargeModel({this.farPerKm, this.minimumChargeWithinKm, this.fareMinimumCharge});

  DriverDeliveryChargeModel.fromJson(Map<String, dynamic> json) {
    farPerKm = json['farPerKm'];
    minimumChargeWithinKm = json['minimumChargeWithinKm'];
    fareMinimumCharge = json['fareMinimumCharge'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['farPerKm'] = farPerKm;
    data['minimumChargeWithinKm'] = minimumChargeWithinKm;
    data['fareMinimumCharge'] = fareMinimumCharge;
    return data;
  }
}
