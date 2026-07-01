// To parse this JSON data, do
//
//     final AadharDataModel = AadharDataModelFromJson(jsonString);

import 'dart:convert';

AadharDataModel AadharDataModelFromJson(String str) =>
    AadharDataModel.fromJson(json.decode(str));

String AadharDataModelToJson(AadharDataModel data) =>
    json.encode(data.toJson());

class AadharDataModel {
  String? version;
  String? dateTime;
  String? ipAddress;
  String? referenceid;
  String? name;
  String? dob;
  String? gender;
  String? careof;
  String? district;
  String? landmark;
  String? house;
  String? location;
  String? pincode;
  String? postoffice;
  String? state;
  String? street;
  String? subdistrict;
  String? vtc;
  String? last4DigitsMobileNo;
  String? aadhaarLast4Digit;
  String? aadhaarLastDigit;
  bool? email;
  bool? mobile;
  List<int> profileimage = const [];

  AadharDataModel({
    this.version,
    this.referenceid,
    this.ipAddress,
    this.name,
    this.dateTime,
    this.dob,
    this.gender,
    this.careof,
    this.district,
    this.landmark,
    this.house,
    this.location,
    this.pincode,
    this.postoffice,
    this.state,
    this.street,
    this.subdistrict,
    this.vtc,
    this.last4DigitsMobileNo,
    this.aadhaarLast4Digit,
    this.aadhaarLastDigit,
    this.email,
    this.mobile,
    this.profileimage = const [],
  });

  factory AadharDataModel.fromJson(Map<String, dynamic> json) =>
      AadharDataModel(
        version: json["version"],
        dateTime: json["dateTime"],
        ipAddress: json["ipAddress"],
        referenceid: json["referenceid"]?.toString(),
        name: json["name"],
        dob: json["dob"],
        gender: json["gender"],
        careof: json["careof"],
        district: json["district"],
        landmark: json["landmark"],
        house: json["house"],
        location: json["location"],
        pincode: json["pincode"],
        postoffice: json["postoffice"],
        state: json["state"],
        street: json["street"],
        subdistrict: json["subdistrict"],
        vtc: json["vtc"],
        last4DigitsMobileNo: json["last_4_digits_mobile_no"],
        aadhaarLast4Digit: json["aadhaar_last_4_digit"],
        aadhaarLastDigit: json["aadhaar_last_digit"],
        email: json["email"],
        mobile: json["mobile"],
        profileimage: json["profileimage"] != null
            ? List<int>.from(json["profileimage"].map((x) => x))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "version": version,
        "dateTime": dateTime,
        "referenceid": referenceid,
        "ipAddress": ipAddress,
        "name": name,
        "dob": dob,
        "gender": gender,
        "careof": careof,
        "district": district,
        "landmark": landmark,
        "house": house,
        "location": location,
        "pincode": pincode,
        "postoffice": postoffice,
        "state": state,
        "street": street,
        "subdistrict": subdistrict,
        "vtc": vtc,
        "last_4_digits_mobile_no": last4DigitsMobileNo,
        "aadhaar_last_4_digit": aadhaarLast4Digit,
        "aadhaar_last_digit": aadhaarLastDigit,
        "email": email,
        "mobile": mobile,
        "profileimage": List<dynamic>.from(profileimage.map((x) => x)),
      };
}
