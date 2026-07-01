import 'package:authenticator/modules/documents/documents_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'documents_controller.dart';

class FolderView extends GetView<DocumentsController> {
  const FolderView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pageBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    final currentFolder = controller.folders.firstWhereOrNull((f) => f.id == controller.selectedFolderId.value);

    return Obx(() {
      final bool editing = controller.isEditMode.value;

      return Scaffold(
        backgroundColor: pageBg,
        appBar: AppBar(
          backgroundColor: pageBg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(editing ? Icons.close_rounded : Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: editing ? controller.toggleEditMode : Get.back,
          ),
          // title: Text(editing ? '${controller.selectedDocIds.length} Selected' : (currentFolder?.name ?? 'Folder View')),
          title: Text(currentFolder?.name ?? 'Folder View'),
          actions: [
            // Edit Toggle Button
            if (controller.filtered.isNotEmpty)
              TextButton(
                onPressed: controller.toggleEditMode,
                child: Text(editing ? 'Cancel' : 'Select', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            if (!editing)
              IconButton(
                onPressed: () => controller.showDeleteFolderDialog(context),
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              )
            else
              IconButton(
                onPressed: () => _confirmBatchDelete(),
                icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
              ),
          ],
        ),
        body: controller.filtered.isEmpty
            ? buildEmptyState(context)
            : Stack(
                children: [
                  GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120), // Left room for action bars
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: controller.filtered.length,
                    itemBuilder: (context, i) {
                      final doc = controller.filtered[i];
                      return Obx(() {
                        final isSelected = controller.selectedDocIds.contains(doc.id);
                        return DocCard(
                          doc: doc,
                          controller: controller,
                          showFolderName: false,
                          isSelectionMode: editing,
                          isSelected: isSelected,
                          onSelectToggle: () => controller.toggleSelection(doc.id),
                        );
                      });
                    },
                  ),

                  // Bottom Batch Actions Sheet panel
                  if (editing && controller.selectedDocIds.isNotEmpty)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 24,
                      child: SafeArea(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 1),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${controller.selectedDocIds.length} file${controller.selectedDocIds.length != 1 ? 's' : ''} selected',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                              ),
                              TextButton.icon(
                                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                                onPressed: _confirmBatchDelete,
                                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                label: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      );
    });
  }

  void _confirmBatchDelete() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Selected Files?'),
        content: Text(
          'Are you sure you want to permanently delete these ${controller.selectedDocIds.length} documents? This action cannot be reversed.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteSelectedDocuments();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
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
