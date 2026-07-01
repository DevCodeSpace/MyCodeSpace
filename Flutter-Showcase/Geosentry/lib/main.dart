import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geofencing_app/events_screen.dart';
import 'package:geofencing_app/geofence_service.dart';
import 'package:geofencing_app/map_screen.dart';
import 'package:geofencing_app/theme.dart';
import 'package:geofencing_app/zones_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(ChangeNotifierProvider(create: (_) => GeofenceService(), child: const GeofenceApp()));
}

class GeofenceApp extends StatelessWidget {
  const GeofenceApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'GeoGuard', theme: AppTheme.lightTheme, debugShowCheckedModeBanner: false, home: const HomeShell());
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  final GlobalKey<MapScreenState> _mapKey = GlobalKey<MapScreenState>();

  void _locateOnMap(double lat, double lng) {
    setState(() => _currentIndex = 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapKey.currentState?.flyTo(lat, lng);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [MapScreen(key: _mapKey), ZonesScreen(onLocate: _locateOnMap), const EventsScreen()];

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: _NavBar(currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i), service: context.watch<GeofenceService>()),
    );
  }
}

class _NavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final GeofenceService service;

  const _NavBar({required this.currentIndex, required this.onTap, required this.service});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.map_outlined, activeIcon: Icons.map_rounded, label: 'Map'),
      _NavItem(icon: Icons.layers_outlined, activeIcon: Icons.layers_rounded, label: 'Zones', badge: service.geofences.length),
      _NavItem(icon: Icons.timeline_outlined, activeIcon: Icons.timeline_rounded, label: 'Activity', badge: service.events.length),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(top: BorderSide(color: AppTheme.border, width: 1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Active pill with gradient
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(24)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(item.activeIcon, color: Colors.white, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  item.label,
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          )
                        else
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(item.icon, color: AppTheme.mutedForeground, size: 22),
                              if (item.badge > 0)
                                Positioned(
                                  top: -4,
                                  right: -6,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                                    child: Text(
                                      item.badge > 9 ? '9+' : '${item.badge}',
                                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        if (!isActive) ...[
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            style: const TextStyle(color: AppTheme.mutedForeground, fontSize: 10, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badge;
  const _NavItem({required this.icon, required this.activeIcon, required this.label, this.badge = 0});
}
