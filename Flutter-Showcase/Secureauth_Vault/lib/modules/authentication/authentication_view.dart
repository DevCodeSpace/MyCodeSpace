import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import 'authentication_controller.dart';

class AuthenticationView extends GetView<AuthenticationController> {
  const AuthenticationView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final pageBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(title: const Text('Authentication'), backgroundColor: pageBg),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeroCard(context, isDark, primaryColor),
            _buildStatsRow(context, isDark, primaryColor),
            _buildSearchBar(context, isDark),
            _buildSectionHeader(context, isDark, primaryColor),
            _buildAccountList(context, isDark, primaryColor),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Builder(
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(bottom: 84 + MediaQuery.of(context).padding.bottom),
            child: FloatingActionButton(
              onPressed: () => Get.toNamed(AppRoutes.scanner),
              backgroundColor: const Color(0xFF15BABD),
              child: const Icon(Icons.qr_code_scanner_rounded),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────── Theme Helpers ───────────────────────

  Color _getBorderColor(bool isDark) {
    return isDark ? const Color(0xFF1F293D) : const Color(0xFFE2E8F0);
  }

  Color _getTextPrimaryColor(bool isDark) {
    return isDark ? Colors.white : const Color(0xFF0F172A);
  }

  Color _getTextSecondaryColor(bool isDark) {
    return isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  }

  List<BoxShadow> _getCardBoxShadow(bool isDark) {
    return [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.02), blurRadius: 8, offset: const Offset(0, 4))];
  }

  // ─────────────────────── Hero Card ───────────────────────

  Widget _buildHeroCard(BuildContext context, bool isDark, Color primaryColor) {
    final cardBg = Theme.of(context).cardColor;
    final textPrimary = _getTextPrimaryColor(isDark);
    final textSecondary = _getTextSecondaryColor(isDark);
    final borderColor = _getBorderColor(isDark);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: _getCardBoxShadow(isDark),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Protected Accounts", style: TextStyle(color: textSecondary, fontSize: 12, letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    Obx(
                      () => Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${controller.filteredAccounts.length}",
                            style: TextStyle(color: textPrimary, fontSize: 52, fontWeight: FontWeight.w900, height: 1, letterSpacing: -2),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10, left: 6),
                            child: Text("accounts", style: TextStyle(color: textSecondary, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "AES-256 encrypted",
                          style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildShieldWidget(primaryColor),
            ],
          ),
          const SizedBox(height: 20),
          Divider(height: 1, color: borderColor),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _heroStat("TOTP", "Protocol", primaryColor, isDark),
              Container(width: 1, height: 28, color: borderColor),
              _heroStat("30s", "Refresh", Colors.blue, isDark),
              Container(width: 1, height: 28, color: borderColor),
              Obx(() => _heroStat("${controller.secondsRemaining.value}s", "Next in", Colors.purple, isDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShieldWidget(Color primaryColor) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF15BABD).withOpacity(0.12)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.shield_rounded, color: const Color(0xFF15BABD), size: 36),
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: const Color(0xFF15BABD), shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String value, String label, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: _getTextSecondaryColor(isDark), fontSize: 10, letterSpacing: 0.3)),
      ],
    );
  }

  // ─────────────────────── Stats Row ───────────────────────

  Widget _buildStatsRow(BuildContext context, bool isDark, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(child: _statChip(context, Icons.verified_user_rounded, "Secured", "Active", primaryColor, isDark)),
          const SizedBox(width: 12),
          Expanded(child: _statChip(context, Icons.auto_awesome_rounded, "TOTP 2FA", "Method", Colors.purple, isDark)),
          const SizedBox(width: 12),
          Expanded(child: _statChip(context, Icons.lock_clock_rounded, "SHA-1", "Algorithm", Colors.blue, isDark)),
        ],
      ),
    );
  }

  Widget _statChip(BuildContext context, IconData icon, String title, String sub, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getBorderColor(isDark)),
        boxShadow: _getCardBoxShadow(isDark),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: _getTextPrimaryColor(isDark), fontSize: 11, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(sub, style: TextStyle(color: _getTextSecondaryColor(isDark), fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── Search ───────────────────────

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _getBorderColor(isDark)),
          boxShadow: _getCardBoxShadow(isDark),
        ),
        child: TextField(
          onChanged: (value) => controller.searchQuery.value = value,
          style: TextStyle(color: _getTextPrimaryColor(isDark), fontSize: 14),
          decoration: InputDecoration(
            hintText: "Search accounts...",
            hintStyle: TextStyle(color: _getTextSecondaryColor(isDark), fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: _getTextSecondaryColor(isDark), size: 20),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  // ─────────────────────── Section Header ───────────────────────

  Widget _buildSectionHeader(BuildContext context, bool isDark, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 12,
                decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 8),
              Text(
                "ACTIVE TOKENS",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: _getTextSecondaryColor(isDark)),
              ),
            ],
          ),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Text(
                "${controller.filteredAccounts.length} accounts",
                style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── Account List ───────────────────────

  Widget _buildAccountList(BuildContext context, bool isDark, Color primaryColor) {
    return Obx(
      () => controller.filteredAccounts.isEmpty
          ? _buildEmptyState(context, isDark)
          : Column(
              children: List.generate(controller.filteredAccounts.length, (index) {
                final acc = controller.filteredAccounts[index];
                return _buildTokenCard(context, acc, index, isDark);
              }),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: _getBorderColor(isDark)),
            ),
            child: Icon(Icons.shield_outlined, color: _getTextSecondaryColor(isDark), size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            "No accounts yet",
            style: TextStyle(color: _getTextPrimaryColor(isDark), fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text("Scan a QR code to add your first account", style: TextStyle(color: _getTextSecondaryColor(isDark), fontSize: 13)),
        ],
      ),
    );
  }

  // ─────────────────────── Token Card ───────────────────────

  Widget _buildTokenCard(BuildContext context, dynamic acc, int index, bool isDark) {
    final textPrimary = _getTextPrimaryColor(isDark);
    final textSecondary = _getTextSecondaryColor(isDark);
    final cardAccentColors = [Colors.blue, Colors.purple, Colors.teal, Colors.orange];
    final accent = cardAccentColors[index % cardAccentColors.length];

    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _getBorderColor(isDark)),
          boxShadow: _getCardBoxShadow(isDark),
        ),
        child: Padding(
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
                      style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Text(
                        controller.formatOtp(controller.getOtp(acc.secret)),
                        style: TextStyle(color: textPrimary, fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: 4, height: 1.1),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildCopyHint(accent),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildCircularTimer(context, accent, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountIcon(dynamic acc, Color accent) {
    final initial = acc.account.isNotEmpty ? acc.account[0].toUpperCase() : '?';
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: accent.withOpacity(0.12)),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(color: accent, fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildCopyHint(Color color) {
    return Row(
      children: [
        Icon(Icons.copy_rounded, size: 10, color: color),
        const SizedBox(width: 4),
        Text(
          "Tap to copy",
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildCircularTimer(BuildContext context, Color color, bool isDark) {
    return Obx(() {
      final seconds = controller.secondsRemaining.value;
      final isUrgent = seconds <= 5;
      final urgentColor = Theme.of(context).colorScheme.error;
      final timerColor = isUrgent ? urgentColor : color;

      return SizedBox(
        width: 52,
        height: 52,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(shape: BoxShape.circle, color: timerColor.withOpacity(0.08)),
            ),
            SizedBox(
              width: 52,
              height: 52,
              child: CircularProgressIndicator(
                value: seconds / 30.0,
                color: timerColor,
                backgroundColor: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06),
                strokeWidth: 3,
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "$seconds",
                  style: TextStyle(color: isUrgent ? urgentColor : _getTextPrimaryColor(isDark), fontSize: 15, fontWeight: FontWeight.w800),
                ),
                Text("sec", style: TextStyle(color: _getTextSecondaryColor(isDark), fontSize: 8)),
              ],
            ),
          ],
        ),
      );
    });
  }
}
