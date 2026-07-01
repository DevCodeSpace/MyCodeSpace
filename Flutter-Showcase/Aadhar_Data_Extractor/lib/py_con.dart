import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:io';
import 'package:image/image.dart' as img;

class AadhaarSecureQr {
  String? base10encodedstring;
  List<String>? details;
  List<int>? delimeter;
  Map<String, dynamic>? data;
  Uint8List? decompressedArray;

  AadhaarSecureQr(this.base10encodedstring) {
    delimeter = [-1];
    data = {};
    _convertBase10EncodedToDecompressedArray();
    _createDelimeter();
    _adjustFieldsForVersion();
    _extractInfoFromDecompressedArray();
  }

  void _convertBase10EncodedToDecompressedArray() {
    final bigIntValue = BigInt.tryParse(base10encodedstring ?? "") ?? BigInt.zero;
    if (bigIntValue == BigInt.zero) throw FormatException('Invalid QR data');
    final bytesArray = _bigIntToBytes(bigIntValue);
    final bytesArrayWithoutLeadingZeroes = _removeLeadingZeroes(bytesArray);
    decompressedArray = Uint8List.fromList(zlib.decode(bytesArrayWithoutLeadingZeroes));
  }

  Uint8List _bigIntToBytes(BigInt value) {
    final hexString = value.toRadixString(16).padLeft(value.toRadixString(16).length + (value.toRadixString(16).length % 2), '0');
    final bytes = <int>[];
    for (var i = 0; i < hexString.length; i += 2) {
      bytes.add(int.parse(hexString.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

  Uint8List _removeLeadingZeroes(Uint8List bytes) {
    var i = 0;
    while (i < bytes.length && bytes[i] == 0) {
      i++;
    }
    return Uint8List.sublistView(bytes, i);
  }

  void _createDelimeter() {
    for (int i = 0; i < decompressedArray!.length; i++) {
      if (decompressedArray![i] == 255) delimeter!.add(i);
    }
  }

  void _adjustFieldsForVersion() {
    if (decompressedArray == null || delimeter!.length < 3) return;

    // Field 0 aur Field 1 ko safely decode karte hain
    final field0 = utf8.decode(decompressedArray!.sublist(0, delimeter![1]), allowMalformed: true).replaceAll('\x00', '').trim();

    final isV5 = RegExp(r'^V\d+$', caseSensitive: false).hasMatch(field0);
    final isV2 = RegExp(r'^\d$').hasMatch(field0);

    if (isV5) {
      // V5 Format: field0=version("V5"), field1=email/mobile indicator
      // house aur landmark ka order V2 se alag hai
      details = [
        "version",
        "email_mobile_present",
        "referenceid",
        "name",
        "dob",
        "gender",
        "careof",
        "district",
        "house",
        "landmark",
        "location",
        "pincode",
        "postoffice",
        "state",
        "street",
        "subdistrict",
        "vtc",
      ];

      // email/mobile flag field[1] mein hota hai V5 mein
      if (delimeter!.length >= 3) {
        final field1 = utf8.decode(decompressedArray!.sublist(delimeter![1] + 1, delimeter![2]), allowMalformed: true).trim();
        int flag = int.tryParse(field1.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        if (flag & 1 != 0) details!.add("email_hash");
        if (flag & 2 != 0) details!.add("mobile_hash");
      }
    } else if (isV2) {
      // V2 Format
      details = [
        "email_mobile_present",
        "referenceid",
        "name",
        "dob",
        "gender",
        "careof",
        "district",
        "landmark",
        "house",
        "location",
        "pincode",
        "postoffice",
        "state",
        "street",
        "subdistrict",
        "vtc",
      ];

      // Bitmask: bit0 = email, bit1 = mobile
      int flag = int.tryParse(field0.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (flag & 1 != 0) details!.add("email_hash");
      if (flag & 2 != 0) details!.add("mobile_hash");
    } else {
      // V1 Format
      details = ["referenceid", "name", "dob", "gender", "careof", "district", "landmark", "house", "location", "pincode", "postoffice", "state", "street", "subdistrict", "vtc"];
    }
  }

  void _extractInfoFromDecompressedArray() {
    if (details == null || delimeter == null) return;
    final maxFields = math.min(details!.length, delimeter!.length - 1);

    for (int i = 0; i < maxFields; i++) {
      String rawValue = utf8.decode(decompressedArray!.sublist(delimeter![i] + 1, delimeter![i + 1]), allowMalformed: true);
      data![details![i]] = rawValue.replaceAll('\x00', '').trim();
    }

    final refId = data!['referenceid'] ?? '';
    data!['aadhaar_last_4_digit'] = refId.length >= 4 ? refId.substring(0, 4) : refId;
    data!['aadhaar_last_digit'] = refId.length >= 4 ? refId[3] : (refId.isNotEmpty ? refId[refId.length - 1] : '');

    if (details!.contains("email_mobile_present")) {
      int flag = int.tryParse((data!['email_mobile_present'] ?? '0').replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      data!['email'] = (flag & 1) != 0;
      data!['mobile'] = (flag & 2) != 0;
    } else {
      data!['email'] = false;
      data!['mobile'] = false;
    }
  }

  Map<String, dynamic>? decodedData() => data;

  Uint8List signature() => decompressedArray!.sublist(decompressedArray!.length - 256);

  Uint8List signedData() => decompressedArray!.sublist(0, decompressedArray!.length - 256);

  bool isMobileNoRegistered() => data!['mobile'] as bool? ?? false;

  bool isEmailRegistered() => data!['email'] as bool? ?? false;

  img.Image? getAdharimage() {
    if (delimeter == null || details == null) return null;

    final lastTextDelimIdx = details!.length;
    if (lastTextDelimIdx >= delimeter!.length) return null;

    final imgStart = delimeter![lastTextDelimIdx] + 1;
    final imgEnd = decompressedArray!.length - 256;

    if (imgStart >= imgEnd) return null;

    final imgData = decompressedArray!.sublist(imgStart, imgEnd);
    return img.decodeImage(Uint8List.fromList(imgData));
  }

  /// Raw image bytes return karta hai (JPEG ya JPEG 2000)
  /// Caller platform channel se decode karega agar JP2 hai
  Uint8List? getRawImageBytes() {
    if (delimeter == null || details == null) return null;

    final lastTextDelimIdx = details!.length;
    if (lastTextDelimIdx >= delimeter!.length) return null;

    final imgStart = delimeter![lastTextDelimIdx] + 1;
    final imgEndWithSig = decompressedArray!.length - 256;

    if (imgStart >= imgEndWithSig) return null;

    final rawBytes = decompressedArray!.sublist(imgStart, imgEndWithSig);
    if (rawBytes.length < 2) return null;

    return rawBytes;
  }

  bool get hasJpegPhoto {
    final b = getRawImageBytes();
    return b != null && b[0] == 0xFF && b[1] == 0xD8;
  }

  bool get hasJp2Photo {
    final b = getRawImageBytes();
    return b != null && b[0] == 0xFF && b[1] == 0x4F;
  }

  // Keep for compatibility
  Uint8List? getAadhaarPhotoBytes() => getRawImageBytes();

  void saveImage(String filepath) {
    final image = getAdharimage();
    if (image != null) File(filepath).writeAsBytesSync(img.encodePng(image));
  }
}
