// ignore_for_file: avoid_print, use_build_context_synchronously, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as ml;
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:aadhar_demo_app/py_con.dart';
import 'package:aadhar_demo_app/recent_screen.dart';
import 'package:aadhar_demo_app/settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:get/get.dart';

import 'aadhar_model.dart';
import 'home_screen.dart';
import 'demo_screen.dart';
import 'sheet_controller.dart';

import 'package:http/http.dart' as http;

enum SampleItem { ipChange }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Settings.init();
  Get.put(SheetController(), permanent: true);
  runApp(const GetMaterialApp(debugShowCheckedModeBanner: false, title: 'Aadhaar Demo', home: DemoScreen()));
  // runApp(const MaterialApp(title: 'Marvel Soft', home: MyHome()));
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  TextEditingController ipController = TextEditingController();
  QRViewController? controller;
  var errorMessage = "";
  String? result;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  File? imagefile;
  ImagePicker imagePicker = ImagePicker();
  var isFlashOn = false;
  var isPlaying = true;
  List<AadharDataModel> aadharData = [];
  var aadhaarShow = false;
  int settimer = 15;
  Timer? timer;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      showIPDialog(true);
      getPrefData();
    });
    super.initState();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (settimer == 0) {
        settimer = 15;

        setState(() {});

        debugPrint('Timer Open Dialog');
        timer.cancel();
        if (aadhaarShow) {
          aadhaarShow = false;
          setdialog();
        }
      } else {
        setState(() {
          settimer--;
        });
      }
      debugPrint('Timer Value $settimer');
    });
  }

  bool validateNumber(String str) {
    if (str == null) {
      return false;
    }
    return int.tryParse(str) != null;
  }

  bool validateIPAddress(String ip) {
    int i, num, dots = 0;
    List<String> parts;
    if (ip == null) {
      return false;
    }
    parts = ip.split('.');
    if (parts.length != 4) {
      return false;
    }
    for (i = 0; i < parts.length; i++) {
      if (!validateNumber(parts[i])) {
        return false;
      }
      num = int.parse(parts[i]);
      if (num < 0 || num > 255) {
        return false;
      }
      if (i < parts.length - 1) {
        dots++;
      }
    }

    if (dots != 3) {
      return false;
    }
    return true;
  }

  Future<void> getuploadimage() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Select image"),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.close, size: 35),
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
                      child: const ListTile(
                        leading: Icon(Icons.camera, size: 25),
                        title: Text("Camera", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                    ),
                    const Divider(),
                    GestureDetector(
                      onTap: () async {
                        XFile? selectgallery = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                        if (selectgallery != null) {
                          imagefile = File(selectgallery.path);
                          setState(() {});
                        }
                        Navigator.pop(context);
                      },
                      child: const ListTile(
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

  void showIPDialog(shouldCheck) {
    if (Settings.ipAddress.isEmpty || !shouldCheck) {
      ipController.text = Settings.ipAddress ?? "";
      showDialog(
        barrierDismissible: !shouldCheck,
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, dialogState) {
            return AlertDialog(
              title: const Text("Set Domain/IP Address"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: ipController),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
                    ),
                  MaterialButton(
                    color: Colors.blue,
                    onPressed: () async {
                      if (ipController.text.isNotEmpty) {
                        var isValidIP = false;
                        try {
                          var url = Uri.parse("${ipController.text}/saceApi/sadmin/status/check");
                          var response = await http.get(url);
                          if (response.statusCode == 200 || response.statusCode == 201) {
                            isValidIP = true;
                          } else {
                            isValidIP = false;
                          }
                        } catch (e) {
                          isValidIP = false;
                        }
                        dialogState(() {});
                        // String input = ipController.text;
                        // bool containsCharacters = RegExp(r'[a-zA-Z]').hasMatch(input);
                        // if(!containsCharacters) {
                        //   isValidIP = validateIPAddress(ipController.text);
                        //   if(isValidIP){
                        //     try{
                        //       var response = await http.get(Uri.parse("http://${ipController.text}"));
                        //       if(response.statusCode == 200 || response.statusCode == 201){
                        //         isValidIP = true;
                        //       }else{
                        //         isValidIP = false;
                        //       }
                        //     }catch(e){
                        //       print(e.toString());
                        //       isValidIP = false;
                        //     }
                        //   }
                        // }
                        // else{
                        //  try{
                        //    if(!ipController.text.startsWith("http") || !(ipController.text.startsWith("https"))){
                        //     if(!ipController.text.startsWith("www")){
                        //       ipController.text = "https://www.${ipController.text}";
                        //     }else{
                        //       if(!ipController.text.contains("www")){
                        //         if(ipController.text.startsWith("http")){
                        //           if(ipController.text.contains("://")){
                        //             ipController.text.replaceAll("http://", "http://www.");
                        //           }else{
                        //             ipController.text.replaceAll("http", "http://www.");
                        //           }
                        //         } else{
                        //           if(ipController.text.contains("://")){
                        //             ipController.text.replaceAll("https://", "http://www.");
                        //           }else{
                        //             ipController.text.replaceAll("https", "http://www.");
                        //           }
                        //         }
                        //       }else {
                        //         if (!ipController.text.contains("://")) {
                        //           if (ipController.text.startsWith(
                        //               "http")) {
                        //             ipController.text.replaceAll(
                        //                 "http", "http://");
                        //           } else if(ipController.text.startsWith(
                        //               "https")){
                        //             ipController.text.replaceAll(
                        //                 "https", "http://");
                        //           }else{
                        //             ipController.text = "https://${ipController.text}";
                        //           }
                        //         }
                        //       }
                        //     }
                        //    }
                        //    var url = Uri.parse(ipController.text);
                        //    var response = await http.get(url);
                        //    if(response.statusCode == 200 || response.statusCode == 201){
                        //      isValidIP = true;
                        //    }else{
                        //      isValidIP = false;
                        //    }
                        //  }catch(e){
                        //    isValidIP = false;
                        //  }
                        // }
                        if (isValidIP) {
                          Settings.ipAddress = ipController.text;
                          ipController.clear();
                          Navigator.pop(context);
                          errorMessage = "";
                        } else {
                          errorMessage = "Unable to connect";
                        }
                        dialogState(() {});
                      }
                    },
                    child: const Text("Set", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400) ? 150.0 : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(borderColor: const Color(0xff0200e0), borderRadius: 10, borderLength: 30, borderWidth: 10, cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      result = scanData.code ?? "";
      this.controller?.stopCamera();
      final regex = RegExp(r'[a-zA-Z]');
      var isOldAadhar = regex.hasMatch(result ?? "");
      if (scanData != null) timer?.cancel();

      /// Here changes
      await getAdharDetails(isOldAadhar);
    });
  }

  Future<Future<dynamic>> setdialog() async {
    //  Navigator.pop(context);
    imagefile = null;
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(imagefile != null ? "Upload Image" : "Alert"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  imagefile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(height: 200, width: 200, child: Image.file(File(imagefile?.path ?? ""), fit: BoxFit.cover)),
                        )
                      : const Text("Unfortunately we can't scan your aadhaar information, please upload the image of your aadhaar to process the information"),
                  const SizedBox(height: 10),
                ],
              ),
              actions: [
                GestureDetector(
                  onTap: () async {
                    await getuploadimage();
                    setState(() {});
                  },
                  child: Container(
                    decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Upload image ", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
                if (imagefile != null)
                  GestureDetector(
                    onTap: () async {
                      aadhaarShow = false;
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(imagepath: imagefile)));
                      imagefile = null;
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Submit", style: TextStyle(color: Colors.white)),
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

  Future<void> getAdharDetails(isOldAadhar) async {
    if (!isOldAadhar) {
      if (result!.length > 20) {
        final aadhaarSecureQr = AadhaarSecureQr(result);
        final decodedData = aadhaarSecureQr.decodedData();
        print(decodedData);
        var aadhaarData = AadharDataModel.fromJson(decodedData!);
        aadhaarShow = false;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(aadharData: aadhaarData, aadharDataList: aadharData),
          ),
        );
        getPrefData();
        await controller?.pauseCamera();
        await controller?.resumeCamera();
        setState(() {});
      } else {
        await controller?.resumeCamera();
      }
    } else {
      final XmlDocument xml = XmlDocument.parse(result!);
      final uid = xml.rootElement.getAttribute('uid');
      final name = xml.rootElement.getAttribute('name');
      final gender = xml.rootElement.getAttribute('gender');
      final lm = xml.rootElement.getAttribute('lm');
      final loc = xml.rootElement.getAttribute('loc');
      final vtc = xml.rootElement.getAttribute('vtc');
      final po = xml.rootElement.getAttribute('po');
      final dist = xml.rootElement.getAttribute('dist');
      final state = xml.rootElement.getAttribute('state');
      final pc = xml.rootElement.getAttribute('pc');
      final dob = xml.rootElement.getAttribute('dob') ?? xml.rootElement.getAttribute('yob');
      final aadhaarData = AadharDataModel(
        referenceid: uid,
        name: name,
        gender: gender,
        landmark: lm,
        location: loc,
        vtc: vtc,
        postoffice: po,
        district: dist,
        state: state,
        pincode: pc,
        dob: dob,
      );
      aadhaarShow = false;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(aadharData: aadhaarData, aadharDataList: aadharData),
        ),
      );
      getPrefData();
      await controller?.pauseCamera();
      await controller?.resumeCamera();
      setState(() {});
    }
  }

  Uint8List bigIntegerToByteArray(BigInt number) {
    final byteCount = (number.bitLength + 7) ~/ 8;
    final byteArray = Uint8List(byteCount);

    for (var i = 0; i < byteCount; i++) {
      byteArray[i] = number.toUnsigned(8).toInt();
      number = number >> 8;
    }

    return byteArray;
  }

  Uint8List decompressBytes(Uint8List compressedData) {
    try {
      final codec = ZLibDecoder();
      final decompressedBytes = codec.convert(compressedData);
      return Uint8List.fromList(decompressedBytes);
    } catch (e) {
      e.toString();
      return Uint8List(0);
    }
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('no Permission')));
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> getPrefData() async {
    var previous = Settings.previousScanned;
    if (previous.isNotEmpty) {
      aadharData = [];
      var json = jsonDecode(previous);
      for (var i = 0; i < json.length; i++) {
        aadharData.add(AadharDataModel.fromJson(json[i]));
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          // useDefaultSemanticsOrder: false,
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xff0200e0),
          elevation: 0,
          centerTitle: true,
          actions: [
            PopupMenuButton<SampleItem>(
              onSelected: (SampleItem item) {
                showIPDialog(false);
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[const PopupMenuItem<SampleItem>(value: SampleItem.ipChange, child: Text('Server Config'))],
            ),
          ],
          title: const Column(
            children: [
              Text("SchoolAdminCE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
              SizedBox(height: 4),
              Text("Upload Adhar data of Students", style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
            ],
          ),
        ),
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse("https://www.marvelsoft.co.in/"));
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.public, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              "https://www.marvelsoft.co.in/",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: Colors.blue[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse("mailto:support@marvelsoft.co.in"));
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mail, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              "support@marvelsoft.co.in",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: Colors.blue[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Padding(padding: const EdgeInsets.all(8.0), child: Image.asset("assets/app-logo.jpg")),
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: PopupMenuButton<SampleItem>(
                //     onSelected: (SampleItem item) {
                //       showIPDialog(false);
                //     },
                //     itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
                //       const PopupMenuItem<SampleItem>(
                //         value: SampleItem.ipChange,
                //         child: Text('Change IpAddress'),
                //       ),
                //
                //     ],
                //   ),
                // )
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              child: aadhaarShow
                  ? Stack(
                      children: <Widget>[
                        _buildQrView(context),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(500)),
                                  child: GestureDetector(
                                    onTap: () async {
                                      aadhaarShow = false;
                                      var image = await ImagePicker().pickImage(source: ImageSource.gallery);
                                      if (image != null) {
                                        final ml.InputImage inputImage;
                                        inputImage = ml.InputImage.fromFilePath(image.path);
                                        final List<ml.BarcodeFormat> formats = [ml.BarcodeFormat.all];
                                        final barcodeScanner = ml.BarcodeScanner(formats: formats);
                                        final List<ml.Barcode> barcodes = await barcodeScanner.processImage(inputImage);
                                        if (barcodes.isNotEmpty) {
                                          for (ml.Barcode barcode in barcodes) {
                                            final ml.BarcodeType type = barcode.type;
                                            final Rect boundingBox = barcode.boundingBox;
                                            final String? displayValue = barcode.displayValue;
                                            final String? rawValue = barcode.rawValue;
                                            print("Type :- $type");
                                            print("boundingBox :- $boundingBox");
                                            print("displayValue :- $displayValue");
                                            print("rawValue :- $rawValue");
                                            final regex = RegExp(r'[a-zA-Z]');
                                            var isOldAadhar = regex.hasMatch(barcode.rawValue ?? "");
                                            result = barcode.rawValue;
                                            getAdharDetails(isOldAadhar);
                                          }
                                        } else {
                                          imagefile = null;
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return StatefulBuilder(
                                                builder: (context, setState) {
                                                  return AlertDialog(
                                                    title: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        const Text("Upload Image"),
                                                        GestureDetector(
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            imagefile = null;
                                                          },
                                                          child: const Icon(Icons.close, size: 30),
                                                        ),
                                                      ],
                                                    ),
                                                    content: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        imagefile != null
                                                            ? ClipRRect(
                                                                borderRadius: BorderRadius.circular(15),
                                                                child: Image.file(File(imagefile?.path ?? ""), height: 150, width: 150),
                                                              )
                                                            : const Text(
                                                                "Your Barcode Scan is Fail",
                                                                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red, fontSize: 20),
                                                              ),
                                                        const SizedBox(height: 10),
                                                      ],
                                                    ),
                                                    actions: [
                                                      GestureDetector(
                                                        onTap: () async {
                                                          await getuploadimage();
                                                          setState(() {});
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                                                          child: const Padding(
                                                            padding: EdgeInsets.all(8.0),
                                                            child: Text("Upload ", style: TextStyle(fontSize: 20, color: Colors.white)),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      GestureDetector(
                                                        onTap: () async {
                                                          if (imagefile != null) {
                                                            await Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => HomeScreen(setfailimage: true, imagepath: imagefile, aadharDataList: aadharData),
                                                              ),
                                                            );
                                                            Navigator.pop(context);
                                                          }
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                                                          child: const Padding(
                                                            padding: EdgeInsets.all(8.0),
                                                            child: Text("Submit", style: TextStyle(fontSize: 20, color: Colors.white)),
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
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                                      child: Text(
                                        "Upload from gallery",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(500)),
                                      child: IconButton(
                                        onPressed: () async {
                                          await controller?.toggleFlash();
                                          isFlashOn = await controller?.getFlashStatus() ?? false;
                                          setState(() {});
                                        },
                                        icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off, color: Colors.white, size: 30),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(500)),
                                      child: IconButton(
                                        onPressed: () async {
                                          await controller?.flipCamera();
                                          setState(() {});
                                        },
                                        icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white, size: 30),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(500)),
                                      child: IconButton(
                                        onPressed: () async {
                                          if (isPlaying) {
                                            await controller?.pauseCamera();
                                          } else {
                                            await controller?.resumeCamera();
                                          }
                                          isPlaying = !isPlaying;
                                          setState(() {});
                                        },
                                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 30),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        children: [
                          SizedBox(width: MediaQuery.of(context).size.width - 80, height: MediaQuery.of(context).size.height / 3, child: Lottie.asset("assets/scan.json")),
                          GestureDetector(
                            onTap: () {
                              aadhaarShow = true;
                              startTimer();
                              setState(() {});
                            },
                            child: Container(
                              decoration: BoxDecoration(color: const Color(0xff0200e0), borderRadius: BorderRadius.circular(12)),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                                child: Text("Scan Aadhaar Card", style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Recent Scan"),
                            TextButton(
                              onPressed: () {
                                aadhaarShow = false;
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const RecentScreen()));
                              },
                              child: const Text("See More"),
                            ),
                          ],
                        ),
                      ),
                      aadharData.isEmpty
                          ? const Center(
                              child: Padding(padding: EdgeInsets.only(top: 8.0), child: Text("No recent scan")),
                            )
                          : ListView.builder(
                              itemCount: aadharData.length,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, i) {
                                return aadharData[i].gender == null
                                    ? Container(height: 0)
                                    : Padding(
                                        padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
                                        child: Container(
                                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              if (aadharData[i].name != null) Text(aadharData[i].name ?? ""),
                                              if (aadharData[i].dateTime != null) Text(aadharData[i].dateTime ?? ""),
                                              if (aadharData[i].ipAddress != null) Text(aadharData[i].ipAddress ?? ""),
                                            ],
                                          ),
                                        ),
                                      );
                              },
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
