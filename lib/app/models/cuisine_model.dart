class CuisineModel {
  String? id;
  String? cuisineName;
  String? image;
  bool? active;

  CuisineModel({this.id, this.cuisineName, this.active, this.image});

  CuisineModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cuisineName = json['cuisineName'];
    image = json['image'];
    active = json['active'];
  }

  @override
  String toString() {
    return 'CuisineModel{id: $id, cuisineName: $cuisineName, image: $image, active: $active}';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['cuisineName'] = cuisineName;
    data['image'] = image;
    data['active'] = active;
    return data;
  }
}
