import 'package:flutter/material.dart';
import 'package:promoruta/core/constants/colors.dart';

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
    this.borderRadius = 20,
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
    final theme = Theme.of(context);
    final activeColor = widget.activeColor ??
        (theme.brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF0A9995));
    final inactiveColor = widget.inactiveColor ?? theme.colorScheme.onSurface;
    final backgroundColor = widget.backgroundColor ??
        (theme.brightness == Brightness.light
            ? AppColors.grayDarkStroke.withValues(alpha: .60)
            : AppColors.secondaryLight.withValues(alpha: .25));

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius!),
        border: theme.brightness == Brightness.dark
            ? Border.all(color: AppColors.secondaryLight, width: 1)
            : null,
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
                left: (itemWidth * _selectedIndex) + 4,
                top: 4,
                bottom: 4,
                width: itemWidth - 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius:
                        BorderRadius.circular(widget.borderRadius! - 4),
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
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          widget.options[index],
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _selectedIndex == index
                                ? inactiveColor
                                : inactiveColor.withValues(alpha: .6),
                            fontWeight: _selectedIndex == index
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: 13,
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

// Example usage
class MultiSwitchExample extends StatefulWidget {
  const MultiSwitchExample({super.key});

  @override
  State<MultiSwitchExample> createState() => _MultiSwitchExampleState();
}

class _MultiSwitchExampleState extends State<MultiSwitchExample> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Multi Switch Component'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Filter',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            MultiSwitch(
              options: const ['Todas', 'Activas', 'Pendientes', 'Completadas'],
              initialIndex: _selectedIndex,
              onChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Selected: ${[
                'Todas',
                'Activas',
                'Pendientes',
                'Completadas'
              ][_selectedIndex]}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            // Buttons to control from parent
            const Text(
              'Control from parent:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _selectedIndex = 0),
                  child: const Text('Todas'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _selectedIndex = 1),
                  child: const Text('Activas'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _selectedIndex = 2),
                  child: const Text('Pendientes'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _selectedIndex = 3),
                  child: const Text('Completadas'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MultiSwitchExample(),
  ));
}
