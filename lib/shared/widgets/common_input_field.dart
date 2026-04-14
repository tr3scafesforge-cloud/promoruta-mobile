import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:promoruta/core/constants/colors.dart';

class CommonInputField extends StatelessWidget {
  const CommonInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
    this.headIcon,
    this.onHeadIconPressed,
    this.tailIcon,
    this.onTailIconPressed,
    this.suffixIcon,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final TextEditingController controller;
  final String hintText;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;
  final IconData? headIcon;
  final VoidCallback? onHeadIconPressed;
  final IconData? tailIcon;
  final VoidCallback? onTailIconPressed;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry contentPadding;

  Widget? _buildIconButton({
    required IconData? icon,
    required VoidCallback? onPressed,
  }) {
    if (icon == null) {
      return null;
    }

    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.textHint),
      splashRadius: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: _buildIconButton(
          icon: headIcon,
          onPressed: onHeadIconPressed,
        ),
        suffixIcon: suffixIcon ??
            _buildIconButton(
              icon: tailIcon,
              onPressed: onTailIconPressed,
            ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.grayStroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.grayStroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        contentPadding: contentPadding,
      ),
    );
  }
}
