import 'package:flutter/material.dart';

abstract final class AppShapes {
  static const BorderRadius buttonRadius =
      BorderRadius.all(Radius.circular(10));

  static const BorderRadius dialogRadius =
      BorderRadius.all(Radius.circular(12));

  static RoundedRectangleBorder fabShape({BorderSide side = BorderSide.none}) {
    return const RoundedRectangleBorder(
      borderRadius: buttonRadius,
    ).copyWith(side: side);
  }
}
