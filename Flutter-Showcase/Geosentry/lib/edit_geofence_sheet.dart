import 'package:flutter/material.dart';
import 'package:geofencing_app/geofence_model.dart';
import 'package:geofencing_app/theme.dart';

class EditGeofenceSheet extends StatefulWidget {
  final GeofenceModel geofence;
  final void Function(GeofenceModel updated) onSave;

  const EditGeofenceSheet({
    super.key,
    required this.geofence,
    required this.onSave,
  });

  @override
  State<EditGeofenceSheet> createState() => _EditGeofenceSheetState();
}

class _EditGeofenceSheetState extends State<EditGeofenceSheet> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late double _radius;
  late int _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.geofence.name);
    _descController =
        TextEditingController(text: widget.geofence.description ?? '');
    _radius = widget.geofence.radius;
    _selectedColor = widget.geofence.color;
  }

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
                      Icons.edit_location_rounded,
                      color: Color(_selectedColor),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Zone',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Update name, radius or color',
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

              // Location (read-only)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.pin_drop_rounded,
                        size: 16, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.geofence.latitude.toStringAsFixed(5)}, '
                      '${widget.geofence.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Fixed',
                      style: TextStyle(
                          fontSize: 11, color: AppTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Name
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

              // Description
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
                  const Text('Radius',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
              const Text('Color',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
                            content: Text('Please enter a zone name')),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    widget.onSave(
                      widget.geofence.copyWith(
                        name: _nameController.text.trim(),
                        radius: _radius,
                        description: _descController.text.trim().isEmpty
                            ? null
                            : _descController.text.trim(),
                        color: _selectedColor,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(_selectedColor),
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}