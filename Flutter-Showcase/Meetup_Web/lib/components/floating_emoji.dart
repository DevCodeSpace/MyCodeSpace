import 'dart:math' as math;
import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FloatingEmoji extends StatefulWidget {
  final String emoji;
  final String senderName;
  final VoidCallback onAnimationComplete;
  final bool isMobile;

  const FloatingEmoji({super.key, required this.emoji, required this.senderName, required this.onAnimationComplete, required this.isMobile});

  @override
  State<FloatingEmoji> createState() => _FloatingEmojiState();
}

class _FloatingEmojiState extends State<FloatingEmoji> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _travelAnimation;
  late Animation<double> _fadeAnimation;
  late double _randomXOffset;

  @override
  void initState() {
    super.initState();
    // Keeps quick reactions clustered horizontally across the central layout space
    _randomXOffset = (math.Random().nextDouble() * 160) - 80;

    _controller = AnimationController(
      duration: Duration(milliseconds: 3500 + math.Random().nextInt(501)),
      vsync: this,
    );

    _travelAnimation = Tween<double>(begin: 0.0, end: 500).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 15), // Fade in quick
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 70), // Hold full opacity
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 15), // Fade out elegantly
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onAnimationComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AnimatedEmojiData getAnimatedEmoji(String id) {
      switch (id) {
        case 'clap':
          return AnimatedEmojis.clap;
        case 'heart':
          return AnimatedEmojis.redHeart;
        case 'thumbsUp':
          return AnimatedEmojis.thumbsUp;
        case 'party':
          return AnimatedEmojis.partyPopper;
        case 'laugh':
          return AnimatedEmojis.laughing;
        case 'astonished':
          return AnimatedEmojis.astonished;
        case 'thinking':
          return AnimatedEmojis.thinkingFace;
        default:
          return AnimatedEmojis.smile;
      }
    }

    final size = widget.isMobile ? 36 : 44;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_randomXOffset, -_travelAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: size.toDouble(), height: size.toDouble(), child: AnimatedEmoji(getAnimatedEmoji(widget.emoji), repeat: true)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.65), borderRadius: BorderRadius.circular(100)),
                    child: Text(
                      widget.senderName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.googleSans(
                        color: Colors.white,
                        fontSize: widget.isMobile ? 10 : 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
