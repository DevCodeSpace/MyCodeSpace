import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/utils/tag_helper.dart';
import '../../models/credential.dart';
import 'credentials_controller.dart';

class CredentialsView extends GetView<CredentialsController> {
  const CredentialsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pageBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final titleColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'SecureAuth Vault',
          style: TextStyle(color: titleColor, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        actions: [
          Obx(
            () => IconButton(
              onPressed: controller.onFavChange,
              icon: controller.showFav.value ? Icon(Icons.star_rounded, color: Colors.amber) : Icon(Icons.star_outline_rounded),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search_rounded, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
            onPressed: () => showSearch(context: context, delegate: _CredentialSearchDelegate(controller, isDark)),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary)));
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Categories Horizontal Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 16, 4),
                child: Text(
                  'CATEGORIES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),

            // Horizontal Category Scroll (Keeps original chip layout & behavior)
            SliverToBoxAdapter(child: _CategoryBar(controller: controller)),

            // Vault Records Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 16, 12),
                child: Text(
                  'SECURE RECORDS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),

            // Credentials List (Keeps original List/Tile structure with matching Document borders & backgrounds)
            controller.filtered.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: _EmptyState(onAdd: () => Get.toNamed(AppRoutes.addEditCredential)),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CredentialTile(credential: controller.filtered[i], controller: controller),
                        ),
                        childCount: controller.filtered.length,
                      ),
                    ),
                  ),
          ],
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Builder(
        builder: (context) => Padding(
          padding: EdgeInsets.only(bottom: 84 + MediaQuery.of(context).padding.bottom),
          child: FloatingActionButton.extended(
            heroTag: 'credentials_fab',
            elevation: 4,
            highlightElevation: 1,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            onPressed: () => Get.toNamed(AppRoutes.addEditCredential),
            icon: const Icon(Icons.add_rounded, size: 22),
            label: const Text('Add New', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.2)),
          ),
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final CredentialsController controller;
  const _CategoryBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final selectedCat = controller.selectedCategory.value;

      return SizedBox(
        height: 48,
        child: ListView(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _buildCategoryChip(
              context: context,
              label: 'All',
              icon: Icons.grid_view_rounded,
              isSelected: selectedCat == null,
              isDark: isDark,
              activeColor: Theme.of(context).colorScheme.primary,
              onTap: () => controller.selectCategory(null),
            ),
            ...controller.categories.map((cat) {
              final isSelected = selectedCat?.id == cat.id;
              return _buildCategoryChip(
                context: context,
                label: cat.name,
                icon: cat.displayIcon,
                isSelected: isSelected,
                isDark: isDark,
                activeColor: cat.displayColor,
                onTap: () => controller.selectCategory(cat),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildCategoryChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    final unselectedBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final unselectedTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Padding(
      padding: const EdgeInsets.only(right: 10, top: 4, bottom: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSelected ? [activeColor, activeColor.withValues(alpha: 0.85)] : [unselectedBg, unselectedBg],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(200),
              border: Border.all(color: isSelected ? activeColor.withValues(alpha: 0.3) : borderCol, width: 1.0),
              boxShadow: [
                BoxShadow(color: isSelected ? activeColor.withValues(alpha: 0.25) : Colors.transparent, blurRadius: 12, offset: const Offset(0, 6)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedTheme(
                  data: ThemeData(iconTheme: IconThemeData(color: isSelected ? Colors.white : activeColor)),
                  duration: const Duration(milliseconds: 200),
                  child: Icon(icon, size: 16),
                ),
                const SizedBox(width: 8),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isSelected ? Colors.white : unselectedTextColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CredentialTile extends StatelessWidget {
  final Credential credential;
  final CredentialsController controller;
  const _CredentialTile({required this.credential, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cat = controller.categoryById(credential.categoryId);
    final catColor = cat?.displayColor ?? Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.15) : const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 16,
            spreadRadius: -4,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            controller.selectedCredential.value = credential;
            Get.toNamed(AppRoutes.credentialDetail);
          },
          onLongPress: () => _showOptionsSheet(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Category Icon Matching Document Card Icon Geometry Frame
                Icon(cat?.displayIcon ?? Icons.lock_outline_rounded, color: catColor, size: 24),
                const SizedBox(width: 16),
                // Title and Identification Parameters
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        credential.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        cat?.name == "Banking"
                            ? credential.ifscCode!.isNotEmpty
                                  ? 'A/C no. ${credential.accountNumber}'
                                  : 'No account details'
                            : credential.username.isNotEmpty
                            ? credential.username
                            : 'No account identification details',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Action Sheet Entry Trigger Elements
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (credential.isFavorite)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                      ),
                    IconButton(
                      style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.all(0)), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      icon: Icon(Icons.copy_rounded, size: 18, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      onPressed: () => controller.copyToClipboard(
                        credential.password.isEmpty ? credential.accountNumber! : credential.password,
                        credential.password.isEmpty ? 'Account Number' : 'Password',
                      ),
                      tooltip: 'Copy',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: isDark ? const Color(0xFF1F293D) : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.copy_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
              ),
              title: const Text('Copy Password', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                controller.copyToClipboard(credential.password, 'Password');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
              ),
              title: const Text(
                'Delete Record',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        title: const Text('Delete Credential?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        content: Text(
          'Are you sure you want to delete "${credential.title}"? This deployment stage cannot be rolled back.',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Invoke targeted logic context drop patterns here
            },
            style: FilledButton.styleFrom(
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06), shape: BoxShape.circle),
              child: Icon(Icons.lock_open_rounded, size: 36, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'No Credentials Yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap the operational deployment workspace button to house secure account keys inside the matrix vault.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}

class _CredentialSearchDelegate extends SearchDelegate<Credential?> {
  final CredentialsController controller;
  final bool isDark;
  _CredentialSearchDelegate(this.controller, this.isDark);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final base = super.appBarTheme(context);
    final pageBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    return base.copyWith(
      scaffoldBackgroundColor: pageBg,
      appBarTheme: base.appBarTheme.copyWith(backgroundColor: pageBg, elevation: 0),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear_rounded, color: Color(0xFF64748B)),
      onPressed: () => query = '',
    ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: isDark ? Colors.white : const Color(0xFF1E293B)),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  List<Credential> _filteredByQuery(List<Credential> source) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return source;
    return source.where((c) {
      return c.title.toLowerCase().contains(q) || c.url.toLowerCase().contains(q) || c.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  Widget _buildList(BuildContext context) {
    return Obx(() {
      final isDarkTheme = isDark;
      final selectedCategory = controller.selectedCategory.value;

      if (query.trim().isEmpty) {
        final allTags = <String, int>{};
        for (final c in controller.credentials) {
          for (final tag in c.tags) {
            final normalized = tag.trim();
            if (normalized.isNotEmpty) {
              allTags[normalized] = (allTags[normalized] ?? 0) + 1;
            }
          }
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.local_offer_rounded, color: Theme.of(context).colorScheme.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search by Tags',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkTheme ? Colors.white : const Color(0xFF0F172A)),
                      ),
                      Text(
                        'Explore secure labels & clusters',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDarkTheme ? Colors.white38 : Colors.black38),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (allTags.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                  decoration: BoxDecoration(
                    color: isDarkTheme ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDarkTheme ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.tag_rounded, size: 36, color: isDarkTheme ? Colors.white24 : Colors.black26),
                      const SizedBox(height: 12),
                      Text(
                        'No tags created yet',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDarkTheme ? Colors.white70 : const Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allTags.entries.map((entry) {
                    final tag = entry.key;
                    final count = entry.value;
                    final tagColor = TagHelper.getTagColor(tag);

                    return Container(
                      decoration: BoxDecoration(
                        color: isDarkTheme ? tagColor.withValues(alpha: 0.06) : tagColor.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: tagColor.withValues(alpha: isDarkTheme ? 0.25 : 0.18), width: 1.2),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => query = tag,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(gradient: TagHelper.getTagGradient(tag), shape: BoxShape.circle),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    '#',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  tag,
                                  style: TextStyle(
                                    color: isDarkTheme ? Colors.white : const Color(0xFF0F172A),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDarkTheme ? Colors.black38 : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: tagColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      }

      var results = controller.credentials.toList();
      if (selectedCategory != null) {
        results = results.where((c) => c.categoryId == selectedCategory.id).toList();
      }
      results = _filteredByQuery(results);

      if (results.isEmpty) {
        return const Center(
          child: Text('No results matching parameters', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: results.length,
        itemBuilder: (context, i) {
          final c = results[i];
          final cat = controller.categoryById(c.categoryId);
          final catColor = cat?.displayColor ?? Theme.of(context).colorScheme.primary;
          final cleanQuery = query.trim().toLowerCase();

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkTheme ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDarkTheme ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                horizontalTitleGap: 12,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: catColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                  child: Icon(cat?.displayIcon ?? Icons.lock_outline_rounded, color: catColor, size: 20),
                ),
                title: Text(
                  c.title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: isDarkTheme ? Colors.white : const Color(0xFF0F172A), fontSize: 14.5),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (c.username.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(c.username, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                    if (c.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: c.tags.map((tag) {
                          final isTagMatch = tag.toLowerCase().contains(cleanQuery);
                          final tagColor = TagHelper.getTagColor(tag);

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isTagMatch
                                  ? tagColor.withValues(alpha: 0.15)
                                  : (isDarkTheme ? const Color(0xFF161F30) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isTagMatch ? tagColor : tagColor.withValues(alpha: isDarkTheme ? 0.25 : 0.15),
                                width: isTagMatch ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '#',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: isTagMatch ? tagColor : (isDarkTheme ? Colors.white38 : Colors.black38),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: isTagMatch ? FontWeight.bold : FontWeight.w500,
                                    color: isDarkTheme ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
                onTap: () {
                  controller.selectedCredential.value = c;
                  close(context, c);
                  Future.microtask(() => Get.toNamed(AppRoutes.credentialDetail));
                },
              ),
            ),
          );
        },
      );
    });
  }
}
