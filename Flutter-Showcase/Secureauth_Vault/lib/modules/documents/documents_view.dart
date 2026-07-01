import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../models/document_folder.dart';
import '../../models/document_model.dart';
import 'documents_controller.dart';

class DocumentsView extends GetView<DocumentsController> {
  const DocumentsView({super.key});

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
          'Documents',
          style: TextStyle(color: titleColor, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
            onPressed: () => showSearch(context: context, delegate: _DocSearchDelegate(controller, isDark)),
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
            // Folders Title Bar Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FOLDERS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                      ),
                    ),
                    InkWell(
                      onTap: () => _showCreateFolderDialog(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.create_new_folder_outlined, size: 16, color: theme.colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              'New Folder',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Folders Dynamic Grid
            if (controller.folders.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Center(
                    child: Text(
                      'No custom folders created yet.',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black.withValues(alpha: 0.15) : const Color(0xFF0F172A).withValues(alpha: 0.02),
                          blurRadius: 16,
                          spreadRadius: -4,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            clipBehavior: Clip.hardEdge,
                            itemCount: (controller.folders.length > 3 ? 3 : controller.folders.length),
                            itemBuilder: (context, index) {
                              final folder = controller.folders[index];
                              final count = controller.documents.where((d) => d.folderId == folder.id).length;
                              return FolderRow(
                                folder: folder,
                                fileCount: count,
                                onTap: () => controller.selectFolder(folder.id),
                                onDelete: () => controller.deleteFolder(folder),
                              );
                            },
                          ),

                          // 2. Conditionally show the "Show More / Less" row inside the card
                          if (controller.folders.length > 3)
                            Material(
                              color: Colors.transparent,
                              clipBehavior: Clip.hardEdge,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Show More',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.keyboard_arrow_right_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Recent Files Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 16, 4),
                child: Text(
                  'RECENT FILES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),

            // Files Grid Matrix
            controller.filtered.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(padding: const EdgeInsets.only(top: 40), child: buildEmptyState(context)),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => DocCard(doc: controller.filtered[i], controller: controller),
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
            heroTag: 'documents_fab',
            elevation: 4,
            highlightElevation: 1,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            onPressed: () => _showAddSheet(context),
            icon: const Icon(Icons.add_rounded, size: 22),
            label: const Text('Add New', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.2)),
          ),
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 12),
            _buildActionSheetRow(
              context,
              icon: Icons.create_new_folder_outlined,
              iconColor: const Color(0xFF3B82F6),
              title: 'Create Folder',
              onTap: () => _showCreateFolderDialog(context),
            ),
            _buildActionSheetRow(
              context,
              icon: Icons.upload_file_rounded,
              iconColor: const Color(0xFF6366F1),
              title: 'Import Secure File',
              onTap: () => _pickFolderAndRun(context, (folderId) => controller.pickAndSaveFile(folderId: folderId)),
            ),
            _buildActionSheetRow(
              context,
              icon: Icons.camera_alt_rounded,
              iconColor: const Color(0xFF14B8A6),
              title: 'Scan Document / Photo',
              onTap: () => _pickFolderAndRun(context, (folderId) => controller.pickImageFromCamera(folderId: folderId)),
            ),
            _buildActionSheetRow(
              context,
              icon: Icons.photo_library_rounded,
              iconColor: const Color(0xFFA855F7),
              title: 'Choose from Gallery',
              onTap: () => _pickFolderAndRun(context, (folderId) => controller.pickImageFromGallery(folderId: folderId)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSheetRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      horizontalTitleGap: 12,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B)),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _pickFolderAndRun(BuildContext context, Future<void> Function(String? folderId) action) {
    final folders = controller.folders.toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Destination',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.folder_off_rounded, color: Colors.grey, size: 20),
                    ),
                    title: const Text('Root Directory', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                    subtitle: const Text('Store outside any explicit folder', style: TextStyle(fontSize: 12)),
                    onTap: () {
                      Navigator.pop(context);
                      action(null);
                    },
                  ),
                  ...folders.map(
                    (folder) => ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.folder_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                      ),
                      title: Text(folder.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                      onTap: () {
                        Navigator.pop(context);
                        action(folder.id);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateFolderDialog(BuildContext context) async {
    var folderName = '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        title: const Text('Create Folder', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: -0.3)),
        content: TextField(
          autofocus: true,
          textInputAction: TextInputAction.done,
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
          decoration: InputDecoration(
            labelText: 'Folder Name',
            hintText: 'e.g., Personal Docs',
            prefixIcon: const Icon(Icons.folder_open_rounded, size: 20),
            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            filled: true,
            fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
          onChanged: (value) => folderName = value,
          onSubmitted: (_) async {
            final created = await controller.createFolder(folderName);
            if (created && dialogContext.mounted) Navigator.pop(dialogContext);
          },
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
          ),
          FilledButton(
            onPressed: () async {
              final created = await controller.createFolder(folderName);
              if (created && dialogContext.mounted) Navigator.pop(dialogContext);
            },
            style: FilledButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Create', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState(BuildContext context) {
    final selectedFolderName = controller.folderNameById(controller.selectedFolderId.value);
    final title = selectedFolderName == null ? 'No Documents Yet' : 'Empty Folder';
    final subtitle = selectedFolderName == null
        ? 'Import records, images, or assets directly into your client-side encrypted vault.'
        : 'Tap the workflow menu action path to drop items into "$selectedFolderName"';
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
              child: Icon(Icons.folder_open_rounded, size: 36, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Secondary Modular UI Subcomponents ───────────────────────────────────────

class FolderRow extends StatelessWidget {
  final DocumentFolder folder;
  final int fileCount;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const FolderRow({super.key, required this.folder, required this.fileCount, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 0, 4),
        child: Row(
          children: [
            Icon(Icons.folder_open_rounded, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    folder.name,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    fileCount == 0 ? 'Empty' : '$fileCount ${fileCount == 1 ? 'file' : 'files'}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.more_vert_rounded, size: 18, color: Color(0xFF64748B)),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DocCard extends StatelessWidget {
  final DocumentModel doc;
  final DocumentsController controller;
  final bool showFolderName;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onSelectToggle; // Made nullable for screens without selection

  const DocCard({
    super.key,
    required this.doc,
    required this.controller,
    this.showFolderName = true,
    this.isSelectionMode = false, // Defaulted to false
    this.isSelected = false, // Defaulted to false
    this.onSelectToggle, // Optional parameter
  });

  IconData get _icon {
    switch (doc.type) {
      case DocumentType.pdf:
        return Icons.picture_as_pdf_rounded;
      case DocumentType.image:
        return Icons.image_rounded;
      case DocumentType.video:
        return Icons.video_file_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _color() {
    switch (doc.type) {
      case DocumentType.pdf:
        return const Color(0xFFFF4D4D); // Vibrant coral red
      case DocumentType.image:
        return const Color(0xFF2563EB); // Modern Royal blue
      case DocumentType.video:
        return const Color(0xFF7C3AED); // Deep premium violet
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    final borderCol = (isSelectionMode && isSelected)
        ? Theme.of(context).colorScheme.primary
        : (isDark ? const Color(0xFF334155).withValues(alpha: 0.4) : const Color(0xFFF1F5F9));

    final accentColor = _color();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol, width: (isSelectionMode && isSelected) ? 2.0 : 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isSelectionMode ? onSelectToggle : () => _showDetail(context),
          onLongPress: isSelectionMode ? null : _showOptions,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // File Preview Container Space
                    Positioned.fill(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                        child: doc.type == DocumentType.image
                            ? ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                                child: ImagePreview(doc: doc, controller: controller, fallbackColor: accentColor, fallbackIcon: _icon),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 1),
                                ),
                                child: Center(child: Icon(_icon, size: 28, color: accentColor)),
                              ),
                      ),
                    ),

                    // Floating selection checkbox indicator overlay
                    if (isSelectionMode)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Icon(Icons.check_rounded, size: 14, color: isSelected ? Colors.white : Colors.transparent),
                        ),
                      ),
                  ],
                ),
              ),

              // const SizedBox(height: 4),

              // Metadata block
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      doc.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                      ),
                    ),
                    // const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (showFolderName && doc.folderId != null)
                          Flexible(
                            child: Text(
                              controller.folderNameById(doc.folderId)?.toUpperCase() ?? '',
                              style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: accentColor, letterSpacing: 0.4),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        // else
                        //   const Spacer(),
                        Text(
                          doc.sizeFormatted,
                          style: TextStyle(
                            fontSize: 9.5,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    if (doc.type == DocumentType.image) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _ImageViewerScreen(doc: doc, controller: controller),
        ),
      );
    } else {
      Get.snackbar(
        'Document Info',
        'Open ${doc.name} (${doc.sizeFormatted}) — export to view outside SecureAuth Vault',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showOptions() {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    Get.bottomSheet(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(3)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
              title: const Text(
                'Delete Document',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 14.5),
              ),
              onTap: () {
                Get.back();
                controller.deleteSingleDocument(doc);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class ImagePreview extends StatefulWidget {
  final DocumentModel doc;
  final DocumentsController controller;
  final Color fallbackColor;
  final IconData fallbackIcon;

  const ImagePreview({super.key, required this.doc, required this.controller, required this.fallbackColor, required this.fallbackIcon});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  Uint8List? _bytes;
  bool _hasError = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Defend against state identity updates within structural Obx updates
  @override
  void didUpdateWidget(ImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.doc.id != widget.doc.id) {
      _load();
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final bytes = await widget.controller.readDecryptedBytes(widget.doc);
      if (mounted) {
        setState(() {
          _bytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show structural icon layout if an error occurs or decryption breaks
    if (_hasError) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: widget.fallbackColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Icon(widget.fallbackIcon, size: 30, color: widget.fallbackColor),
      );
    }

    // Loader container with an image icon silhouette background so it doesn't stay blank
    if (_isLoading || _bytes == null) {
      return Container(
        height: 76,
        width: 108,
        decoration: BoxDecoration(
          color: widget.fallbackColor.withValues(alpha: 0.04),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Icon(widget.fallbackIcon, size: 26, color: widget.fallbackColor.withValues(alpha: 0.25)),
      );
    }

    // Clean decrypted preview image asset frame
    return Image.memory(
      _bytes!,
      height: 76,
      width: 108,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: widget.fallbackColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Icon(widget.fallbackIcon, size: 30, color: widget.fallbackColor),
        );
      },
    );
  }
}

class _ImageViewerScreen extends StatefulWidget {
  final DocumentModel doc;
  final DocumentsController controller;
  const _ImageViewerScreen({required this.doc, required this.controller});

  @override
  State<_ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<_ImageViewerScreen> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bytes = await widget.controller.readDecryptedBytes(widget.doc);
    if (mounted) setState(() => _bytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(widget.doc.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: Center(
        child: _bytes == null
            ? const CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
            : InteractiveViewer(clipBehavior: Clip.none, maxScale: 4.0, child: Image.memory(_bytes!)),
      ),
    );
  }
}

class _DocSearchDelegate extends SearchDelegate<DocumentModel?> {
  final DocumentsController controller;
  final bool isDark;
  _DocSearchDelegate(this.controller, this.isDark);

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

  List<DocumentModel> _filteredDocuments(List<DocumentModel> source) {
    var list = source;
    final folderId = controller.selectedFolderId.value;
    if (folderId != null) list = list.where((d) => d.folderId == folderId).toList();

    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) list = list.where((d) => d.name.toLowerCase().contains(q)).toList();
    return list;
  }

  Widget _buildList(BuildContext context) {
    return Obx(() {
      final results = _filteredDocuments(controller.documents);
      if (results.isEmpty) {
        return Center(
          child: Text('No results matching parameters', style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: results.length,
        itemBuilder: (context, i) {
          final d = results[i];
          final folderName = controller.folderNameById(d.folderId);
          final folderPart = folderName == null ? '' : ' • $folderName';

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              horizontalTitleGap: 12,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.insert_drive_file_outlined, color: Theme.of(context).colorScheme.primary, size: 18),
              ),
              title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
              subtitle: Text(
                '${d.sizeFormatted} • ${DateFormat.yMMMd().format(d.createdAt)}$folderPart',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
          );
        },
      );
    });
  }
}
