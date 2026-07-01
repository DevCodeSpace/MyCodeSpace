import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/tile_model.dart';
import '../theme/app_theme.dart';

class TileWidget extends StatefulWidget {
  final TileModel tile;
  final double size;

  const TileWidget({super.key, required this.tile, required this.size});

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = widget.tile.isNew
        ? Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut))
        : widget.tile.isMerged
        ? Tween<double>(begin: 1.18, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut))
        : ConstantTween<double>(1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.linear));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(TileWidget old) {
    super.didUpdateWidget(old);
    if (widget.tile.isMerged && !old.tile.isMerged) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.tileColor(widget.tile.value);
    final fontColor = AppColors.tileFontColor(widget.tile.value);
    final size = widget.size;

    return TweenAnimationBuilder(
      tween: Tween(begin: 0.85, end: 1.0),
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color, // ✅ FIXED
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          '${widget.tile.value}',
          style: TextStyle(fontSize: size * 0.35, fontWeight: FontWeight.bold, color: fontColor),
        ),
      ),
    );
  }
}
