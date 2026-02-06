import 'package:flutter/material.dart';

/// A reusable confirmation dialog widget.
class ConfirmDialogWidget extends StatelessWidget {
  const ConfirmDialogWidget({
    super.key,
    required this.title,
    required this.content,
    required this.confirmText,
    required this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.confirmButtonStyle,
  });

  /// Dialog title.
  final String title;

  /// Dialog content message.
  final String content;

  /// Text for confirm button.
  final String confirmText;

  /// Text for cancel button.
  final String cancelText;

  /// Callback when confirm is pressed.
  final VoidCallback? onConfirm;

  /// Callback when cancel is pressed.
  final VoidCallback? onCancel;

  /// Optional style for confirm button.
  final ButtonStyle? confirmButtonStyle;

  /// Shows the confirmation dialog and returns the result.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
    ButtonStyle? confirmButtonStyle,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialogWidget(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmButtonStyle: confirmButtonStyle,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
          style: confirmButtonStyle ??
              TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
