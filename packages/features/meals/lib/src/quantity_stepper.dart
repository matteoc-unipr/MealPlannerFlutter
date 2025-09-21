import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A numeric stepper that allows changing a quantity with undo support.
class QuantityStepper extends StatefulWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.step = 1.0,
    this.min = 0.0,
    this.max,
    this.label,
    this.unitLabel,
    this.precision = 1,
    this.snackBarDuration = const Duration(seconds: 3),
    this.undoLabel = 'Annulla',
  }) : assert(precision >= 0, 'Precision must be zero or positive.');

  /// Current value rendered by the stepper.
  final double value;

  /// Callback triggered whenever the value changes.
  final ValueChanged<double> onChanged;

  /// Amount added or subtracted on each step.
  final double step;

  /// Lower bound for the value.
  final double min;

  /// Optional maximum allowed value.
  final double? max;

  /// Optional label displayed above the control.
  final String? label;

  /// Optional unit appended to the formatted quantity.
  final String? unitLabel;

  /// Number of decimal places used when rounding values.
  final int precision;

  /// Duration for which the undo snackbar remains visible.
  final Duration snackBarDuration;

  /// Label used for the snackbar undo action.
  final String undoLabel;

  @override
  State<QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<QuantityStepper> {
  void _changeBy(double delta) {
    final previous = widget.value;
    var updated = previous + delta;
    updated = _clamp(updated);
    updated = _round(updated);

    if ((updated - previous).abs() < 1e-6) {
      return;
    }

    widget.onChanged(updated);
    _showUndoSnackBar(previous, updated);
  }

  double _clamp(double value) {
    var result = value;
    if (result < widget.min) {
      result = widget.min;
    }
    final max = widget.max;
    if (max != null && result > max) {
      result = max;
    }
    return result;
  }

  double _round(double value) {
    if (widget.precision <= 0) {
      return value.roundToDouble();
    }
    final factor = math.pow(10, widget.precision).toDouble();
    return (value * factor).round() / factor;
  }

  bool get _canDecrement => widget.value - widget.min > 1e-6;

  bool get _canIncrement {
    final max = widget.max;
    if (max == null) {
      return true;
    }
    return max - widget.value > 1e-6;
  }

  void _showUndoSnackBar(double previous, double next) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }

    messenger.hideCurrentSnackBar();
    final formatted = _formatValue(next);
    final unitSuffix = widget.unitLabel != null
        ? ' ${widget.unitLabel!.toLowerCase()}'
        : '';
    messenger.showSnackBar(
      SnackBar(
        duration: widget.snackBarDuration,
        content: Text('Quantità aggiornata a $formatted$unitSuffix'),
        action: SnackBarAction(
          label: widget.undoLabel,
          onPressed: () {
            widget.onChanged(previous);
          },
        ),
      ),
    );
  }

  String _formatValue(double value) {
    if (widget.precision == 0 || value % 1 == 0) {
      return value.toStringAsFixed(0).replaceAll('.', ',');
    }
    return value
        .toStringAsFixed(widget.precision)
        .replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatted = _formatValue(widget.value);
    final unit = widget.unitLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label!,
              style: theme.textTheme.titleMedium,
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surfaceVariant,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _canDecrement ? () => _changeBy(-widget.step) : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  unit == null ? formatted : '$formatted $unit',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _canIncrement ? () => _changeBy(widget.step) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
