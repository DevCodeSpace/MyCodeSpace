import 'package:flutter/material.dart';
import 'package:geofencing_app/edit_geofence_sheet.dart';
import 'package:geofencing_app/geofence_model.dart';
import 'package:geofencing_app/geofence_service.dart';
import 'package:geofencing_app/theme.dart';
import 'package:provider/provider.dart';

class ZonesScreen extends StatelessWidget {
  final void Function(double lat, double lng)? onLocate;
  const ZonesScreen({super.key, this.onLocate});

  @override
  Widget build(BuildContext context) {
    return Consumer<GeofenceService>(
      builder: (context, service, _) {
        return Container(
          decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Fixed header + stats (not scrollable) ────────────────
              Padding(padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 0), child: _buildHeader(context, service)),
              Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 0), child: _buildStats(service)),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    const Text(
                      'All Zones',
                      style: TextStyle(color: AppTheme.foreground, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              // ── Only zone list scrolls ────────────────────────────────
              Expanded(
                child: service.geofences.isEmpty
                    ? const _EmptyView()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: service.geofences.length,
                        itemBuilder: (ctx, i) => _ZoneCard(geofence: service.geofences[i], onLocate: onLocate),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, GeofenceService service) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GEOFENCES',
                style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your Zones',
                style: TextStyle(color: AppTheme.foreground, fontSize: 30, fontWeight: FontWeight.w800, height: 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats(GeofenceService service) {
    final weekEvents = service.events.where((e) => DateTime.now().difference(e.timestamp).inDays < 7).length;

    return Row(
      children: [
        _StatTile(tag: 'ACTIVE', value: '${service.activeGeofences.length}', sub: 'of ${service.geofences.length}', color: AppTheme.emerald),
        const SizedBox(width: 10),
        _StatTile(tag: 'EVENTS', value: '$weekEvents', sub: 'this week', color: AppTheme.primary),
      ],
    );
  }
}

// ── Stat tile ─────────────────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final String tag;
  final String value;
  final String sub;
  final Color color;
  const _StatTile({required this.tag, required this.value, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up_rounded, size: 12, color: color),
                const SizedBox(width: 4),
                Text(
                  tag,
                  style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.6),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(color: AppTheme.foreground, fontSize: 30, fontWeight: FontWeight.w800, height: 1),
            ),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(color: AppTheme.mutedForeground, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ── Zone card ─────────────────────────────────────────────────────────────────
class _ZoneCard extends StatelessWidget {
  final GeofenceModel geofence;
  final void Function(double lat, double lng)? onLocate;
  const _ZoneCard({required this.geofence, this.onLocate});

  @override
  Widget build(BuildContext context) {
    final color = Color(geofence.color);
    final isInside = geofence.status == GeofenceStatus.inside;
    final eventCount = context.read<GeofenceService>().events.where((e) => e.geofenceId == geofence.id).length;

    return GestureDetector(
      onTap: () => _showViewSheet(context, eventCount),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Mini map thumbnail
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(58, 58),
                          painter: _MiniMapPainter(color: color),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: color, width: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              geofence.name,
                              style: const TextStyle(color: AppTheme.foreground, fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 8),
                            _StatusBadge(isActive: isInside),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _InfoChip(label: '${geofence.radius.toInt()}m radius'),
                            const SizedBox(width: 8),
                            _InfoChip(icon: Icons.timeline_rounded, label: '$eventCount events'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.85,
                    child: Switch.adaptive(
                      value: geofence.isActive,
                      // Green active color
                      activeThumbColor: AppTheme.emerald,
                      activeTrackColor: AppTheme.emerald.withValues(alpha: 0.1),
                      onChanged: (_) => context.read<GeofenceService>().toggleGeofence(geofence.id),
                    ),
                  ),
                ],
              ),
            ),
            // Action row
            Container(
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                border: const Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  _ActionBtn(
                    icon: Icons.my_location_rounded,
                    label: 'Locate',
                    onTap: () {
                      if (onLocate != null) {
                        onLocate!(geofence.latitude, geofence.longitude);
                      }
                    },
                  ),
                  Container(width: 1, height: 20, color: AppTheme.border),
                  _ActionBtn(
                    icon: Icons.edit_rounded,
                    label: 'Edit',
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => EditGeofenceSheet(geofence: geofence, onSave: (updated) => context.read<GeofenceService>().updateGeofence(updated)),
                    ),
                  ),
                  Container(width: 1, height: 20, color: AppTheme.border),
                  _ActionBtn(icon: Icons.delete_outline_rounded, label: 'Delete', color: AppTheme.danger, onTap: () => _confirmDelete(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── View-only bottom sheet ────────────────────────────────────────────────
  void _showViewSheet(BuildContext context, int eventCount) {
    final color = Color(geofence.color);
    final isInside = geofence.status == GeofenceStatus.inside;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: AppTheme.surfaceVariant, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Zone header
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [color, color.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        geofence.name,
                        style: const TextStyle(color: AppTheme.foreground, fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      _StatusBadge(isActive: isInside),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: geofence.isActive,
                  activeThumbColor: AppTheme.emerald,
                  activeTrackColor: AppTheme.emerald.withValues(alpha: 0.1),
                  onChanged: (_) => context.read<GeofenceService>().toggleGeofence(geofence.id),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Details grid
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  _DetailRow(icon: Icons.radio_button_unchecked_rounded, label: 'Radius', value: '${geofence.radius.toInt()} meters', color: color),
                  Divider(height: 1, color: AppTheme.border),
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Coordinates',
                    value: '${geofence.latitude.toStringAsFixed(5)}, ${geofence.longitude.toStringAsFixed(5)}',
                    color: color,
                  ),
                  Divider(height: 1, color: AppTheme.border),
                  _DetailRow(icon: Icons.timeline_rounded, label: 'Total Events', value: '$eventCount events triggered', color: color),
                  Divider(height: 1, color: AppTheme.border),
                  _DetailRow(icon: Icons.calendar_today_rounded, label: 'Created', value: _formatDate(geofence.createdAt), color: color),
                  if (geofence.description != null) ...[
                    Divider(height: 1, color: AppTheme.border),
                    _DetailRow(icon: Icons.notes_rounded, label: 'Description', value: geofence.description!, color: color),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Area name from reverse geocoding
            if (geofence.areaName != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color.withOpacity(0.1), color.withOpacity(0.03)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.location_city_rounded, color: color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Zone Area',
                            style: TextStyle(color: AppTheme.mutedForeground, fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            geofence.areaName!,
                            style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.verified_rounded, color: color.withOpacity(0.5), size: 16),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month]} ${d.day}, ${d.year}';
  }

  void _showMoreMenu(BuildContext context) {}

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Zone'),
        content: Text('Delete "${geofence.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GeofenceService>().deleteGeofence(geofence.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Detail row for view sheet ─────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _DetailRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(color: AppTheme.mutedForeground, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(color: AppTheme.foreground, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.emerald : AppTheme.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Inside' : 'Outside',
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  const _InfoChip({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppTheme.surfaceVariant, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 11, color: AppTheme.mutedForeground), const SizedBox(width: 3)],
          Text(
            label,
            style: const TextStyle(color: AppTheme.mutedForeground, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.mutedForeground;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: c),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  final Color color;
  const _MiniMapPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.15)
      ..strokeWidth = 1;
    for (double i = 0; i <= size.width; i += size.width / 3) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += size.height / 3) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    final diagPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.65), diagPaint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.3), diagPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: RadialGradient(colors: [AppTheme.primary.withOpacity(0.15), AppTheme.primary.withOpacity(0.03)]),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add_location_alt_rounded, color: AppTheme.primary, size: 44),
        ),
        const SizedBox(height: 20),
        const Text(
          'No Zones Yet',
          style: TextStyle(color: AppTheme.foreground, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          'Go to the Map tab and tap "+ Zone"\nto create your first geofence',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.mutedForeground, fontSize: 13, height: 1.5),
        ),
      ],
    ),
  );
}
