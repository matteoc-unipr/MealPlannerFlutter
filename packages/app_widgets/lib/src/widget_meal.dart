import 'dart:collection';

import 'package:meta/meta.dart';

/// Immutable description of a meal to be displayed inside a platform widget.
@immutable
class WidgetMeal {
  const WidgetMeal({
    required this.id,
    required this.title,
    required this.scheduledAt,
    this.description,
    List<String> items = const <String>[],
  }) : _items = List.unmodifiable(items);

  /// Unique identifier for the meal.
  final String id;

  /// Short title rendered inside the widget.
  final String title;

  /// Optional description or subtitle providing more context.
  final String? description;

  /// When the meal is planned to happen.
  final DateTime scheduledAt;

  final List<String> _items;

  /// Items that compose the meal. The list is unmodifiable to keep
  /// [WidgetMeal] instances immutable.
  List<String> get items => UnmodifiableListView<String>(_items);

  /// Serializes the meal so it can be sent through a platform channel.
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'title': title,
        'description': description,
        'scheduledAt': scheduledAt.toIso8601String(),
        'items': List<String>.from(_items),
      };

  /// Deserializes a map that was received from a platform channel.
  factory WidgetMeal.fromMap(Map<dynamic, dynamic> map) {
    final Object? rawScheduledAt = map['scheduledAt'];
    final DateTime scheduledAt;
    if (rawScheduledAt is String) {
      scheduledAt = DateTime.parse(rawScheduledAt);
    } else if (rawScheduledAt is int) {
      scheduledAt = DateTime.fromMillisecondsSinceEpoch(rawScheduledAt);
    } else {
      throw ArgumentError(
        'Unsupported scheduledAt value: $rawScheduledAt',
      );
    }

    final Object? rawItems = map['items'];
    final List<String> items;
    if (rawItems == null) {
      items = const <String>[];
    } else if (rawItems is List) {
      items = rawItems.map((Object? e) => e?.toString() ?? '').toList();
    } else {
      throw ArgumentError('Unsupported items value: $rawItems');
    }

    return WidgetMeal(
      id: map['id']?.toString() ?? 'unknown',
      title: map['title']?.toString() ?? 'Prossimo pasto',
      description: map['description']?.toString(),
      scheduledAt: scheduledAt,
      items: items,
    );
  }

  /// Provides a deterministic mock meal, useful while native integrations are
  /// still stubs.
  factory WidgetMeal.mock({DateTime? now}) {
    final DateTime current = now ?? DateTime.now();
    DateTime scheduledAt = DateTime(
      current.year,
      current.month,
      current.day,
      12,
      30,
    );

    if (!scheduledAt.isAfter(current)) {
      scheduledAt = DateTime(
        current.year,
        current.month,
        current.day,
        19,
        30,
      );
    }

    return WidgetMeal(
      id: 'mock-next-meal',
      title: 'Prossimo pasto',
      description: 'Suggerimento automatico dal planner.',
      scheduledAt: scheduledAt,
      items: const <String>[
        'Insalata di quinoa',
        'Yogurt greco con frutta',
        'Tè verde',
      ],
    );
  }
}
