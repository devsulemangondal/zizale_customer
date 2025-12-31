import 'package:customer/app/models/driver_delivery_charge_model.dart';

class GlobalValueModel {
  String? distanceType;
  String? driverLocationUpdate;
  String? radius;
  String? restaurantRadius;
  DriverDeliveryChargeModel? deliveryCharge;

  GlobalValueModel({this.distanceType, this.driverLocationUpdate, this.radius, this.restaurantRadius, this.deliveryCharge});

  GlobalValueModel.fromJson(Map<String, dynamic> json) {
    distanceType = json['distanceType'];
    driverLocationUpdate = json['driverLocationUpdate'];
    radius = json['radius'];
    restaurantRadius = json['restaurantRadius'];
    deliveryCharge = json['deliveryCharge'] != null ? DriverDeliveryChargeModel.fromJson(json['deliveryCharge']) : DriverDeliveryChargeModel();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['distanceType'] = distanceType;
    data['driverLocationUpdate'] = driverLocationUpdate;
    data['radius'] = radius;
    data['restaurantRadius'] = restaurantRadius;
    if (deliveryCharge != null) {
      data['deliveryCharge'] = deliveryCharge!.toJson();
    }
    return data;
  }
}
