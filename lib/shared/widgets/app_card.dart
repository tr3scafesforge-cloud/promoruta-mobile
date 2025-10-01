import 'package:flutter/material.dart';
import 'package:promoruta/core/constants/colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool hasBorder;

  const AppCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: hasBorder
              ? const BorderSide(
                  color: AppColors.grayDarkStroke,
                  width: 1,
                )
              : BorderSide.none,
        ),
        child: padding != null ? Padding(padding: padding!, child: child) : child,
      ),
    );
  }
}