class PlatFormFeeSettingModel {
  String? platformFee;
  bool? platformFeeActive;
  bool? packagingFeeActive;

  PlatFormFeeSettingModel({this.platformFee, this.platformFeeActive,this.packagingFeeActive});

  PlatFormFeeSettingModel.fromJson(Map<String, dynamic> json) {
    platformFee = json['platformFee'];
    platformFeeActive = json['platformFeeActive'];
    packagingFeeActive = json['packagingFeeActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['platformFee'] = platformFee;
    data['platformFeeActive'] = platformFeeActive;
    data['packagingFeeActive'] = packagingFeeActive;
    return data;
  }
}
