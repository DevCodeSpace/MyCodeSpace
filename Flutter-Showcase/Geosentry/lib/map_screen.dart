import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geofencing_app/geofence_bottomsheet.dart';
import 'package:geofencing_app/geofence_model.dart';
import 'package:geofencing_app/geofence_service.dart';
import 'package:geofencing_app/theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Circle> _circles = {};
  final Set<Marker> _markers = {};
  bool _isAddingGeofence = false;
  StreamSubscription? _eventSub;
  GeofenceService? _service;

  static const CameraPosition _initialCamera = CameraPosition(target: LatLng(21.1702, 72.8311), zoom: 14.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initService());
  }

  void _initService() async {
    _service = context.read<GeofenceService>();
    await _service!.startMonitoring();
    _service!.addListener(_updateMapElements);
    _eventSub = _service!.eventStream.listen(_showEventSnackbar);
    _updateMapElements();
    final pos = _service!.currentPosition;
    if (pos != null && _mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 15));
    }
  }

  void _showEventSnackbar(GeofenceEvent event) {
    if (!mounted) return;
    final isEnter = event.type == GeofenceEventType.entered;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: (isEnter ? AppTheme.emerald : AppTheme.danger).withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(isEnter ? Icons.login_rounded : Icons.logout_rounded, color: isEnter ? AppTheme.emerald : AppTheme.danger, size: 14),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEnter ? 'Entered Zone' : 'Exited Zone',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(event.geofenceName, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
              ],
            ),
          ],
        ),
        backgroundColor: AppTheme.foreground,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _updateMapElements() {
    if (!mounted) return;
    final service = context.read<GeofenceService>();
    final newCircles = <Circle>{};
    final newMarkers = <Marker>{};

    for (final geofence in service.geofences) {
      final color = Color(geofence.color);
      newCircles.add(
        Circle(
          circleId: CircleId(geofence.id),
          center: LatLng(geofence.latitude, geofence.longitude),
          radius: geofence.radius,
          fillColor: color.withOpacity(geofence.isActive ? 0.12 : 0.04),
          strokeColor: geofence.isActive ? color : color.withOpacity(0.2),
          strokeWidth: 2,
        ),
      );
      newMarkers.add(
        Marker(
          markerId: MarkerId(geofence.id),
          position: LatLng(geofence.latitude, geofence.longitude),
          infoWindow: InfoWindow(title: geofence.name, snippet: '${geofence.radius.toInt()}m'),
          icon: BitmapDescriptor.defaultMarkerWithHue(HSLColor.fromColor(color).hue),
          onTap: () => _showGeofenceOptions(geofence),
        ),
      );
    }

    final pos = service.currentPosition;
    if (pos != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(pos.latitude, pos.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'You'),
          zIndex: 2,
        ),
      );
    }

    setState(() {
      _circles
        ..clear()
        ..addAll(newCircles);
      _markers
        ..clear()
        ..addAll(newMarkers);
    });
  }

  void _onMapTap(LatLng position) {
    if (_isAddingGeofence) {
      setState(() => _isAddingGeofence = false);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => GeofenceBottomSheet(
          position: position,
          onSave: (name, radius, description, color) async {
            await context.read<GeofenceService>().addGeofence(
              name: name,
              latitude: position.latitude,
              longitude: position.longitude,
              radius: radius,
              description: description,
              color: color,
            );
            _updateMapElements();
          },
        ),
      );
    }
  }

  void _showGeofenceOptions(GeofenceModel geofence) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => GeofenceOptionsSheet(
        geofence: geofence,
        onToggle: () async {
          await context.read<GeofenceService>().toggleGeofence(geofence.id);
          _updateMapElements();
        },
        onDelete: () async {
          await context.read<GeofenceService>().deleteGeofence(geofence.id);
          _updateMapElements();
        },
        onZoomTo: () => flyTo(geofence.latitude, geofence.longitude),
      ),
    );
  }

  void flyTo(double lat, double lng) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16));
  }

  void _goToCurrentLocation() {
    final pos = context.read<GeofenceService>().currentPosition;
    if (pos != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 15));
    }
  }

  @override
  void dispose() {
    _service?.removeListener(_updateMapElements);
    _eventSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GeofenceService>(
      builder: (context, service, _) {
        return Stack(
          children: [
            // ── Map ─────────────────────────────────────────────────────
            GoogleMap(
              initialCameraPosition: _initialCamera,
              circles: _circles,
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
                _setMapStyle(controller);
                final pos = service.currentPosition;
                if (pos != null) {
                  controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 15));
                } else {
                  void flyOnFirstFix() {
                    final p = service.currentPosition;
                    if (p != null) {
                      controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(p.latitude, p.longitude), 15));
                      service.removeListener(flyOnFirstFix);
                    }
                  }

                  service.addListener(flyOnFirstFix);
                }
              },
              onTap: _onMapTap,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
            ),

            // ── Top header card ─────────────────────────────────────────
            Positioned(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, child: _buildTopHeader(service)),

            // ── Search + Add Zone bar ───────────────────────────────────
            Positioned(top: MediaQuery.of(context).padding.top + 80, left: 16, right: 16, child: _buildSearchBar()),

            // ── Right-side FABs ─────────────────────────────────────────
            Positioned(right: 16, bottom: 220, child: _buildSideFabs(service)),

            // ── Bottom perimeter status card ────────────────────────────
            Positioned(bottom: 80, left: 16, right: 16, child: _buildStatusCard(service)),

            // ── Adding geofence hint ────────────────────────────────────
            if (_isAddingGeofence) Positioned(bottom: 160, left: 0, right: 0, child: Center(child: _buildAddHint())),
          ],
        );
      },
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _buildTopHeader(GeofenceService service) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.surface.withOpacity(0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              // Animated live indicator
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(gradient: AppTheme.emeraldGradient, shape: BoxShape.circle),
                child: const Icon(Icons.wifi_tethering_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(color: AppTheme.emerald, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          service.isMonitoring ? 'LIVE TRACKING' : 'PAUSED',
                          style: TextStyle(
                            color: service.isMonitoring ? AppTheme.emerald : AppTheme.mutedForeground,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.currentPosition != null
                          ? '${service.currentPosition!.latitude.toStringAsFixed(4)}, '
                                '${service.currentPosition!.longitude.toStringAsFixed(4)}'
                          : 'Acquiring location…',
                      style: const TextStyle(color: AppTheme.foreground, fontSize: 14, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Search bar ───────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.surface.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(Icons.search_rounded, color: AppTheme.mutedForeground, size: 18),
                    const SizedBox(width: 8),
                    const Text('Search places or zones', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => setState(() => _isAddingGeofence = !_isAddingGeofence),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: _isAddingGeofence ? null : AppTheme.primaryGradient,
              color: _isAddingGeofence ? AppTheme.danger : null,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: (_isAddingGeofence ? AppTheme.danger : AppTheme.primary).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Icon(_isAddingGeofence ? Icons.close_rounded : Icons.add_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  _isAddingGeofence ? 'Cancel' : 'Zone',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Side FABs ─────────────────────────────────────────────────────────────
  Widget _buildSideFabs(GeofenceService service) {
    return _SideFab(icon: Icons.my_location_rounded, onTap: _goToCurrentLocation);
  }

  // ── Perimeter status card ────────────────────────────────────────────────
  Widget _buildStatusCard(GeofenceService service) {
    final insideCount = service.geofences.where((g) => g.status == GeofenceStatus.inside).length;
    final allSecure = insideCount == 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 6))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, color: allSecure ? AppTheme.primary : AppTheme.warning, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'PERIMETER STATUS',
                        style: TextStyle(color: allSecure ? AppTheme.primary : AppTheme.warning, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // ── Tappable arrow opens distance sheet ──────────
                  GestureDetector(
                    onTap: () => _showDistanceSheet(service),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Icon(Icons.keyboard_arrow_up_rounded, color: AppTheme.primary, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          allSecure ? 'All zones secure' : '$insideCount zone active',
                          style: const TextStyle(color: AppTheme.foreground, fontSize: 22, fontWeight: FontWeight.w800, height: 1.1),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${service.activeGeofences.length} active · '
                          '${service.events.length} alerts today',
                          style: const TextStyle(color: AppTheme.mutedForeground, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Zone avatar stack — max 3 + overflow
                  if (service.geofences.isNotEmpty) _ZoneAvatarStack(geofences: service.geofences.toList()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Distance bottom sheet ─────────────────────────────────────────────────
  void _showDistanceSheet(GeofenceService service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DistanceSheet(service: service),
    );
  }

  Widget _buildAddHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_rounded, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            'Tap on the map to place a zone',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _setMapStyle(GoogleMapController controller) {
    controller.setMapStyle('''[
      {"elementType":"geometry","stylers":[{"color":"#e8f0fe"}]},
      {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
      {"elementType":"labels.text.fill","stylers":[{"color":"#5d646f"}]},
      {"elementType":"labels.text.stroke","stylers":[{"color":"#f8fafc"}]},
      {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#d0daea"}]},
      {"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},
      {"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#11161f"}]},
      {"featureType":"poi","stylers":[{"visibility":"off"}]},
      {"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
      {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a9bb0"}]},
      {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#f4f8ff"}]},
      {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#dce8ff"}]},
      {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#c5d8ff"}]},
      {"featureType":"road.local","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
      {"featureType":"transit.line","elementType":"geometry","stylers":[{"color":"#dce8ff"}]},
      {"featureType":"water","elementType":"geometry","stylers":[{"color":"#bbd8f5"}]},
      {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#7aabde"}]},
      {"featureType":"landscape","elementType":"geometry","stylers":[{"color":"#ebf3fc"}]},
      {"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#ddeeff"}]}
    ]''');
  }
}

class _SideFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SideFab({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 3))],
        ),
        child: Icon(icon, color: AppTheme.foreground, size: 18),
      ),
    );
  }
}

class _ZoneAvatarStack extends StatelessWidget {
  final List<GeofenceModel> geofences;
  const _ZoneAvatarStack({required this.geofences});

  @override
  Widget build(BuildContext context) {
    const maxVisible = 3;
    final visible = geofences.take(maxVisible).toList();
    final overflow = geofences.length - maxVisible;
    final totalItems = overflow > 0 ? maxVisible + 1 : visible.length;

    return SizedBox(
      width: totalItems * 24.0 + 14,
      height: 40,
      child: Stack(
        children: [
          ...List.generate(visible.length, (i) {
            final color = Color(geofences[i].color);
            return Positioned(
              left: i * 24.0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [color, color.withOpacity(0.75)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 15),
              ),
            );
          }),
          // +N overflow badge
          if (overflow > 0)
            Positioned(
              left: maxVisible * 24.0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surfaceVariant,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$overflow',
                    style: const TextStyle(color: AppTheme.mutedForeground, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Distance bottom sheet ─────────────────────────────────────────────────────
class _DistanceSheet extends StatelessWidget {
  final GeofenceService service;
  const _DistanceSheet({required this.service});

  String _formatDistance(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.toInt()} m';
  }

  @override
  Widget build(BuildContext context) {
    final pos = service.currentPosition;
    final geofences = service.geofences;

    // Sort by distance
    final sorted = pos == null ? geofences.toList() : [...geofences]
      ..sort((a, b) => a.distanceTo(pos?.latitude ?? 0, pos?.longitude ?? 0).compareTo(b.distanceTo(pos?.latitude ?? 0, pos?.longitude ?? 0)));

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: AppTheme.surfaceVariant, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.social_distance_rounded, color: AppTheme.primary, size: 18),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zone Distances',
                    style: TextStyle(color: AppTheme.foreground, fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  Text('Your distance from each zone', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (pos == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('Acquiring your location…', style: TextStyle(color: AppTheme.mutedForeground)),
              ),
            )
          else if (geofences.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No zones added yet', style: TextStyle(color: AppTheme.mutedForeground)),
              ),
            )
          else
            ...sorted.map((geofence) {
              final distance = geofence.distanceTo(pos.latitude, pos.longitude);
              final isInside = distance <= geofence.radius;
              final color = Color(geofence.color);
              final progress = isInside ? 1.0 : (geofence.radius / distance).clamp(0.0, 1.0);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isInside ? color.withOpacity(0.4) : AppTheme.border, width: isInside ? 1.5 : 1),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [color, color.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      ),
                      child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  geofence.name,
                                  style: const TextStyle(color: AppTheme.foreground, fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: (isInside ? AppTheme.emerald : AppTheme.primary).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  isInside ? 'Inside' : _formatDistance(distance),
                                  style: TextStyle(color: isInside ? AppTheme.emerald : AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppTheme.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isInside ? 'You are inside this zone' : '${_formatDistance(geofence.radius)} radius · ${_formatDistance(distance - geofence.radius)} to boundary',
                            style: const TextStyle(color: AppTheme.mutedForeground, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
