import 'package:flutter/material.dart';

class MultiSwitch extends StatefulWidget {
  final List<String> options;
  final int initialIndex;
  final Function(int) onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? backgroundColor;
  final double? height;
  final double? borderRadius;

  const MultiSwitch({
    super.key,
    required this.options,
    this.initialIndex = 0,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.backgroundColor,
    this.height = 50,
    this.borderRadius = 15,
  });

  @override
  State<MultiSwitch> createState() => _MultiSwitchState();
}

class _MultiSwitchState extends State<MultiSwitch> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(MultiSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() {
        _selectedIndex = widget.initialIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? Colors.white;
    final inactiveColor = widget.inactiveColor ?? Colors.black54;
    final backgroundColor = widget.backgroundColor ?? Colors.grey[300];

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius!),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / widget.options.length;

          return Stack(
            children: [
              // Animated marker
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: itemWidth * _selectedIndex,
                top: 4,
                bottom: 4,
                width: itemWidth - 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(widget.borderRadius! - 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Options
              Row(
                children: List.generate(
                  widget.options.length,
                  (index) => Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        widget.onChanged(index);
                      },
                      child: Container(
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: Text(
                          widget.options[index],
                          style: TextStyle(
                            color: _selectedIndex == index
                                ? inactiveColor
                                : inactiveColor.withValues(alpha: .6),
                            fontWeight: _selectedIndex == index
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
