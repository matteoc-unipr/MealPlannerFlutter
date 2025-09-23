import 'dart:collection';

import 'package:meta/meta.dart';

/// Base class for all application level intents exposed to the platform.
@immutable
abstract class AppIntent {
  const AppIntent({
    required this.id,
    required this.name,
    required this.deepLink,
    this.description,
    List<String> keywords = const <String>[],
  }) : _keywords = List.unmodifiable(keywords);

  /// Unique identifier used across platforms (Android shortcuts, iOS intents).
  final String id;

  /// Human readable name shown to the user when selecting the shortcut.
  final String name;

  /// Optional description that can be displayed on the platform side.
  final String? description;

  /// The deep link that should be opened when the intent is triggered.
  final Uri deepLink;

  final List<String> _keywords;

  /// Keywords that can help platforms surface the intent via search.
  List<String> get keywords => UnmodifiableListView<String>(_keywords);

  /// Serializes the intent so it can be passed to the platform.
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'name': name,
        'description': description,
        'deepLink': deepLink.toString(),
        if (_keywords.isNotEmpty) 'keywords': List<String>.from(_keywords),
      };

  /// Maps the intent to a structure that mirrors Android's ShortcutInfo
  /// requirements.
  Map<String, dynamic> toAndroidShortcut({
    String? shortLabel,
    String? longLabel,
    String? iconName,
    int? rank,
  }) {
    return <String, dynamic>{
      'id': id,
      'shortLabel': shortLabel ?? name,
      'longLabel': longLabel ?? description ?? name,
      'intentAction': 'android.intent.action.VIEW',
      'uri': deepLink.toString(),
      'categories': const <String>['assistente.intent.shortcut'],
      if (iconName != null) 'icon': iconName,
      if (rank != null) 'rank': rank,
      if (_keywords.isNotEmpty) 'keywords': List<String>.from(_keywords),
    };
  }
}

/// Intent used to add a new meal to the planner.
class AddMealIntent extends AppIntent {
  const AddMealIntent()
      : super(
          id: 'add_meal',
          name: 'Aggiungi pasto',
          description: 'Registra rapidamente un nuovo pasto',
          deepLink: Uri.parse('assistente://meals/add'),
          keywords: const <String>['meal', 'aggiungi', 'pasto'],
        );
}

/// Intent that suggests lunch ideas to the user.
class SuggestLunchIntent extends AppIntent {
  const SuggestLunchIntent()
      : super(
          id: 'suggest_lunch',
          name: 'Suggerisci pranzo',
          description: 'Ricevi un suggerimento equilibrato per il pranzo',
          deepLink: Uri.parse('assistente://suggestions/lunch'),
          keywords: const <String>['pranzo', 'suggerimento', 'idee'],
        );
}
