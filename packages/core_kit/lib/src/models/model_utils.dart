import 'package:uuid/uuid.dart';

/// Shared UUID generator for immutable model factories.
const Uuid _uuid = Uuid();

/// Returns the provided [id] or generates a new v4 UUID when null.
String generateId([String? id]) => id ?? _uuid.v4();
