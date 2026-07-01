// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:aadhar_demo_app/settings.dart';

import 'aadhar_model.dart';

class RecentScreen extends StatefulWidget {
  const RecentScreen({super.key});

  @override
  State<RecentScreen> createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  List<AadharDataModel> aadharData = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPrefData();
  }

  Future<void> getPrefData() async {
    var previous = Settings.previousScanned;
    if (previous.isNotEmpty) {
      var json = jsonDecode(previous);
      for (var i = 0; i < json.length; i++) {
        aadharData.add(AadharDataModel.fromJson(json[i]));
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xff0200e0), elevation: 0, title: const Text("Recent Scan")),
      body: aadharData.isEmpty
          ? const Center(child: Text("No recent scan"))
          : ListView.builder(
              itemCount: aadharData.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: aadharData[i].gender == null
                      ? SizedBox(height: MediaQuery.of(context).size.height / 3, child: Image.memory(Uint8List.fromList(aadharData[i].profileimage)))
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                                    (aadharData[i].gender ?? "").toLowerCase().startsWith("f")
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
                                              const Text("Name :", style: TextStyle(fontWeight: FontWeight.w500)),
                                              Text(aadharData[i].name ?? ""),
                                            ],
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("DOB :", style: TextStyle(fontWeight: FontWeight.w500)),
                                              Text(aadharData[i].dob ?? ""),
                                            ],
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text("Gender :", style: TextStyle(fontWeight: FontWeight.w500)),
                                              Text((aadharData[i].gender ?? "") == "M" ? "Male" : "Female"),
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
                                  const Text("Address :", style: TextStyle(fontWeight: FontWeight.w500)),
                                  Text(
                                    "${aadharData[i].location ?? ""},${aadharData[i].landmark ?? ""},${aadharData[i].district ?? ""},${aadharData[i].state ?? ""}-${aadharData[i].pincode ?? ""}",
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: (aadharData[i].aadhaarLast4Digit ?? "").isNotEmpty
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [Text("**** **** ${aadharData[i].aadhaarLast4Digit!}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))],
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
                );
              },
            ),
    );
  }
}
