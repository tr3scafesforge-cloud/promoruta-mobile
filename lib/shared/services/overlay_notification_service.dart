import 'package:flutter/material.dart';
import 'package:promoruta/shared/services/notification_service.dart';

/// Implementation of NotificationService using overlay entries
class OverlayNotificationService implements NotificationService {
  final GlobalKey<NavigatorState> navigatorKey;

  OverlayNotificationService(this.navigatorKey);

  @override
  void showToast(
    String message, {
    ToastType type = ToastType.info,
    BuildContext? context,
  }) {
    final targetContext = context ?? navigatorKey.currentContext;
    if (targetContext == null) return;

    // Use ScaffoldMessenger for toasts as it's more reliable
    ScaffoldMessenger.of(targetContext).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getIconForType(type), color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: _getColorForType(type, targetContext),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  IconData _getIconForType(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
        return Icons.info;
    }
  }

  Color _getColorForType(ToastType type, BuildContext context) {
    final theme = Theme.of(context);
    switch (type) {
      case ToastType.success:
        return Colors.green;
      case ToastType.error:
        return theme.colorScheme.error;
      case ToastType.warning:
        return Colors.orange;
      case ToastType.info:
        return theme.colorScheme.primary;
    }
  }

  @override
  Future<void> showDialog(
    String title,
    String message, {
    List<DialogAction> actions = const [],
    BuildContext? context,
  }) async {
    final targetContext = context ?? navigatorKey.currentContext;
    if (targetContext == null) return;

    await showAdaptiveDialog(
      context: targetContext,
      builder: (context) => AlertDialog.adaptive(
        title: Text(title),
        content: Text(message),
        actions: actions.map((action) {
          return TextButton(
            onPressed: () {
              action.onPressed?.call();
              Navigator.of(context).pop();
            },
            child: Text(action.label),
          );
        }).toList(),
      ),
    );
  }
}
