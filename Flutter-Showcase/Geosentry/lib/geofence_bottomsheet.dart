import 'package:flutter/material.dart';
import 'package:geofencing_app/geofence_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme.dart';

class GeofenceBottomSheet extends StatefulWidget {
  final LatLng position;
  final void Function(
          String name, double radius, String? description, int color)
      onSave;

  const GeofenceBottomSheet({
    super.key,
    required this.position,
    required this.onSave,
  });

  @override
  State<GeofenceBottomSheet> createState() => _GeofenceBottomSheetState();
}

class _GeofenceBottomSheetState extends State<GeofenceBottomSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  double _radius = 100;
  int _selectedColor = 0xFF0A84FF;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
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
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(_selectedColor).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_location_rounded,
                      color: Color(_selectedColor),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Geofence Zone',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Tap & hold to drag the pin',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Location chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.pin_drop_rounded,
                      size: 16,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.position.latitude.toStringAsFixed(5)}, ${widget.position.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Name field
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Zone Name',
                  prefixIcon: Icon(Icons.label_rounded, size: 18),
                ),
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(fontSize: 15),
              ),

              const SizedBox(height: 12),

              // Description field
              TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  prefixIcon: Icon(Icons.notes_rounded, size: 18),
                ),
                style: const TextStyle(fontSize: 15),
              ),

              const SizedBox(height: 20),

              // Radius slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Radius',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(_selectedColor).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_radius.toInt()} m',
                      style: TextStyle(
                        color: Color(_selectedColor),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Color(_selectedColor),
                  thumbColor: Color(_selectedColor),
                  overlayColor: Color(_selectedColor).withOpacity(0.1),
                  inactiveTrackColor: AppTheme.surfaceVariant,
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _radius,
                  min: 50,
                  max: 2000,
                  divisions: 39,
                  onChanged: (v) => setState(() => _radius = v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('50m',
                        style: TextStyle(
                            color: AppTheme.onSurfaceVariant, fontSize: 11)),
                    Text('2km',
                        style: TextStyle(
                            color: AppTheme.onSurfaceVariant, fontSize: 11)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Color picker
              const Text(
                'Color',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: AppTheme.geofenceColors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Color(color).withOpacity(0.5),
                                  blurRadius: 8,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 16)
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a zone name'),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    widget.onSave(
                      _nameController.text.trim(),
                      _radius,
                      _descController.text.trim().isEmpty
                          ? null
                          : _descController.text.trim(),
                      _selectedColor,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(_selectedColor),
                  ),
                  child: const Text('Create Zone'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GeofenceOptionsSheet extends StatelessWidget {
  final GeofenceModel geofence;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onZoomTo;

  const GeofenceOptionsSheet({
    super.key,
    required this.geofence,
    required this.onToggle,
    required this.onDelete,
    required this.onZoomTo,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(geofence.color);
    final isInside = geofence.status == GeofenceStatus.inside;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Geofence info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on_rounded, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      geofence.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (isInside ? AppTheme.success : AppTheme.danger)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isInside ? 'Inside' : 'Outside',
                            style: TextStyle(
                              color: isInside
                                  ? AppTheme.success
                                  : AppTheme.danger,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${geofence.radius.toInt()}m radius',
                          style: const TextStyle(
                            color: AppTheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Actions
          _OptionTile(
            icon: Icons.my_location_rounded,
            title: 'Center on Map',
            onTap: () {
              Navigator.pop(context);
              onZoomTo();
            },
          ),
          _OptionTile(
            icon: geofence.isActive
                ? Icons.pause_circle_rounded
                : Icons.play_circle_rounded,
            title: geofence.isActive ? 'Disable Zone' : 'Enable Zone',
            color: geofence.isActive ? AppTheme.warning : AppTheme.success,
            onTap: () {
              Navigator.pop(context);
              onToggle();
            },
          ),
          _OptionTile(
            icon: Icons.delete_outline_rounded,
            title: 'Delete Zone',
            color: AppTheme.danger,
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.onSurface;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: c, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: c,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppTheme.onSurfaceVariant,
        size: 18,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}