import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';

class AppIconWidget extends StatefulWidget {
  final String? packageName;
  final Uint8List? iconBytes;
  final IconData? iconData;
  final Color? color;
  final double size;

  const AppIconWidget({super.key, this.packageName, this.iconBytes, this.iconData, this.color, required this.size});

  // Global static cache for icons so we only fetch each icon once across the app lifecycle
  static final Map<String, Uint8List> _iconCache = {};

  @override
  State<AppIconWidget> createState() => _AppIconWidgetState();
}

class _AppIconWidgetState extends State<AppIconWidget> {
  Uint8List? _lazyIconBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLazyIcon();
  }

  @override
  void didUpdateWidget(AppIconWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageName != widget.packageName || oldWidget.iconBytes != widget.iconBytes) {
      _loadLazyIcon();
    }
  }

  Future<void> _loadLazyIcon() async {
    // If we already have direct iconBytes, no need to load lazily
    if (widget.iconBytes != null && widget.iconBytes!.isNotEmpty) {
      if (mounted) {
        setState(() {
          _lazyIconBytes = widget.iconBytes;
        });
      }
      return;
    }

    final pkg = widget.packageName;
    if (pkg == null || pkg.isEmpty) {
      if (mounted) {
        setState(() {
          _lazyIconBytes = null;
        });
      }
      return;
    }

    // Check static cache
    final cached = AppIconWidget._iconCache[pkg];
    if (cached != null) {
      if (mounted) {
        setState(() {
          _lazyIconBytes = cached;
        });
      }
      return;
    }

    if (_isLoading) return;
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final appInfo = await InstalledApps.getAppInfo(pkg);
      if (appInfo != null && appInfo.icon != null && appInfo.icon!.isNotEmpty) {
        AppIconWidget._iconCache[pkg] = appInfo.icon!;
        if (mounted) {
          setState(() {
            _lazyIconBytes = appInfo.icon;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _lazyIconBytes ?? widget.iconBytes;
    if (bytes != null && bytes.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.size * 0.2),
        child: Image.memory(
          bytes,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(widget.iconData ?? Icons.android, color: widget.color, size: widget.size);
          },
        ),
      );
    }
    return Icon(widget.iconData ?? Icons.android, color: widget.color, size: widget.size);
  }
}
