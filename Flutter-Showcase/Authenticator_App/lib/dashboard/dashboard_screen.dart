import 'package:authenticator/Controller/auth_controller.dart';
import 'package:authenticator/Controller/theme_controller.dart';
import 'package:authenticator/Model/account_model.dart';
import 'package:authenticator/Routes/app_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

class _AppColors {
  final bool isDark;
  const _AppColors(this.isDark);

  // Backgrounds
  Color get bgPage => isDark ? const Color(0xFF0A0E1A) : const Color(0xFFFFFFFF);
  Color get bgCard => isDark ? const Color(0xFF111827) : const Color(0xFFFFFFFF);
  Color get bgCardLight => isDark ? const Color(0xFF1A2235) : const Color(0xFFF8FAFC);

  // Text
  Color get textPrimary => isDark ? const Color(0xFFEFF6FF) : const Color(0xFF0F172A);
  Color get textSecondary => isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  // Borders / dividers
  Color get border => isDark ? const Color(0xFF1E3A5F) : const Color(0xFFDDE3ED);
  Color get divider => isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05);

  // Chip / search background in light mode uses a slightly off-white
  Color get inputBg => isDark ? const Color(0xFF111827) : const Color(0xFFFFFFFF);

  // Hero card
  List<Color> get heroGradient => isDark ? [const Color(0xFF0D2B45), const Color(0xFF0A1628)] : [const Color(0xFFFFFFFF), const Color(0xFFF0FDF9)];
  Color get heroBorder => isDark ? _AppColors.primary.withValues(alpha: 0.25) : _AppColors.primary.withValues(alpha: 0.3);
  Color get heroGlow => isDark ? _AppColors.primary.withValues(alpha: 0.12) : _AppColors.primary.withValues(alpha: 0.15);

  // Hero card text (white on dark, dark on light)
  Color get heroTextPrimary => isDark ? Colors.white : const Color(0xFF0F172A);
  Color get heroTextSecondary => isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B);
  Color get heroTextFaint => isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF94A3B8);
  Color get heroDividerLine => isDark ? Colors.white.withValues(alpha: 0.08) : _AppColors.primary.withValues(alpha: 0.12);

  // Accents (same in both modes)
  static const Color primary = Color(0xFF00D4AA);
  static const Color primaryDark = Color(0xFF00A884);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color urgent = Color(0xFFEF4444);

  static const List<List<Color>> cardAccents = [
    [Color(0xFF00D4AA), Color(0xFF0891B2)],
    [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    [Color(0xFF3B82F6), Color(0xFF06B6D4)],
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    [Color(0xFF10B981), Color(0xFF059669)],
  ];
}

class DashboardScreen extends GetView<AuthController> {
  const DashboardScreen({super.key});

  ThemeController get _theme {
    if (!Get.isRegistered<ThemeController>()) {
      Get.put(ThemeController(), permanent: true);
    }
    return Get.find<ThemeController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final c = _AppColors(_theme.isDark.value);
      return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: c.bgPage,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              _buildBackgroundDecor(c),
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(c),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [_buildHeroCard(c), _buildStatsRow(c), _buildSearchBar(c), _buildSectionHeader(c), _buildAccountList(c), const SizedBox(height: 100)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildFloatingBottomNav(c),
            ],
          ),
        ),
      );
    });
  }

  // ─────────────────────── Background ───────────────────────

  Widget _buildBackgroundDecor(_AppColors c) {
    return Stack(
      children: [
        Positioned(top: -80, right: -80, child: _glow(250, _AppColors.primary.withValues(alpha: c.isDark ? 0.12 : 0.08))),
        Positioned(top: 200, left: -100, child: _glow(200, _AppColors.accentPurple.withValues(alpha: c.isDark ? 0.08 : 0.05))),
        Positioned(bottom: 300, right: -60, child: _glow(180, _AppColors.accentBlue.withValues(alpha: c.isDark ? 0.06 : 0.04))),
      ],
    );
  }

  Widget _glow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }

  // ─────────────────────── Header ───────────────────────

  Widget _buildHeader(_AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: _AppColors.primary.withValues(alpha: 0.6), blurRadius: 6)],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "CODEX AUTH",
                    style: TextStyle(color: _AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2.5),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "My Vault",
                style: TextStyle(color: c.textPrimary, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ),
            ],
          ),
          Row(
            children: [
              _glassButton(Icons.notifications_none_rounded, c, badge: true),
              const SizedBox(width: 10),
              _themeToggleButton(c),
              const SizedBox(width: 10),
              _buildAvatar(c),
            ],
          ),
        ],
      ),
    );
  }

  Widget _glassButton(IconData icon, _AppColors c, {bool badge = false}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: c.bgCardLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.border),
          ),
          child: Icon(icon, size: 20, color: c.textSecondary),
        ),
        if (badge)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: _AppColors.primary.withValues(alpha: 0.6), blurRadius: 4)],
              ),
            ),
          ),
      ],
    );
  }

  Widget _themeToggleButton(_AppColors c) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _theme.toggleTheme();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: c.bgCardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.isDark ? _AppColors.accentPurple.withValues(alpha: 0.35) : c.border),
          boxShadow: c.isDark ? [BoxShadow(color: _AppColors.accentPurple.withValues(alpha: 0.12), blurRadius: 8)] : [],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Icon(
            c.isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
            key: ValueKey(c.isDark),
            size: 20,
            color: c.isDark ? const Color(0xFFFBBF24) : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(_AppColors c) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(colors: [_AppColors.primary, _AppColors.accentPurple], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: _AppColors.primary.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: const Center(
        child: Text(
          "CX",
          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  // ─────────────────────── Hero Card ───────────────────────

  Widget _buildHeroCard(_AppColors c) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(colors: c.heroGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border.all(color: c.heroBorder, width: 1),
        boxShadow: [BoxShadow(color: c.heroGlow, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Protected Accounts", style: TextStyle(color: c.heroTextSecondary, fontSize: 12, letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    Obx(
                      () => Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${controller.filteredAccounts.length}",
                            style: TextStyle(color: c.heroTextPrimary, fontSize: 52, fontWeight: FontWeight.w900, height: 1, letterSpacing: -2),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10, left: 6),
                            child: Text("accounts", style: TextStyle(color: c.heroTextSecondary, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [const BoxShadow(color: _AppColors.primary, blurRadius: 6)],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "AES-256 encrypted",
                          style: TextStyle(color: _AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildShieldWidget(),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: c.heroDividerLine),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _heroStat("TOTP", "Protocol", _AppColors.primary, c),
              _heroDivider(c),
              _heroStat("30s", "Refresh", _AppColors.accentBlue, c),
              _heroDivider(c),
              Obx(() => _heroStat("${controller.secondsRemaining.value}s", "Next in", _AppColors.accentPurple, c)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShieldWidget() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [_AppColors.primary.withValues(alpha: 0.2), _AppColors.primary.withValues(alpha: 0.05)]),
        border: Border.all(color: _AppColors.primary.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.shield_rounded, color: _AppColors.primary, size: 36),
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: _AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: _AppColors.primary, blurRadius: 8)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String value, String label, Color color, _AppColors c) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: c.heroTextFaint, fontSize: 10, letterSpacing: 0.3)),
      ],
    );
  }

  Widget _heroDivider(_AppColors c) {
    return Container(width: 1, height: 28, color: c.heroDividerLine);
  }

  // ─────────────────────── Stats Row ───────────────────────

  Widget _buildStatsRow(_AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(child: _statChip(Icons.verified_user_rounded, "Secured", "Active", _AppColors.primary, c)),
          const SizedBox(width: 12),
          Expanded(child: _statChip(Icons.auto_awesome_rounded, "TOTP 2FA", "Method", _AppColors.accentPurple, c)),
          const SizedBox(width: 12),
          Expanded(child: _statChip(Icons.lock_clock_rounded, "SHA-1", "Algorithm", _AppColors.accentBlue, c)),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String title, String sub, Color color, _AppColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [if (!c.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: c.textPrimary, fontSize: 11, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(sub, style: TextStyle(color: c.textSecondary, fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── Search ───────────────────────

  Widget _buildSearchBar(_AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.border),
          boxShadow: [if (!c.isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: TextField(
          onChanged: (value) => controller.searchQuery.value = value,
          style: TextStyle(color: c.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: "Search accounts...",
            hintStyle: TextStyle(color: c.textSecondary, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: c.textSecondary, size: 20),
            suffixIcon: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: _AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.tune_rounded, color: _AppColors.primary, size: 16),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  // ─────────────────────── Section Header ───────────────────────

  Widget _buildSectionHeader(_AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: _AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [BoxShadow(color: _AppColors.primary.withValues(alpha: 0.6), blurRadius: 6)],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Active Tokens",
                style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: -0.3),
              ),
            ],
          ),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                "${controller.filteredAccounts.length} accounts",
                style: const TextStyle(color: _AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── Account List ───────────────────────

  Widget _buildAccountList(_AppColors c) {
    return Obx(
      () => AnimationLimiter(
        child: controller.filteredAccounts.isEmpty
            ? _buildEmptyState(c)
            : Column(
                children: List.generate(controller.filteredAccounts.length, (index) {
                  final acc = controller.filteredAccounts[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(verticalOffset: 40, child: FadeInAnimation(child: _buildTokenCard(acc, index, c))),
                  );
                }),
              ),
      ),
    );
  }

  Widget _buildEmptyState(_AppColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: c.bgCard,
              shape: BoxShape.circle,
              border: Border.all(color: c.border),
            ),
            child: Icon(Icons.shield_outlined, color: c.textSecondary, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            "No accounts yet",
            style: TextStyle(color: c.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text("Scan a QR code to add your first account", style: TextStyle(color: c.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  // ─────────────────────── Token Card ───────────────────────

  Widget _buildTokenCard(AccountModel acc, int index, _AppColors c) {
    final accent = _AppColors.cardAccents[index % _AppColors.cardAccents.length];
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accent[0].withValues(alpha: 0.2)),
          boxShadow: [BoxShadow(color: c.isDark ? accent[0].withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [accent[0].withValues(alpha: 0.07), Colors.transparent]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    _buildAccountIcon(acc, accent),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            acc.account,
                            style: TextStyle(color: c.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => Text(
                              controller.formatOtp(controller.getOtp(acc.secret)),
                              style: TextStyle(color: c.textPrimary, fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: 4, height: 1.1),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildCopyHint(accent[0]),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildCircularTimer(accent[0], c),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountIcon(AccountModel acc, List<Color> accent) {
    final initial = acc.account.isNotEmpty ? acc.account[0].toUpperCase() : '?';
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(colors: accent, begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: accent[0].withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildCopyHint(Color color) {
    return Row(
      children: [
        Icon(Icons.copy_rounded, size: 10, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text(
          "Tap to copy",
          style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildCircularTimer(Color color, _AppColors c) {
    return Obx(() {
      final seconds = controller.secondsRemaining.value;
      final isUrgent = seconds <= 5;
      final timerColor = isUrgent ? _AppColors.urgent : color;

      return SizedBox(
        width: 52,
        height: 52,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(shape: BoxShape.circle, color: timerColor.withValues(alpha: 0.08)),
            ),
            SizedBox(
              width: 52,
              height: 52,
              child: CircularProgressIndicator(
                value: seconds / 30.0,
                color: timerColor,
                backgroundColor: c.isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
                strokeWidth: 3,
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "$seconds",
                  style: TextStyle(color: isUrgent ? _AppColors.urgent : c.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                ),
                Text("sec", style: TextStyle(color: c.textSecondary, fontSize: 8)),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ─────────────────────── Bottom Nav ───────────────────────

  Widget _buildFloatingBottomNav(_AppColors c) {
    return Positioned(
      bottom: 16 + MediaQuery.of(Get.context!).padding.bottom,
      left: 20,
      right: 20,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: c.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: c.isDark ? 0.4 : 0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
            BoxShadow(color: _AppColors.primary.withValues(alpha: 0.05), blurRadius: 20),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_navItem(Icons.grid_view_rounded, "Vault", true, c), _buildScanButton(), _navItem(Icons.person_outline_rounded, "Profile", false, c)],
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Get.toNamed(AppRoutes.scanner);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_AppColors.primary, _AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: _AppColors.primary.withValues(alpha: 0.45), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 3),
          const Text(
            "Scan",
            style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive, _AppColors c) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? _AppColors.primary : c.textSecondary, size: 22),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: isActive ? _AppColors.primary : c.textSecondary, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400),
        ),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 3),
            width: 16,
            height: 2.5,
            decoration: BoxDecoration(
              color: _AppColors.primary,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [BoxShadow(color: _AppColors.primary.withValues(alpha: 0.6), blurRadius: 4)],
            ),
          ),
      ],
    );
  }
}
