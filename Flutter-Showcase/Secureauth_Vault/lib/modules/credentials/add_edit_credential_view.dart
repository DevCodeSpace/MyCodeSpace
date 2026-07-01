import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_edit_credential_controller.dart';

class AddEditCredentialView extends GetView<AddEditCredentialController> {
  const AddEditCredentialView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pageBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final inputBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final headerTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final mainTextColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);

    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: borderCol, width: 1),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
    );

    InputDecoration inputStyle({required String hint, Widget? prefix, Widget? suffix}) {
      return InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w400),
        filled: true,
        fillColor: inputBg,
        prefixIcon: prefix,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: outlineBorder,
        focusedBorder: focusedBorder,
        errorBorder: outlineBorder,
        focusedErrorBorder: focusedBorder,
      );
    }

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: mainTextColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          controller.isEdit ? 'Edit Credential' : 'Add Credential',
          style: TextStyle(color: mainTextColor, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
      ),
      // A single Obx cleanly tracks structural changes across the entire input form hierarchy
      body: Obx(() {
        final isBanking = controller.isBankingCategory(controller.selectedCategoryId.value);
        return Form(
          key: controller.formKey,
          autovalidateMode: AutovalidateMode.onUserInteractionIfError,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              // Title Input
              _buildFieldLabel('CREDENTIAL TITLE *', headerTextColor),
              TextFormField(
                controller: controller.titleCtrl,
                style: TextStyle(color: mainTextColor, fontSize: 15, fontWeight: FontWeight.w500),
                decoration: inputStyle(
                  hint: 'e.g., HDFC Savings Account',
                  prefix: Icon(Icons.label_outline_rounded, color: headerTextColor, size: 20),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
              const SizedBox(height: 20),

              // Category Selection
              _buildFieldLabel('VAULT CATEGORY', headerTextColor),
              DropdownButtonFormField<String>(
                initialValue: controller.selectedCategoryId.value,
                style: TextStyle(color: mainTextColor, fontSize: 15, fontWeight: FontWeight.w500),
                dropdownColor: isDark ? const Color(0xFF161F30) : Colors.white,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: headerTextColor),
                decoration: inputStyle(
                  hint: 'Select a Category',
                  prefix: Icon(Icons.category_outlined, color: headerTextColor, size: 20),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('None', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
                  ),
                  ...controller.categories.map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Row(
                        children: [
                          Icon(c.displayIcon, size: 18, color: c.displayColor),
                          const SizedBox(width: 10),
                          Text(c.name),
                        ],
                      ),
                    ),
                  ),
                ],
                onChanged: controller.handleCategoryChanged,
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Indian Banking Section Matrix Blocks
              // FIXED VALIDATION BLOCK:
              // Using Visibility with maintainState ensures the fields exist in the Form layout matrix permanently.
              Visibility(
                visible: isBanking,
                maintainState: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('BANK ACCOUNT NUMBER', headerTextColor),
                    TextFormField(
                      controller: controller.bankAccountNumberCtrl,
                      style: TextStyle(color: mainTextColor, fontSize: 15, fontWeight: FontWeight.w500),
                      keyboardType: TextInputType.number,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      decoration: inputStyle(
                        hint: 'Enter bank account number',
                        prefix: Icon(Icons.account_balance_wallet_outlined, color: headerTextColor, size: 20),
                      ),
                      validator: (value) {
                        final isBankingCategory = controller.isBankingCategory(controller.selectedCategoryId.value);
                        if (!isBankingCategory) return null;
                        if (value == null || value.trim().isEmpty) {
                          return 'Account number is required';
                        }
                        if (value.trim().isNotEmpty) {
                          final pattern = RegExp(r'^[0-9]{9,18}$');
                          if (!pattern.hasMatch(value.trim())) {
                            return 'Enter a valid account number (9-18 digits)';
                          }
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildFieldLabel('IFSC CODE', headerTextColor),
                    TextFormField(
                      controller: controller.bankIfscCtrl,
                      style: TextStyle(color: mainTextColor, fontSize: 15, fontWeight: FontWeight.w500),
                      textCapitalization: TextCapitalization.characters,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      decoration: inputStyle(
                        hint: 'e.g., HDFC0000123',
                        prefix: Icon(Icons.pin_outlined, color: headerTextColor, size: 20),
                      ),
                      validator: (value) {
                        final isBankingCategory = controller.isBankingCategory(controller.selectedCategoryId.value);

                        if (!isBankingCategory) return null;
                        if (value == null || value.trim().isEmpty) {
                          return 'IFSC code is required';
                        }
                        if (value.trim().isNotEmpty) {
                          final pattern = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

                          if (!pattern.hasMatch(value.trim().toUpperCase())) {
                            return 'Enter a valid IFSC code';
                          }
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Username/Email Input
              _buildFieldLabel('USERNAME OR EMAIL', headerTextColor),
              TextFormField(
                controller: controller.usernameCtrl,
                style: TextStyle(color: mainTextColor, fontSize: 15, fontWeight: FontWeight.w500),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                decoration: inputStyle(
                  hint: 'Enter login identifier',
                  prefix: Icon(Icons.person_outline_rounded, color: headerTextColor, size: 20),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final isBankingCategory = controller.isBankingCategory(controller.selectedCategoryId.value);
                  if (isBankingCategory) return null;
                  if (value == null || value.trim().isEmpty) {
                    return 'Username or email is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password Input with embedded control rules
              _buildFieldLabel('SECURE PASSWORD', headerTextColor),
              TextFormField(
                controller: controller.passwordCtrl,
                obscureText: !controller.showPassword.value,
                style: TextStyle(
                  color: mainTextColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: !controller.showPassword.value ? 2.0 : 0.0,
                ),
                onChanged: controller.updatePasswordStrength,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                decoration: inputStyle(
                  hint: 'Enter banking password / login PIN',
                  prefix: Icon(Icons.lock_outline_rounded, color: headerTextColor, size: 20),
                  suffix: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          controller.showPassword.value ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: headerTextColor,
                          size: 20,
                        ),
                        onPressed: () => controller.showPassword.toggle(),
                      ),
                      IconButton(
                        icon: Icon(Icons.casino_outlined, color: theme.colorScheme.primary, size: 20),
                        tooltip: 'Generate password',
                        onPressed: controller.generateSecurePassword,
                      ),
                    ],
                  ),
                ),
                validator: (value) {
                  final isBankingCategory = controller.isBankingCategory(controller.selectedCategoryId.value);
                  if (isBankingCategory) return null;
                  if (value == null || value.trim().isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
              _StrengthBar(strength: controller.pwStrength.value),
              const SizedBox(height: 20),

              // URL Input
              _buildFieldLabel('ACCESS URL', headerTextColor),
              TextFormField(
                controller: controller.urlCtrl,
                style: TextStyle(color: mainTextColor, fontSize: 15, fontWeight: FontWeight.w500),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                decoration: inputStyle(
                  hint: 'https://onlinesbi.sbi',
                  prefix: Icon(Icons.link_rounded, color: headerTextColor, size: 20),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 20),

              // Tags Matrix Input
              _buildFieldLabel('TAGS', headerTextColor),
              TextFormField(
                controller: controller.tagsCtrl,
                style: TextStyle(color: mainTextColor, fontSize: 15, fontWeight: FontWeight.w500),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                decoration: inputStyle(
                  hint: 'personal, bank, active (comma separated)',
                  prefix: Icon(Icons.local_offer_outlined, color: headerTextColor, size: 20),
                ),
              ),
              const SizedBox(height: 20),

              // Notes Text Block Area
              _buildFieldLabel('ADDITIONAL NOTES', headerTextColor),
              TextFormField(
                controller: controller.notesCtrl,
                style: TextStyle(color: mainTextColor, fontSize: 15, fontWeight: FontWeight.w500),
                maxLines: 4,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                decoration: inputStyle(
                  hint: 'Append customer ID, branch details, or security tokens...',
                  prefix: Padding(
                    padding: const EdgeInsets.only(bottom: 64),
                    child: Icon(Icons.note_alt_outlined, color: headerTextColor, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              FilledButton(
                onPressed: controller.saveCredential,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Credential', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFieldLabel(String labelText, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        labelText,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: color),
      ),
    );
  }
}

class _StrengthBar extends StatelessWidget {
  final double strength;
  const _StrengthBar({required this.strength});

  Color get _color {
    if (strength < 0.4) return const Color(0xFFEF4444);
    if (strength < 0.7) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String get _label {
    if (strength == 0) return '';
    if (strength < 0.4) return 'Weak Strength';
    if (strength < 0.7) return 'Fair Quality';
    return 'Highly Secure';
  }

  @override
  Widget build(BuildContext context) {
    if (strength == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 4, right: 4),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: strength,
                color: _color,
                backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                minHeight: 5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _color, letterSpacing: 0.2),
          ),
        ],
      ),
    );
  }
}
