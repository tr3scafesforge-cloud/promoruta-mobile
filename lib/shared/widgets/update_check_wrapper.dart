import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import 'update_dialog.dart';

class UpdateCheckWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const UpdateCheckWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<UpdateCheckWrapper> createState() => _UpdateCheckWrapperState();
}

class _UpdateCheckWrapperState extends ConsumerState<UpdateCheckWrapper> {
  bool _hasCheckedForUpdate = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(updateCheckProvider, (previous, next) {
      if (_hasCheckedForUpdate) return;

      next.whenData((versionInfo) {
        if (versionInfo != null && mounted) {
          _hasCheckedForUpdate = true;
          UpdateDialog.show(context, versionInfo);
        }
      });
    });

    return widget.child;
  }
}
