// ignore_for_file: depend_on_referenced_packages


class DocumentModel {
  String? id;
  String? name;
  bool? active;

  DocumentModel({
    this.id,
    this.name,
    this.active,
  });

  DocumentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['active'] = active;
    return data;
  }
}

class VerifyDocumentModel {
  String? documentId;
  String? documentImage;
  String? status;
  String? rejectedReason;

  VerifyDocumentModel({this.documentId, this.documentImage, this.status, this.rejectedReason});

  VerifyDocumentModel.fromJson(Map<String, dynamic> json) {
    documentId = json['documentId'];
    documentImage = json['documentImage'];
    status = json['status'];
    rejectedReason = json['rejectedReason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['documentId'] = documentId;
    data['documentImage'] = documentImage;
    data['status'] = status;
    data['rejectedReason'] = rejectedReason;
    return data;
  }
}
