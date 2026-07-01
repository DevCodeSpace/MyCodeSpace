// ignore_for_file: must_be_immutable, prefer_const_constructors, avoid_unnecessary_containers, prefer_interpolation_to_compose_strings, avoid_function_literals_in_foreach_calls, sized_box_for_whitespace, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:aadhar_demo_app/aadhar_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aadhar_demo_app/settings.dart' as stg;

class HomeScreen extends StatefulWidget {
  bool setfailimage = false;
  File? imagepath;
  AadharDataModel? aadharData;
  List<AadharDataModel> aadharDataList = const [];
  HomeScreen({super.key, this.aadharData, this.aadharDataList = const [], setfailimage = false, this.imagepath});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      getConfirmation();
    });
  }

  File? imagefile;
  ImagePicker imagePicker = ImagePicker();

  Future<void> getConfirmation() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(widget.aadharData == null ? "Selected Image" : "Is this correct details?"),
            content: widget.imagepath != null
                ? ClipRRect(child: Image.file(height: 150, width: 150, File(widget.imagepath?.path ?? "")))
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Image.asset("assets/lion.png", height: 50),
                                Spacer(),
                                Text('Government of India', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                Spacer(),
                                Image.asset("assets/aadhar-logo.png", height: 50),
                              ],
                            ),
                            SizedBox(height: 10),
                            Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  (widget.aadharData?.gender ?? "").toLowerCase().startsWith("f")
                                      ? Image.asset("assets/female.jpg", width: 100, fit: BoxFit.cover)
                                      : Image.asset("assets/avatar.jpg", width: 100, fit: BoxFit.cover),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Name :", style: TextStyle(fontWeight: FontWeight.w500)),
                                            Text(widget.aadharData?.name ?? ""),
                                          ],
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("DOB :", style: TextStyle(fontWeight: FontWeight.w500)),
                                            Text(widget.aadharData?.dob ?? ""),
                                          ],
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Gender :", style: TextStyle(fontWeight: FontWeight.w500)),
                                            Text((widget.aadharData?.gender ?? "") == "M" ? "Male" : "Female"),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Address :", style: TextStyle(fontWeight: FontWeight.w500)),
                                Text(
                                  (widget.aadharData?.location ?? "") +
                                      "," +
                                      (widget.aadharData?.landmark ?? "") +
                                      "," +
                                      (widget.aadharData?.district ?? "") +
                                      "," +
                                      (widget.aadharData?.state ?? "") +
                                      "-" +
                                      (widget.aadharData?.pincode ?? ""),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: (widget.aadharData?.aadhaarLast4Digit ?? "").isNotEmpty
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [Text("**** **** ${widget.aadharData?.aadhaarLast4Digit!}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: const [Text("**** **** ****", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))],
                                    ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          imagefile != null
                              ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(File(imagefile?.path ?? ""), height: 50, width: 50))
                              : SizedBox(),
                          // GestureDetector(
                          //   onTap: () async {
                          //     await getuploadimage();
                          //     setState(() {});
                          //   },
                          //   child: Container(
                          //     decoration: BoxDecoration(
                          //         border: Border.all(color: Colors.black)),
                          //     child: Center(
                          //       child: Text(
                          //         "Upload",
                          //         style: TextStyle(
                          //             fontWeight: FontWeight.bold,
                          //             fontSize: 20),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
            actions: [
              MaterialButton(
                color: const Color(0xff0200e0),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel", style: TextStyle(color: Colors.white)),
              ),
              MaterialButton(
                color: const Color(0xff0200e0),
                onPressed: () async {
                  if (widget.setfailimage || widget.imagepath != null) {
                    var testData = widget.aadharData;
                    testData?.ipAddress = "";
                    testData?.dateTime = "";
                    var isScanned = true;
                    if ((widget.aadharDataList.isNotEmpty && imagefile != null) || widget.imagepath != null) {
                      for (var i = 0; i < widget.aadharDataList.length; i++) {
                        var testDataFromList = widget.aadharDataList[i];
                        testDataFromList.ipAddress = "";
                        testDataFromList.dateTime = "";
                        if (testDataFromList == testData) {
                          isScanned = true;
                          break;
                        } else {
                          isScanned = false;
                        }
                      }
                      if (widget.aadharData == null) {
                        isScanned = false;
                      }
                      storeData();
                      if (!isScanned) {
                        storeDataInPref();
                      }
                    }
                    Navigator.pop(context);
                  } else {
                    await showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: Text("Alert"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Aadhaar Scanned successfully.", style: TextStyle(color: Colors.green, fontSize: 15)),
                                  widget.setfailimage == true
                                      ? SizedBox()
                                      : imagefile != null
                                      ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(width: 150, height: 150, File(imagefile?.path ?? '')))
                                      : SizedBox(),
                                  widget.setfailimage == true
                                      ? SizedBox()
                                      : MaterialButton(
                                          color: const Color(0xff0200e0),
                                          onPressed: () async {
                                            await getuploadimage();
                                            setState(() {});
                                          },
                                          child: Text("Select Image", style: TextStyle(color: Colors.white)),
                                        ),
                                ],
                              ),
                              actions: [
                                GestureDetector(
                                  onTap: () {
                                    imagefile == null
                                        ? showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text("Alert"),
                                                content: Text("Please select image", style: TextStyle(color: Colors.red)),
                                                actions: [
                                                  MaterialButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    color: Color(0xff0200e0),
                                                    child: Text("Ok", style: TextStyle(color: Colors.white)),
                                                  ),
                                                ],
                                              );
                                            },
                                          )
                                        : showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text("Are you sure?"),
                                                content: Text("Are you sure want to upload data?"),
                                                actions: [
                                                  MaterialButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    color: Color(0xff0200e0),
                                                    child: Text("No", style: TextStyle(color: Colors.white)),
                                                  ),
                                                  MaterialButton(
                                                    onPressed: () {
                                                      var testData = widget.aadharData;
                                                      testData?.ipAddress = "";
                                                      testData?.dateTime = "";
                                                      var isScanned = false;
                                                      if ((imagefile != null) || widget.imagepath != null) {
                                                        for (var i = 0; i < widget.aadharDataList.length; i++) {
                                                          var testDataFromList = widget.aadharDataList[i];
                                                          testDataFromList.ipAddress = "";
                                                          testDataFromList.dateTime = "";
                                                          if (testDataFromList == testData) {
                                                            isScanned = true;
                                                            break;
                                                          } else {
                                                            isScanned = false;
                                                          }
                                                        }
                                                        if (widget.aadharData == null) {
                                                          isScanned = false;
                                                        }
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                        storeData();
                                                        if (!isScanned) {
                                                          storeDataInPref();
                                                        }
                                                      }
                                                    },
                                                    color: Color(0xff0200e0),
                                                    child: Text("Yes", style: TextStyle(color: Colors.white)),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(color: Color(0xff0200e0), borderRadius: BorderRadius.circular(15)),
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Center(
                                        child: Text("Submit", style: TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  }
                  // Navigator.pop(context);
                },
                child: Text("Next", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> getuploadimage() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Select image"),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.close, size: 35),
                  ),
                ],
              ),
              content: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        XFile? selectcamera = await imagePicker.pickImage(source: ImageSource.camera, imageQuality: 80);
                        if (selectcamera != null) {
                          setState(() {
                            imagefile = File(selectcamera.path);
                          });
                        }
                        Navigator.pop(context);
                      },
                      child: ListTile(
                        leading: Icon(Icons.camera, size: 25),
                        title: Text("Camera", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                    ),
                    Divider(),
                    GestureDetector(
                      onTap: () async {
                        XFile? selectgallery = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                        if (selectgallery != null) {
                          imagefile = File(selectgallery.path);
                          setState(() {});
                        }
                        Navigator.pop(context);
                      },
                      child: ListTile(
                        leading: Icon(Icons.photo, size: 25),
                        title: Text("Gallery", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> storeDataInPref() async {
    var previous = stg.Settings.previousScanned;
    widget.aadharData ??= AadharDataModel();
    if (previous.isNotEmpty) {
      var json = jsonDecode(previous);
      List<AadharDataModel> prefData = [];
      for (var i = 0; i < json.length; i++) {
        prefData.add(AadharDataModel.fromJson(json[i]));
      }
      widget.aadharData?.profileimage = widget.imagepath != null ? widget.imagepath?.readAsBytesSync() ?? [] : imagefile?.readAsBytesSync() ?? [];
      widget.aadharData?.dateTime = DateTime.now().toString();
      widget.aadharData?.ipAddress = stg.Settings.ipAddress.toString();
      prefData.add(widget.aadharData ?? AadharDataModel());
      List<Map<String, dynamic>> jsonList = [];
      prefData.forEach((element) {
        jsonList.add(element.toJson());
      });
      stg.Settings.previousScanned = jsonEncode(jsonList);
    } else {
      List<Map<String, dynamic>> jsonList = [];
      widget.aadharData!.profileimage = widget.imagepath != null ? widget.imagepath?.readAsBytesSync() ?? [] : imagefile?.readAsBytesSync() ?? [];
      widget.aadharData?.dateTime = DateTime.now().toString();
      widget.aadharData?.ipAddress = stg.Settings.ipAddress.toString();
      jsonList.add(widget.aadharData!.toJson());
      stg.Settings.previousScanned = jsonEncode(jsonList);
    }
  }

  Future<void> storeData() async {
    try {
      var aadharPhoto = widget.imagepath != null ? base64Encode(widget.imagepath?.readAsBytesSync() ?? []) : base64Encode(imagefile?.readAsBytesSync() ?? []);
      var response = await http.post(
        Uri.parse("${stg.Settings.ipAddress}/saceApi/sadmin/newPreStudent/add"),
        body: jsonEncode({
          "name": widget.aadharData?.name ?? "Set by adhar image ",
          "mobileNo": "",
          "dateOfBirth": widget.aadharData?.dob ?? "10/10/2010",
          "uid": widget.aadharData?.referenceid ?? "Set by adhar image ",
          "address":
              (widget.aadharData?.location ?? "Set by adhar image ") +
              "," +
              (widget.aadharData?.landmark ?? "Set by adhar image ") +
              "," +
              (widget.aadharData?.district ?? "Set by adhar image ") +
              "," +
              (widget.aadharData?.state ?? "Set by adhar image ") +
              "-" +
              (widget.aadharData?.pincode ?? "Set by adhar image "),
          "gender": widget.aadharData?.gender ?? "Set by adhar image ",
          "city": widget.aadharData?.district ?? "Set by adhar image ",
          "district": widget.aadharData?.district ?? "Set by adhar image ",
          "pinCode": widget.aadharData?.pincode ?? "111111",
          "state": widget.aadharData?.state ?? "Set by adhar image ",
          "adharPhoto": aadharPhoto,
        }),
        headers: {"Content-Type": "application/json"},
      );
      print(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Success")));
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(elevation: 0, backgroundColor: const Color(0xff0200e0), centerTitle: true, title: Text("Result")),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: widget.aadharData == null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [Center(child: Image.file(widget.imagepath!))],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset("assets/lion.png", height: 50),
                                Spacer(),
                                Text('Government of India', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                Spacer(),
                                Image.asset("assets/aadhar-logo.png", height: 50),
                              ],
                            ),
                            SizedBox(height: 10),
                            Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  (widget.aadharData?.gender ?? "").toLowerCase().startsWith("f")
                                      ? Image.asset("assets/female.jpg", width: 100, fit: BoxFit.cover)
                                      : Image.asset("assets/avatar.jpg", width: 100, fit: BoxFit.cover),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Name :", style: TextStyle(fontWeight: FontWeight.w500)),
                                            Text(widget.aadharData?.name ?? ""),
                                          ],
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("DOB :", style: TextStyle(fontWeight: FontWeight.w500)),
                                            Text(widget.aadharData?.dob ?? ""),
                                          ],
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Gender :", style: TextStyle(fontWeight: FontWeight.w500)),
                                            Text((widget.aadharData?.gender ?? "") == "M" ? "Male" : "Female"),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Address :", style: TextStyle(fontWeight: FontWeight.w500)),
                                Text(
                                  (widget.aadharData?.location ?? "") +
                                      "," +
                                      (widget.aadharData?.landmark ?? "") +
                                      "," +
                                      (widget.aadharData?.district ?? "") +
                                      "," +
                                      (widget.aadharData?.state ?? "") +
                                      "-" +
                                      (widget.aadharData?.pincode ?? ""),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: (widget.aadharData?.aadhaarLast4Digit ?? "").isNotEmpty
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [Text("**** **** ${widget.aadharData?.aadhaarLast4Digit!}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: const [Text("**** **** ****", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
