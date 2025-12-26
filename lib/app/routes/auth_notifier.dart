import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/core/models/user.dart';
import 'package:promoruta/shared/providers/providers.dart';

/// ChangeNotifier that GoRouter can listen to for auth state changes
class GoRouterAuthNotifier extends ChangeNotifier {
  final Ref _ref;
  User? _user;

  GoRouterAuthNotifier(this._ref) {
    // Initialize with current auth state if available
    final currentState = _ref.read(authStateProvider);
    currentState.whenData((user) {
      _user = user;
    });

    // Listen for future changes
    _ref.listen(authStateProvider, (previous, next) {
      next.whenData((user) {
        if (_user?.id != user?.id || _user?.role != user?.role) {
          _user = user;
          notifyListeners();
        }
      });
    });
  }

  User? get user => _user;
}
