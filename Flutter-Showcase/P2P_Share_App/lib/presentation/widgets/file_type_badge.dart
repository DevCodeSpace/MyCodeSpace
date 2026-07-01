import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../domain/entities/shared_file.dart';

class FileTypeBadge extends StatelessWidget {
  const FileTypeBadge({super.key, required this.category});

  final FileCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppTheme.textPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(_iconFor(category), color: AppTheme.gold, size: 20),
    );
  }

  IconData _iconFor(FileCategory category) {
    switch (category) {
      case FileCategory.image:
        return Icons.photo_outlined;
      case FileCategory.video:
        return Icons.videocam_outlined;
      case FileCategory.audio:
        return Icons.headphones_outlined;
      case FileCategory.app:
        return Icons.android_outlined;
      case FileCategory.document:
        return Icons.description_outlined;
    }
  }
}
