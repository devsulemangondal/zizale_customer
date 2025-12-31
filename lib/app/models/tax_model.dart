class TaxModel {
  String? country;
  bool? active;
  String? value;
  String? id;
  bool? isFix;
  String? name;
  String? type;

  TaxModel({this.country, this.active, this.value, this.id, this.isFix, this.name, this.type});

  @override
  String toString() {
    return 'TaxModel{country: $country, active: $active, value: $value, id: $id, isFix: $isFix, name: $name, type: $type}';
  }

  TaxModel.fromJson(Map<String, dynamic> json) {
    country = json['country'];
    active = json['active'];
    value = json['value'];
    id = json['id'];
    isFix = json['isFix'];
    name = json['name'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['country'] = country;
    data['active'] = active;
    data['value'] = value;
    data['id'] = id;
    data['isFix'] = isFix;
    data['name'] = name;
    data['type'] = type;
    return data;
  }
}
