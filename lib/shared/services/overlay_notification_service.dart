import 'package:flutter/material.dart';
import 'package:promoruta/shared/services/notification_service.dart';
import 'package:toastification/toastification.dart';

/// Implementation of NotificationService using overlay entries
class OverlayNotificationService implements NotificationService {
  final GlobalKey<NavigatorState> navigatorKey;

  OverlayNotificationService(this.navigatorKey);

  @override
  void showToast(
    String message, {
    ToastType type = ToastType.info,
    required BuildContext context,
  }) {
    // Use toastification for enhanced toast notifications
    toastification.show(
      context: context,
      type: _getToastificationType(type),
      style: ToastificationStyle.flat,
      title: Text(message),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(8),
      showProgressBar: false,
      closeButton: ToastCloseButton(
        showType: CloseButtonShowType.always,
      ),
      dragToClose: true,
    );
  }

  ToastificationType _getToastificationType(ToastType type) {
    switch (type) {
      case ToastType.success:
        return ToastificationType.success;
      case ToastType.error:
        return ToastificationType.error;
      case ToastType.warning:
        return ToastificationType.warning;
      case ToastType.info:
        return ToastificationType.info;
    }
  }

  @override
  Future<void> showDialog(
    String title,
    String message, {
    List<DialogAction> actions = const [],
    required BuildContext context,
  }) async {
    await showAdaptiveDialog(
      context: context,
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
