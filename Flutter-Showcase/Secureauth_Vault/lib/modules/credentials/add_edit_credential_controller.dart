import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/password_generator.dart';
import '../../models/credential.dart';
import 'credentials_controller.dart'; // Assuming your original controller handles global database syncing

class AddEditCredentialController extends GetxController {
  final CredentialsController _globalCredentialsCtrl = Get.find<CredentialsController>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Expose category list from global state for convenience
  List get categories => _globalCredentialsCtrl.categories;

  // Text Editing Controllers
  late final TextEditingController titleCtrl;
  late final TextEditingController usernameCtrl;
  late final TextEditingController passwordCtrl;
  late final TextEditingController urlCtrl;
  late final TextEditingController notesCtrl;
  late final TextEditingController tagsCtrl;
  late final TextEditingController bankAccountNumberCtrl;
  late final TextEditingController bankIfscCtrl;

  // Reactive State Properties
  final selectedCategoryId = RxnString();
  final showPassword = false.obs;
  final pwStrength = 0.0.obs;

  Credential? _existingCredential;
  bool isEdit = false;

  @override
  void onInit() {
    super.onInit();

    // Determine if we are in Edit Mode based on previous route and global selection
    isEdit = _globalCredentialsCtrl.selectedCredential.value != null && Get.previousRoute == '/credential-detail';

    _existingCredential = isEdit ? _globalCredentialsCtrl.selectedCredential.value : null;

    // Initialize Text Fields
    titleCtrl = TextEditingController(text: _existingCredential?.title ?? '');
    usernameCtrl = TextEditingController(text: _existingCredential?.username ?? '');
    passwordCtrl = TextEditingController(text: _existingCredential?.password ?? '');
    urlCtrl = TextEditingController(text: _existingCredential?.url ?? '');
    notesCtrl = TextEditingController(text: _existingCredential?.notes ?? '');
    tagsCtrl = TextEditingController(text: _existingCredential?.tags.join(', ') ?? '');
    bankAccountNumberCtrl = TextEditingController(text: _existingCredential?.accountNumber ?? '');
    bankIfscCtrl = TextEditingController(text: _existingCredential?.ifscCode ?? '');

    // Initialize Reactive Properties
    selectedCategoryId.value = _existingCredential?.categoryId;
    pwStrength.value = (_existingCredential?.password.isNotEmpty == true) ? PasswordGenerator.strength(_existingCredential!.password) : 0.0;
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    urlCtrl.dispose();
    notesCtrl.dispose();
    tagsCtrl.dispose();
    bankAccountNumberCtrl.dispose();
    bankIfscCtrl.dispose();
    super.onClose();
  }

  bool isBankingCategory(String? categoryId) {
    if (categoryId == null) return false;
    final activeCategory = categories.firstWhereOrNull((c) => c.id == categoryId);
    return activeCategory?.name.toLowerCase().contains('bank') ?? false;
  }

  void handleCategoryChanged(String? newCategoryId) {
    selectedCategoryId.value = newCategoryId;
    // Clear banking buffers safely if the category shifts to non-banking
    if (!isBankingCategory(newCategoryId)) {
      bankAccountNumberCtrl.clear();
      bankIfscCtrl.clear();
    }
  }

  void updatePasswordStrength(String password) {
    pwStrength.value = PasswordGenerator.strength(password);
  }

  void generateSecurePassword() {
    final pwd = PasswordGenerator.generate();
    passwordCtrl.text = pwd;
    updatePasswordStrength(pwd);
  }

  Future<void> saveCredential() async {
    if (!formKey.currentState!.validate()) return;

    try {
      final now = DateTime.now();
      String? finalAccountNumber;
      String? finalIfscCode;

      if (isBankingCategory(selectedCategoryId.value)) {
        finalAccountNumber = bankAccountNumberCtrl.text.trim().isEmpty ? null : bankAccountNumberCtrl.text.trim();

        finalIfscCode = bankIfscCtrl.text.trim().isEmpty ? null : bankIfscCtrl.text.trim().toUpperCase();
      }

      final updatedCred = Credential(
        id: _existingCredential?.id ?? '',
        title: titleCtrl.text.trim(),
        username: usernameCtrl.text.trim(),
        password: passwordCtrl.text,
        url: urlCtrl.text.trim(),
        notes: notesCtrl.text.trim(),
        tags: tagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
        categoryId: selectedCategoryId.value,
        isFavorite: _existingCredential?.isFavorite ?? false,
        createdAt: _existingCredential?.createdAt ?? now,
        updatedAt: now,
        accountNumber: finalAccountNumber,
        ifscCode: finalIfscCode,
      );

      Get.back();

      if (isEdit) {
        await _globalCredentialsCtrl.updateCredential(updatedCred);
      } else {
        await _globalCredentialsCtrl.addCredential(updatedCred);
      }
    } catch (e, s) {
      debugPrint('Save Credential Error: $e');
      debugPrintStack(stackTrace: s);

      Get.snackbar('Error', e.toString());
    }
  }
}
