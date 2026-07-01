import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/shared_file.dart';
import 'file_type_badge.dart';

class FileTile extends StatelessWidget {
  const FileTile({super.key, required this.file, this.onRemove});

  final SharedFile file;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.textPrimary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          if (file.thumbnailBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.memory(
                file.thumbnailBytes!,
                width: 42,
                height: 42,
                fit: BoxFit.cover,
              ),
            )
          else
            FileTypeBadge(category: file.category),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  file.secondaryLabel ?? Formatters.fileSize(file.size),
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(
                Icons.close,
                color: AppTheme.textMuted,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}
