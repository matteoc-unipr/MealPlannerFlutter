import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final Widget button;
    if (icon != null) {
      button = FilledButton.icon(
        onPressed: onPressed,
        icon: icon!,
        label: Text(label),
      );
    } else {
      button = FilledButton(
        onPressed: onPressed,
        child: Text(label),
      );
    }

    if (!expanded) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }
}
