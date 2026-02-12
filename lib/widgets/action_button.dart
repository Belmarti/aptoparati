import 'package:flutter/material.dart';

class ActionButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const ActionButton({super.key, required this.text, required this.onPressed});

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _isHovering = false;
  bool _isPressed = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine visual properties based on state
    Color materialColor = colorScheme.primary;
    double scale = 1.0;

    if (_isPressed) {
      scale = 0.98;
      materialColor = colorScheme.primary.withValues(alpha: 0.9);
    } else if (_isHovering || _isFocused) {
      materialColor = colorScheme.primary; // Or slightly lighter/darker
      scale = 1.02;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: FocusableActionDetector(
          onShowFocusHighlight: (focused) =>
              setState(() => _isFocused = focused),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: scale),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            builder: (context, scaleValue, child) {
              return Transform.scale(
                scale: scaleValue,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: materialColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: (_isHovering || _isFocused) && !_isPressed
                        ? [
                            BoxShadow(
                              color: materialColor.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      widget.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
