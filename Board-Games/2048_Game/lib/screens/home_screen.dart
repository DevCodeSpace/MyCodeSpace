import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/grid_size_card.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedSize = 4;
  final List<int> _sizes = [4, 5, 6, 8];

  late AnimationController _logoCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.5)),
    );
    _logoCtrl.forward();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    super.dispose();
  }

  void _startGame() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: GameScreen(
            gridSize: _selectedSize,
            isDarkMode: widget.isDarkMode,
            onToggleTheme: widget.onToggleTheme,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(isDark: isDark, onToggleTheme: widget.onToggleTheme),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // Logo
                      FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: _LogoTitle(isDark: isDark),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Join the numbers — reach 2048!',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Board size label
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'BOARD SIZE',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 2×2 grid size cards
                      _GridSizeSelector(
                        sizes: _sizes,
                        selectedSize: _selectedSize,
                        isDark: isDark,
                        onSelect: (s) {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedSize = s);
                        },
                      ),
                      const SizedBox(height: 44),

                      _PlayButton(onTap: _startGame),
                      const SizedBox(height: 44),

                      _BottomBar(isDark: isDark),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top Bar ────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  const _TopBar({required this.isDark, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavIconBtn(
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            iconColor: isDark ? Colors.amber : AppColors.textDark,
            isDark: isDark,
            onTap: onToggleTheme,
          ),
          _NavIconBtn(
            icon: Icons.settings_rounded,
            iconColor: AppColors.textMuted,
            isDark: isDark,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _NavIconBtn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final bool isDark;
  final VoidCallback onTap;
  const _NavIconBtn({
    required this.icon,
    required this.iconColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.borderColor,
            width: 1.5,
          ),
        ),
        child: IconButton(
          icon: Icon(icon, color: iconColor),
          onPressed: onTap,
        ),
      ),
    );
  }
}

// ── Logo Title ─────────────────────────────────────────────────

class _LogoTitle extends StatelessWidget {
  final bool isDark;
  const _LogoTitle({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.accentAlt],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderSelected,
          width: 2,
        ),
      ),
      child: Text(
        '2048',
        style: GoogleFonts.poppins(
          fontSize: 58,
          fontWeight: FontWeight.w900,
          color: AppColors.textDark,
          height: 1,
        ),
      ),
    );
  }
}

// ── 2×2 Grid Size Selector ─────────────────────────────────────

class _GridSizeSelector extends StatelessWidget {
  final List<int> sizes;
  final int selectedSize;
  final bool isDark;
  final ValueChanged<int> onSelect;

  const _GridSizeSelector({
    required this.sizes,
    required this.selectedSize,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GridSizeCard(
                size: sizes[0],
                isSelected: sizes[0] == selectedSize,
                onTap: () => onSelect(sizes[0]),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: GridSizeCard(
                size: sizes[1],
                isSelected: sizes[1] == selectedSize,
                onTap: () => onSelect(sizes[1]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: GridSizeCard(
                size: sizes[2],
                isSelected: sizes[2] == selectedSize,
                onTap: () => onSelect(sizes[2]),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: GridSizeCard(
                size: sizes[3],
                isSelected: sizes[3] == selectedSize,
                onTap: () => onSelect(sizes[3]),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Play Button ────────────────────────────────────────────────

class _PlayButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PlayButton({required this.onTap});

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.0,
      upperBound: 0.06,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 19),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accent, AppColors.accentAlt],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderSelected,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow_rounded,
                    color: AppColors.textDark, size: 28),
                const SizedBox(width: 8),
                Text(
                  'PLAY NOW',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: 1.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom Bar ─────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final bool isDark;
  const _BottomBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _BottomIcon(
          icon: Icons.emoji_events_rounded,
          label: 'Achievements',
          isDark: isDark,
        ),
        _BottomIcon(
          icon: Icons.leaderboard_rounded,
          label: 'Leaderboard',
          isDark: isDark,
        ),
      ],
    );
  }
}

class _BottomIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _BottomIcon({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.borderColor,
              width: 1.5,
            ),
          ),
          child: Icon(icon, color: AppColors.textMuted, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
