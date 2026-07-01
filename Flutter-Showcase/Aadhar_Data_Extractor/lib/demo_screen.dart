// ignore_for_file: use_build_context_synchronously
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as ml;
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:xml/xml.dart';

import 'package:get/get.dart';

import 'aadhar_model.dart';
import 'py_con.dart';
import 'sheet_controller.dart';
import 'sheet_page.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isProcessing = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    ctrl.scannedDataStream.listen((scanData) async {
      if (isProcessing) return;
      isProcessing = true;
      ctrl.stopCamera();
      await _processQrData(scanData.code ?? "");
      isProcessing = false;
    });
  }

  Future<void> _pickFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    final inputImage = ml.InputImage.fromFilePath(image.path);
    final scanner = ml.BarcodeScanner(formats: [ml.BarcodeFormat.all]);
    final barcodes = await scanner.processImage(inputImage);
    await scanner.close();

    // Remove loading indicator
    if (mounted) Navigator.pop(context);

    if (barcodes.isNotEmpty) {
      await _processQrData(barcodes.first.rawValue ?? "");
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No QR code found in image'), behavior: SnackBarBehavior.floating));
      }
    }
  }

  Future<void> _processQrData(String raw) async {
    if (raw.isEmpty) return;
    try {
      AadharDataModel data;
      Uint8List? photoBytes;
      // XML QR hamesha '<' se start hota hai; numeric QR sirf digits hota hai
      final isXml = raw.trimLeft().startsWith('<');
      if (isXml) {
        final xml = XmlDocument.parse(raw);
        print("sagar: $xml");
        final root = xml.rootElement;
        final uid = root.getAttribute('uid') ?? '';
        data = AadharDataModel(
          referenceid: uid,
          name: root.getAttribute('name'),
          gender: root.getAttribute('gender'),
          dob: root.getAttribute('dob') ?? root.getAttribute('yob'),
          careof: root.getAttribute('co'),
          house: root.getAttribute('house'),
          street: root.getAttribute('street'),
          landmark: root.getAttribute('lm'),
          location: root.getAttribute('loc'),
          vtc: root.getAttribute('vtc'),
          postoffice: root.getAttribute('po'),
          subdistrict: root.getAttribute('subdist'),
          district: root.getAttribute('dist'),
          state: root.getAttribute('state'),
          pincode: root.getAttribute('pc'),
          aadhaarLast4Digit: uid.length >= 4 ? uid.substring(uid.length - 4) : uid,
        );
      } else {
        // Numeric Secure QR (V2/V5)
        final aadhaarSecureQr = AadhaarSecureQr(raw);
        data = AadharDataModel.fromJson(aadhaarSecureQr.decodedData()!);
        final rawImg = aadhaarSecureQr.getRawImageBytes();
        if (rawImg != null) {
          if (rawImg[0] == 0xFF && rawImg[1] == 0xD8) {
            // Standard JPEG — seedha use karo
            photoBytes = rawImg;
          } else if (rawImg[0] == 0xFF && rawImg[1] == 0x4F) {
            // JPEG 2000 — Android native channel se decode karo
            try {
              final result = await const MethodChannel('jp2_decoder').invokeMethod<Uint8List>('decodeJp2', rawImg);
              photoBytes = result;
            } catch (_) {
              photoBytes = null;
            }
          }
        }
      }
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DemoResultScreen(data: data, photoBytes: photoBytes),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not read Aadhaar QR: $e'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.redAccent));
      }
    } finally {
      await controller?.resumeCamera();
      isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanSize = MediaQuery.of(context).size.width * 0.7;
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Scan QR Code', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart_rounded),
            tooltip: 'Saved Entries',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SheetPage())),
          ),
        ],
      ),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(borderColor: Colors.blueAccent, borderRadius: 16, borderLength: 40, borderWidth: 10, cutOutSize: scanSize, overlayColor: Colors.black87),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_scanner, color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'Align the QR code within the frame to scan',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.photo_library_rounded),
                      label: const Text('Upload from Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DemoResultScreen extends StatelessWidget {
  final AadharDataModel data;
  final Uint8List? photoBytes;
  const DemoResultScreen({super.key, required this.data, this.photoBytes});

  @override
  Widget build(BuildContext context) {
    final isFemale = (data.gender ?? '').toLowerCase().startsWith('f');
    final address = [
      data.house,
      data.street,
      data.location,
      data.landmark,
      data.vtc,
      data.postoffice,
      data.district,
      data.state,
      data.pincode,
    ].where((e) => e != null && e.isNotEmpty).join(', ');

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        title: const Text('Verified Details', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Tap the card to view the back side",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            // The New Flip Card Widget
            _AadhaarFlipCard(data: data, isFemale: isFemale, address: address, photoBytes: photoBytes),
            const SizedBox(height: 32),
            const Text(
              "Raw Data Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _InfoTable(data: data),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                // onPressed: () => _showSubmitDialog(context),
                onPressed: () {
                  final ctrl = Get.find<SheetController>();
                  ctrl.addAadhaarEntry(data);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Entry saved successfully!!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
                },
                icon: const Icon(Icons.save_alt_rounded),
                label: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // void _showSubmitDialog(BuildContext context) {
  //   final ctrl = Get.find<SheetController>();
  //   final monthOptions = ctrl.getMonthOptions();
  //   String? selectedMonth;
  //   final remarkCtrl = TextEditingController();

  //   showDialog(
  //     context: context,
  //     builder: (ctx) => StatefulBuilder(
  //       builder: (ctx, setState) => AlertDialog(
  //         title: const Text('Sheet Entry', style: TextStyle(fontWeight: FontWeight.bold)),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text('Name: ${data.name ?? "-"}', style: const TextStyle(fontWeight: FontWeight.w500)),
  //             Text('Aadhaar: **** ${data.aadhaarLast4Digit ?? "****"}'),
  //             const SizedBox(height: 16),
  //             DropdownButtonFormField<String>(
  //               initialValue: selectedMonth,
  //               decoration: const InputDecoration(labelText: 'Select Month', border: OutlineInputBorder(), isDense: true),
  //               items: monthOptions.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
  //               onChanged: (v) => setState(() => selectedMonth = v),
  //             ),
  //             const SizedBox(height: 12),
  //             TextField(
  //               controller: remarkCtrl,
  //               decoration: const InputDecoration(labelText: 'Remark (optional)', border: OutlineInputBorder(), isDense: true),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
  //           ElevatedButton(
  //             onPressed: () {
  //               ctrl.addAadhaarEntry(data, month: selectedMonth, remark: remarkCtrl.text.trim().isEmpty ? null : remarkCtrl.text.trim());
  //               Navigator.pop(ctx);
  //               ScaffoldMessenger.of(
  //                 context,
  //               ).showSnackBar(const SnackBar(content: Text('Entry saved successfully!!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
  //             },
  //             style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white),
  //             child: const Text('Save'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );

  // }
}

/// FLIP CARD LOGIC
class _AadhaarFlipCard extends StatefulWidget {
  final AadharDataModel data;
  final bool isFemale;
  final String address;
  final Uint8List? photoBytes;

  const _AadhaarFlipCard({required this.data, required this.isFemale, required this.address, this.photoBytes});

  @override
  State<_AadhaarFlipCard> createState() => _AadhaarFlipCardState();
}

class _AadhaarFlipCardState extends State<_AadhaarFlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _animation = Tween<double>(begin: 0, end: math.pi).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _animation.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // perspective
          ..rotateY(_animation.value),
        child: _animation.value < math.pi / 2
            ? _buildFront()
            : Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(math.pi), // reverse content so it's not mirrored
                child: _buildBack(),
              ),
      ),
    );
  }

  // --- FRONT DESIGN ---
  Widget _buildFront() {
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  // child: Image.asset(
                  //   widget.isFemale ? 'assets/female.jpg' : 'assets/avatar.jpg',
                  //   width: 85,
                  //   height: 105,
                  //   fit: BoxFit.cover,
                  //   errorBuilder: (context, error, stackTrace) => Container(
                  //     width: 85,
                  //     height: 105,
                  //     color: Colors.grey.shade200,
                  //     child: const Icon(Icons.person, size: 50, color: Colors.grey),
                  //   ),
                  // ),
                  child: _buildPhoto(),
                ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   widget.data.name ?? 'Unknown Name',
                    //   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    // ),
                    _field('Name', widget.data.name ?? 'Unknown Name'),
                    // const SizedBox(height: 8),
                    _field('DOB / YOB', widget.data.dob),
                    _field(
                      'Gender',
                      widget.data.gender == 'M'
                          ? 'Male'
                          : widget.data.gender == 'F'
                          ? 'Female'
                          : widget.data.gender,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          const Divider(height: 20, thickness: 1),
          Center(
            child: Text(
              '**** **** ${widget.data.aadhaarLast4Digit ?? "****"}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 4, color: Colors.black87).copyWith(height: 1),
            ),
          ),
        ],
      ),
    );
  }

  // --- BACK DESIGN ---
  Widget _buildBack() {
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          const Text(
            'Address:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              widget.address,
              style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Divider(height: 24, thickness: 1),
          // Footer / Helpline mock
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.phone, size: 14, color: Colors.red.shade700),
                  const SizedBox(width: 4),
                  const Text('1947', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.email, size: 14, color: Colors.red.shade700),
                  const SizedBox(width: 4),
                  const Text('help@uidai.gov.in', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.language, size: 14, color: Colors.red.shade700),
                  const SizedBox(width: 4),
                  const Text('www.uidai.gov.in', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Shared Header for both Front and Back
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/lion.png', height: 35, errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_balance, color: Colors.grey)),

        Image.asset(
          'assets/bharat_gov.png',
          height: 30,
          errorBuilder: (context, error, stackTrace) => const Column(
            children: [
              Text('भारत सरकार', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text(
                'Government of India',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ],
          ),
        ),
        Image.asset('assets/aadhar-logo.png', height: 35, errorBuilder: (context, error, stackTrace) => const Icon(Icons.fingerprint, color: Colors.redAccent, size: 30)),
      ],
    );
  }

  Widget _buildPhoto() {
    const w = 85.0, h = 105.0;
    final fallback = Image.asset(
      widget.isFemale ? 'assets/female.jpg' : 'assets/avatar.jpg',
      width: w,
      height: h,
      fit: BoxFit.fill,
      errorBuilder: (_, _, _) => Container(
        width: w,
        height: h,
        color: Colors.grey.shade200,
        child: const Icon(Icons.person, size: 50, color: Colors.grey),
      ),
    );

    if (widget.photoBytes != null) {
      return Image.memory(widget.photoBytes!, width: w, height: h, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback);
    }
    return fallback;
  }

  Widget _field(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// Base Container for the Card to keep Front/Back sizing consistent
class _CardContainer extends StatelessWidget {
  final Widget child;
  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260, // Fixed height to maintain card aspect ratio
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _InfoTable extends StatelessWidget {
  final AadharDataModel data;
  const _InfoTable({required this.data});

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String?>>[
      MapEntry('Reference ID', data.referenceid),
      MapEntry('Name', data.name),
      MapEntry('Date of Birth', data.dob),
      MapEntry(
        'Gender',
        data.gender == 'M'
            ? 'Male'
            : data.gender == 'F'
            ? 'Female'
            : data.gender,
      ),
      MapEntry('Care Of', data.careof),
      MapEntry('House', data.house),
      MapEntry('Street', data.street),
      MapEntry('Location', data.location),
      MapEntry('Landmark', data.landmark),
      MapEntry('VTC', data.vtc),
      MapEntry('Post Office', data.postoffice),
      MapEntry('Sub District', data.subdistrict),
      MapEntry('District', data.district),
      MapEntry('State', data.state),
      MapEntry('Pincode', data.pincode),
    ].where((e) => e.value != null && e.value!.isNotEmpty).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: rows.map((e) {
            final isLast = e == rows.last;
            final isEven = rows.indexOf(e) % 2 == 0;
            return Container(
              color: isEven ? Colors.transparent : Colors.grey.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      e.key,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.blueGrey),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.value!,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
