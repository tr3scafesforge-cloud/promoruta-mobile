import 'package:flutter/material.dart';

/// Enum for toast types
enum ToastType {
  success,
  error,
  info,
  warning,
}

/// Represents an action in a dialog
class DialogAction {
  final String label;
  final VoidCallback? onPressed;
  final bool isDefaultAction;

  const DialogAction({
    required this.label,
    this.onPressed,
    this.isDefaultAction = false,
  });
}

/// Abstract notification service interface
abstract class NotificationService {
  /// Shows a toast notification
  void showToast(String message, {
    ToastType type = ToastType.info,
    required BuildContext context,
  });

  /// Shows a dialog notification
  Future<void> showDialog(
    String title,
    String message, {
    List<DialogAction> actions = const [],
    required BuildContext context,
  });
}