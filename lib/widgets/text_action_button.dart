import 'package:flutter/material.dart';

class TextActionButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const TextActionButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<TextActionButton> createState() => _TextActionButtonState();
}

class _TextActionButtonState extends State<TextActionButton> {
  bool _isHovering = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: FocusableActionDetector(
          onShowFocusHighlight: (focused) =>
              setState(() => _isFocused = focused),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _isHovering || _isFocused
                  ? colorScheme.primary
                  : Colors.grey[700],
              decoration: _isHovering || _isFocused
                  ? TextDecoration.underline
                  : TextDecoration.none,
              decorationColor: colorScheme.primary,
            ),
            child: Text(widget.text),
          ),
        ),
      ),
    );
  }
}
