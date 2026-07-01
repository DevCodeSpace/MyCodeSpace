import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../app/routes/app_routes.dart';
import '../../core/utils/tag_helper.dart';
import 'credentials_controller.dart';

class CredentialDetailView extends GetView<CredentialsController> {
  const CredentialDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pageBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final mainTextColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final subTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Obx(() {
      final cred = controller.selectedCredential.value;
      if (cred == null) {
        return Scaffold(
          backgroundColor: pageBg,
          body: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary), strokeWidth: 3)),
        );
      }

      final cat = controller.categoryById(cred.categoryId);
      final catColor = cat?.displayColor ?? theme.colorScheme.primary;

      return Scaffold(
        backgroundColor: pageBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: mainTextColor),
            onPressed: Get.back,
          ),
          title: Text(
            'Credential Vault',
            style: TextStyle(color: mainTextColor, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.5),
          ),
          actions: [const SizedBox(width: 12)],
        ),
        // Column layout enables the persistent sticky action bar at the bottom
        body: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                children: [
                  // Profile Identity Widget
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color.fromARGB(255, 238, 240, 242), // isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: isDark ? const Color(0xFF334155).withValues(alpha: 0.5) : const Color(0xFFE2E8F0), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: catColor.withValues(alpha: isDark ? 0.15 : 0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : Colors.white, shape: BoxShape.circle),
                          child: Icon(cat?.displayIcon ?? Icons.shield_outlined, size: 28, color: catColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cred.title,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: mainTextColor, letterSpacing: -0.5),
                              ),
                              if (cat != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  cat.name.toUpperCase(),
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: catColor, letterSpacing: 0.8),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            cred.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: cred.isFavorite ? const Color(0xFFF59E0B) : subTextColor,
                            size: 22,
                          ),
                          onPressed: () => controller.toggleFavorite(cred),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'CREDENTIAL DETAILS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: subTextColor),
                    ),
                  ),

                  // Safe Validated Conditional Matrix Renderers
                  if (cred.accountNumber?.isNotEmpty == true)
                    _DetailCard(
                      label: 'Account Number',
                      value: cred.accountNumber!,
                      icon: Icons.account_balance_wallet_outlined,
                      onCopy: () => controller.copyToClipboard(cred.accountNumber!, 'Account Number'),
                    ),
                  if (cred.ifscCode?.isNotEmpty == true)
                    _DetailCard(
                      label: 'IFSC Code',
                      value: cred.ifscCode!,
                      icon: Icons.tag_rounded,
                      onCopy: () => controller.copyToClipboard(cred.ifscCode!, 'IFSC Code'),
                    ),
                  if (cred.username.isNotEmpty)
                    _DetailCard(
                      label: 'Username / Email',
                      value: cred.username,
                      icon: Icons.person_outline_rounded,
                      onCopy: () => controller.copyToClipboard(cred.username, 'Username'),
                    ),
                  if (cred.password.isNotEmpty)
                    _DetailCard(
                      label: 'Password',
                      value: cred.password,
                      icon: Icons.lock_outline_rounded,
                      isSecret: true,
                      onCopy: () => controller.copyToClipboard(cred.password, 'Password'),
                    ),
                  if (cred.url.isNotEmpty)
                    _DetailCard(
                      label: 'Website URL',
                      value: cred.url,
                      icon: Icons.language_rounded,
                      onCopy: () => controller.copyToClipboard(cred.url, 'URL'),
                    ),
                  if (cred.notes.isNotEmpty)
                    _DetailCard(
                      label: 'Notes',
                      value: cred.notes,
                      icon: Icons.description_outlined,
                      onCopy: () => controller.copyToClipboard(cred.notes, 'Notes'),
                    ),

                  // Tag Components Layout
                  if (cred.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        'TAGS',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: subTextColor),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cred.tags.map((tag) {
                        final tagColor = TagHelper.getTagColor(tag);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: tagColor.withValues(alpha: isDark ? 0.06 : 0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: tagColor.withValues(alpha: isDark ? 0.25 : 0.15), width: 1.2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '#',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: tagColor),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tag,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mainTextColor),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 32),

                  Text(
                    'Last updated on ${DateFormat.yMMMMd().format(cred.updatedAt)}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: subTextColor, letterSpacing: 0.2),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Premium Persistent Sticky Action Dock
            Container(
              padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                border: Border(top: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0), width: 1.2)),
              ),
              child: Row(
                children: [
                  // Text Icon Button for Delete Action
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context, cred.id),
                      icon: Icon(Icons.delete_outline_rounded, size: 18, color: theme.colorScheme.error),
                      label: Text(
                        'Delete',
                        style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.4), width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Text Icon Filled Button for Edit Action
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.addEditCredential),
                      icon: const Icon(Icons.edit_note_rounded, size: 20, color: Colors.white),
                      label: const Text(
                        'Edit Credential',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  void _confirmDelete(BuildContext context, String id) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Delete Credential?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        content: const Text(
          'Are you sure you want to delete this item? This action is permanent and cannot be undone.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 4),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteCredential(id);
              Get.back();
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isSecret;
  final VoidCallback onCopy;

  const _DetailCard({required this.label, required this.value, required this.icon, this.isSecret = false, required this.onCopy});

  @override
  State<_DetailCard> createState() => _DetailCardState();
}

class _DetailCardState extends State<_DetailCard> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final displayValue = widget.isSecret && !_visible ? '••••••••••••••••' : widget.value;
    final cardBg = isDark ? const Color(0xFF1E293B).withValues(alpha: 0.6) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155).withValues(alpha: 0.4) : const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol, width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                // decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
                child: Icon(widget.icon, size: 20, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayValue,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                        letterSpacing: widget.isSecret && !_visible ? 1.5 : -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (widget.isSecret)
                IconButton(
                  splashRadius: 22,
                  icon: Icon(
                    _visible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    size: 18,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  onPressed: () => setState(() => _visible = !_visible),
                ),
              IconButton(
                splashRadius: 22,
                icon: Icon(Icons.copy_all_rounded, size: 18, color: theme.colorScheme.primary.withValues(alpha: 0.8)),
                onPressed: widget.onCopy,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
