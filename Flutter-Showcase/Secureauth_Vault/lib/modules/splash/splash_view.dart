import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stac/stac.dart';

import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('screens').doc('splash').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final config = data['config'];
        final json = config is String ? jsonDecode(config) : config;
        return KeyedSubtree(
          key: ValueKey(json.toString()),
          child: Stac.fromJson(Map<String, dynamic>.from(json), context) ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
