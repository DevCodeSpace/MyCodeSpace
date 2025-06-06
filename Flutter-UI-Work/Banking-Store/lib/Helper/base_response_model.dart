class BaseResponseModel {
  bool status = false;
  bool isActive = false;
  String? message;

  BaseResponseModel({
    this.status = false,
    this.isActive = false,
    this.message,
  });

  BaseResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    isActive = json['isActive'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['isActive'] = isActive;
    data['message'] = message;
    return data;
  }
}
