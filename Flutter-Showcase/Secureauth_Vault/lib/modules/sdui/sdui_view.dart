import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stac/stac.dart';

class SduiView extends StatelessWidget {
  const SduiView({super.key, this.screenId = 'home'});

  final String screenId;

  Future<Map<String, dynamic>> _loadScreen() async {
    final snapshot = await FirebaseFirestore.instance.collection('screens').doc(screenId).get();

    if (!snapshot.exists) {
      throw Exception('Screen "$screenId" not found');
    }

    final data = snapshot.data();

    if (data == null) {
      throw Exception('Document data is null');
    }

    final config = data['config'];
    if (config == null) {
      throw Exception('Config field not found');
    }

    // Current Firestore structure:
    // config: "{...json...}"

    if (config is String) {
      return Map<String, dynamic>.from(jsonDecode(config));
    }

    // Future support if config becomes a Map
    if (config is Map) {
      return Map<String, dynamic>.from(config);
    }

    throw Exception('Unsupported config type: ${config.runtimeType}');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('SDUI Error')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(snapshot.error.toString(), textAlign: TextAlign.center),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text('No screen data found')));
        }

        try {
          return Stac.fromJson(snapshot.data, context) ?? const Scaffold(body: Center(child: Text('Failed to render screen')));
        } catch (e) {
          return Scaffold(
            appBar: AppBar(title: const Text('Render Error')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(e.toString(), textAlign: TextAlign.center),
              ),
            ),
          );
        }
      },
    );
  }
}
