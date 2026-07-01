import 'package:flutter/material.dart';
import 'package:geofencing_app/geofence_model.dart';
import 'package:geofencing_app/geofence_service.dart';
import 'package:geofencing_app/theme.dart';
import 'package:provider/provider.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});
  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  _Filter _filter = _Filter.all;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GeofenceService>(
      builder: (context, service, _) {
        // Apply filter + search
        final filtered = service.events.where((e) {
          final matchesFilter =
              _filter == _Filter.all || (_filter == _Filter.entries && e.type == GeofenceEventType.entered) || (_filter == _Filter.exits && e.type == GeofenceEventType.exited);
          final matchesSearch = _searchQuery.isEmpty || e.geofenceName.toLowerCase().contains(_searchQuery.toLowerCase());
          return matchesFilter && matchesSearch;
        }).toList();

        return Container(
          decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Fixed: header + search + filters ───────────────────
              Padding(padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 0), child: _buildHeader(service)),
              Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: _buildSearchBar()),
              Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 0), child: _buildFilterChips()),
              // ── Only events list scrolls ────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? const _EmptyEventsView()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final event = filtered[i];
                          final showHeader = i == 0 || !_isSameDay(filtered[i - 1].timestamp, event.timestamp);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showHeader) _DayHeader(date: event.timestamp, count: filtered.where((e) => _isSameDay(e.timestamp, event.timestamp)).length),
                              _EventRow(event: event, index: i, zoneColor: _getZoneColor(event.geofenceId, service)),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(GeofenceService service) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TIMELINE',
                style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0),
              ),
              const SizedBox(height: 4),
              const Text(
                'Activity',
                style: TextStyle(color: AppTheme.foreground, fontSize: 30, fontWeight: FontWeight.w800, height: 1),
              ),
            ],
          ),
        ),
        if (service.events.isNotEmpty)
          GestureDetector(
            onTap: () => _confirmClear(context, service),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.danger.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.danger.withOpacity(0.2)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_sweep_rounded, size: 14, color: AppTheme.danger),
                  SizedBox(width: 5),
                  Text(
                    'Clear',
                    style: TextStyle(color: AppTheme.danger, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, color: AppTheme.mutedForeground, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: 'Search events',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(color: AppTheme.mutedForeground, fontSize: 14),
              ),
              style: const TextStyle(color: AppTheme.foreground, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [(_Filter.all, 'All'), (_Filter.entries, 'Entries'), (_Filter.exits, 'Exits')];
    return Row(
      children: filters
          .map(
            (f) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _filter = f.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: _filter == f.$1 ? AppTheme.primaryGradient : null,
                    color: _filter == f.$1 ? null : AppTheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _filter == f.$1 ? Colors.transparent : AppTheme.border),
                  ),
                  child: Text(
                    f.$2,
                    style: TextStyle(color: _filter == f.$1 ? Colors.white : AppTheme.mutedForeground, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  Color _getZoneColor(String geofenceId, GeofenceService service) {
    try {
      final g = service.geofences.firstWhere((g) => g.id == geofenceId);
      return Color(g.color);
    } catch (_) {
      return AppTheme.primary;
    }
  }

  void _confirmClear(BuildContext context, GeofenceService service) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All Events'),
        content: const Text('This will permanently delete all event history.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              service.clearEvents();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

enum _Filter { all, entries, exits, alerts }

class _DayHeader extends StatelessWidget {
  final DateTime date;
  final int count;
  const _DayHeader({required this.date, required this.count});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final isYesterday = date.year == now.year && date.month == now.month && date.day == now.day - 1;
    final label = isToday
        ? 'TODAY'
        : isYesterday
        ? 'YESTERDAY'
        : _fmt(date);

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.mutedForeground, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6),
          ),
          const SizedBox(width: 8),
          Expanded(child: Container(height: 1, color: AppTheme.border)),
          const SizedBox(width: 8),
          Text('$count events', style: const TextStyle(color: AppTheme.mutedForeground, fontSize: 11)),
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${m[d.month].toUpperCase()} ${d.day}';
  }
}

class _EventRow extends StatelessWidget {
  final GeofenceEvent event;
  final int index;
  final Color zoneColor;
  const _EventRow({required this.event, required this.index, required this.zoneColor});

  @override
  Widget build(BuildContext context) {
    final isEnter = event.type == GeofenceEventType.entered;
    // Both dot AND arrow use the zone's own color
    final time = '${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline dot + line (zone color) ─────────────────
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 18),
                  decoration: BoxDecoration(
                    color: zoneColor,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: zoneColor.withOpacity(0.4), blurRadius: 6, spreadRadius: 1)],
                  ),
                ),
                Expanded(
                  child: Center(child: Container(width: 2, color: AppTheme.border)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // ── Event card ────────────────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: zoneColor.withOpacity(0.2)),
                boxShadow: [BoxShadow(color: zoneColor.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Icon bubble — zone color gradient
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [zoneColor, zoneColor.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(isEnter ? Icons.south_east_rounded : Icons.north_west_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isEnter ? 'Entered' : 'Exited',
                                style: const TextStyle(color: AppTheme.foreground, fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              const Text(' · ', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 14)),
                              Expanded(
                                child: Text(
                                  event.geofenceName,
                                  style: const TextStyle(color: AppTheme.foreground, fontWeight: FontWeight.w700, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(color: zoneColor, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                event.geofenceName,
                                style: TextStyle(color: zoneColor, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(color: AppTheme.mutedForeground, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyEventsView extends StatelessWidget {
  const _EmptyEventsView();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: RadialGradient(colors: [AppTheme.primary.withOpacity(0.12), AppTheme.primary.withOpacity(0.02)]),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.timeline_rounded, color: AppTheme.primary, size: 44),
        ),
        const SizedBox(height: 20),
        const Text(
          'No Activity Yet',
          style: TextStyle(color: AppTheme.foreground, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          'Events will appear here as\nyou enter and exit zones',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.mutedForeground, fontSize: 13, height: 1.5),
        ),
      ],
    ),
  );
}
