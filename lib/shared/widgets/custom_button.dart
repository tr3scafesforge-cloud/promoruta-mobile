import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final VoidCallback onPressed;
  final Color textColor;
  final bool isOutlined;
  final Color? outlineColor;
  final bool shrinkToFit;

  const CustomButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.onPressed,
    this.textColor = Colors.white,
    this.isOutlined = false,
    this.outlineColor,
    this.shrinkToFit = false,
  });

  static CustomButton outlined({
    required String text,
    required Color backgroundColor,
    required Color outlineColor,
    required VoidCallback onPressed,
    required Color textColor,
  }) {
    return CustomButton(
      text: text,
      backgroundColor: backgroundColor,
      onPressed: onPressed,
      textColor: textColor,
      isOutlined: true,
      outlineColor: outlineColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      width: double.infinity,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: isOutlined
                ? Border.all(color: outlineColor ?? backgroundColor, width: 1)
                : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: shrinkToFit
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    text,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }
}
