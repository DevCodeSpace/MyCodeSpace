import 'package:animations_app/Export/export.dart';

class TransferOption {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> features;
  final List<String> details;
  final VoidCallback onTap;

  const TransferOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.features,
    required this.details,
    required this.onTap,
  });
}
