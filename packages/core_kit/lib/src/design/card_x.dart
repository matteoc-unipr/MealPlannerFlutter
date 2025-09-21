import 'package:flutter/material.dart';

class CardX extends StatelessWidget {
  const CardX({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.backgroundColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: backgroundColor ?? Theme.of(context).colorScheme.surface,
      elevation: 1,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (margin == null) {
      return card;
    }

    return Padding(
      padding: margin!,
      child: card,
    );
  }
}
