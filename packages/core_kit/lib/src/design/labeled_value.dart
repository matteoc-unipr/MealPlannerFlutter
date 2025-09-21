import 'package:flutter/material.dart';

class LabeledValue extends StatelessWidget {
  const LabeledValue({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.spacing = 4,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.labelStyle,
    this.valueStyle,
  });

  final String label;
  final String value;
  final Widget? icon;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: labelStyle ??
              theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
        ),
        SizedBox(height: spacing),
        Text(
          value,
          style: valueStyle ?? theme.textTheme.titleMedium,
        ),
      ],
    );

    if (icon == null) {
      return content;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon!,
        const SizedBox(width: 8),
        Flexible(child: content),
      ],
    );
  }
}
