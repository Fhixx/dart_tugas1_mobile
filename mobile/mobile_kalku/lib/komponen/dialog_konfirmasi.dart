import 'package:flutter/material.dart';

import '../inti/konstanta/warna_aplikasi.dart';
import '../inti/konstanta/dimensi_aplikasi.dart';
import '../inti/konstanta/teks_aplikasi.dart';

/// Reusable confirmation dialog for destructive/irreversible actions
/// (delete BMI, logout, exit app) per DESIGN_SYSTEM.md #19.
///
/// Button order is always: Batal, then the action — the destructive
/// action must not be the default focus without reason.
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.isDestructive = true,
    this.cancelLabel = AppStrings.dialogCancel,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  /// Shows the dialog and returns `true` if the user confirmed,
  /// `false`/`null` if cancelled or dismissed.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool isDestructive = true,
    String cancelLabel = AppStrings.dialogCancel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        isDestructive: isDestructive,
        cancelLabel: cancelLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusModal),
      ),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      content: Text(message, style: const TextStyle(color: AppColors.textSecondary)),
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space8,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel, style: const TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmLabel,
            style: TextStyle(
              color: isDestructive ? AppColors.danger : AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
