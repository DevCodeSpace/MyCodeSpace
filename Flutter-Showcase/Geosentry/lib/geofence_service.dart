import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geofencing_app/geofence_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class GeofenceService extends ChangeNotifier {
  static const String _geofencesKey = 'geofences';
  static const String _eventsKey = 'geofence_events';

  final List<GeofenceModel> _geofences = [];
  final List<GeofenceEvent> _events = [];
  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  bool _isMonitoring = false;
  bool _isLoading = false;
  String? _error;

  final _eventController = StreamController<GeofenceEvent>.broadcast();

  List<GeofenceModel> get geofences => List.unmodifiable(_geofences);
  List<GeofenceEvent> get events =>
      List.unmodifiable(_events.reversed.toList());
  Position? get currentPosition => _currentPosition;
  bool get isMonitoring => _isMonitoring;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Stream<GeofenceEvent> get eventStream => _eventController.stream;
  List<GeofenceModel> get activeGeofences =>
      _geofences.where((g) => g.isActive).toList();

  GeofenceService() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    await _loadData();
    // Auto-fetch area names for any zones missing them (runs silently in bg)
    _refreshAreaNamesBackground();
    _isLoading = false;
    notifyListeners();
  }

  /// Runs reverse geocoding in background without blocking UI
  void _refreshAreaNamesBackground() {
    refreshAreaNames();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final geofencesJson = prefs.getStringList(_geofencesKey) ?? [];
    _geofences.clear();
    for (final json in geofencesJson) {
      try {
        _geofences.add(GeofenceModel.fromJson(jsonDecode(json)));
      } catch (_) {}
    }
    final eventsJson = prefs.getStringList(_eventsKey) ?? [];
    _events.clear();
    for (final json in eventsJson) {
      try {
        _events.add(GeofenceEvent.fromJson(jsonDecode(json)));
      } catch (_) {}
    }
  }

  Future<void> _saveGeofences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _geofencesKey,
      _geofences.map((g) => jsonEncode(g.toJson())).toList(),
    );
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = _events.length > 200
        ? _events.sublist(_events.length - 200)
        : _events;
    await prefs.setStringList(
      _eventsKey,
      trimmed.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  // ── Reverse geocoding ─────────────────────────────────────────────────────
  /// Returns a human-readable area name like "Adajan Patiya, Surat"
  /// Priority: subLocality → locality → thoroughfare → administrativeArea
  Future<String?> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;

      // Build a meaningful short address
      final parts = <String>[];
      if (p.subLocality != null && p.subLocality!.isNotEmpty) {
        parts.add(p.subLocality!);
      }
      if (p.locality != null && p.locality!.isNotEmpty) {
        parts.add(p.locality!);
      } else if (p.thoroughfare != null && p.thoroughfare!.isNotEmpty) {
        parts.add(p.thoroughfare!);
      }
      if (p.administrativeArea != null &&
          p.administrativeArea!.isNotEmpty &&
          parts.length < 2) {
        parts.add(p.administrativeArea!);
      }

      return parts.isEmpty ? null : parts.join(', ');
    } catch (_) {
      return null;
    }
  }

  Future<bool> requestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _error = 'Location services are disabled.';
      notifyListeners();
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _error = 'Location permissions are denied.';
        notifyListeners();
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _error = 'Location permissions are permanently denied.';
      notifyListeners();
      return false;
    }
    _error = null;
    return true;
  }

  Future<void> startMonitoring() async {
    if (_isMonitoring) return;
    final hasPermission = await requestPermissions();
    if (!hasPermission) return;

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _checkGeofences(_currentPosition!);
    } catch (e) {
      _error = 'Failed to get location: $e';
    }

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(
      (position) {
        _currentPosition = position;
        _checkGeofences(position);
        notifyListeners();
      },
      onError: (e) {
        _error = 'Location stream error: $e';
        notifyListeners();
      },
    );

    _isMonitoring = true;
    notifyListeners();
  }

  Future<void> stopMonitoring() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _isMonitoring = false;
    notifyListeners();
  }

  void _checkGeofences(Position position) {
    for (int i = 0; i < _geofences.length; i++) {
      final geofence = _geofences[i];
      if (!geofence.isActive) continue;
      final isInside =
          geofence.containsPoint(position.latitude, position.longitude);
      final newStatus =
          isInside ? GeofenceStatus.inside : GeofenceStatus.outside;
      if (newStatus != geofence.status) {
        final event = GeofenceEvent(
          geofenceId: geofence.id,
          geofenceName: geofence.name,
          type: isInside ? GeofenceEventType.entered : GeofenceEventType.exited,
          timestamp: DateTime.now(),
          latitude: position.latitude,
          longitude: position.longitude,
        );
        _geofences[i] = geofence.copyWith(status: newStatus);
        _events.add(event);
        _eventController.add(event);
        _saveEvents();
        _saveGeofences();
        notifyListeners();
      }
    }
  }

  Future<GeofenceModel> addGeofence({
    required String name,
    required double latitude,
    required double longitude,
    required double radius,
    String? description,
    int color = 0xFF2196F3,
  }) async {
    // Reverse geocode to get real area name
    final areaName = await _reverseGeocode(latitude, longitude);

    final geofence = GeofenceModel(
      id: const Uuid().v4(),
      name: name,
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      createdAt: DateTime.now(),
      description: description,
      color: color,
      areaName: areaName,
    );

    _geofences.add(geofence);
    await _saveGeofences();
    notifyListeners();
    return geofence;
  }

  Future<void> updateGeofence(GeofenceModel geofence) async {
    final index = _geofences.indexWhere((g) => g.id == geofence.id);
    if (index != -1) {
      // Re-geocode if coordinates changed
      GeofenceModel updated = geofence;
      if (geofence.areaName == null ||
          geofence.latitude != _geofences[index].latitude ||
          geofence.longitude != _geofences[index].longitude) {
        final areaName =
            await _reverseGeocode(geofence.latitude, geofence.longitude);
        updated = geofence.copyWith(areaName: areaName);
      }
      _geofences[index] = updated;
      await _saveGeofences();
      notifyListeners();
    }
  }

  /// Re-fetches area names for all geofences that don't have one yet
  Future<void> refreshAreaNames() async {
    bool changed = false;
    for (int i = 0; i < _geofences.length; i++) {
      if (_geofences[i].areaName == null) {
        final area = await _reverseGeocode(
          _geofences[i].latitude,
          _geofences[i].longitude,
        );
        if (area != null) {
          _geofences[i] = _geofences[i].copyWith(areaName: area);
          changed = true;
        }
      }
    }
    if (changed) {
      await _saveGeofences();
      notifyListeners();
    }
  }

  Future<void> deleteGeofence(String id) async {
    _geofences.removeWhere((g) => g.id == id);
    await _saveGeofences();
    notifyListeners();
  }

  Future<void> toggleGeofence(String id) async {
    final index = _geofences.indexWhere((g) => g.id == id);
    if (index != -1) {
      _geofences[index] =
          _geofences[index].copyWith(isActive: !_geofences[index].isActive);
      await _saveGeofences();
      notifyListeners();
    }
  }

  Future<void> clearEvents() async {
    _events.clear();
    await _saveEvents();
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _eventController.close();
    super.dispose();
  }
}