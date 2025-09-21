import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Handles local notifications related to shopping reminders.
class NotificationManager {
  NotificationManager(
    this._plugin, {
    tz.Location? location,
    DateTime Function()? now,
  })  : _location = location,
        _now = now ?? DateTime.now;

  final FlutterLocalNotificationsPlugin _plugin;
  final DateTime Function() _now;
  tz.Location? _location;

  /// Identifier used for shopping reminder notifications.
  static const String shoppingChannelId = 'shopping_reminders';
  static const String shoppingChannelName = 'Promemoria spesa';
  static const String shoppingChannelDescription =
      'Ricorda all\'utente di prepararsi per il prossimo giorno di spesa.';

  /// Updates the timezone location used to schedule notifications.
  void setLocation(tz.Location location) {
    _location = location;
  }

  /// Schedules a reminder the day before [shoppingDate] at 18:30.
  Future<void> scheduleShoppingReminder(
    DateTime shoppingDate, {
    int notificationId = 1001,
    String? title,
    String? body,
  }) async {
    final location = _location ?? tz.local;
    final scheduledTime = _resolveScheduleTime(shoppingDate, location);
    final now = tz.TZDateTime.from(_now(), location);

    if (!scheduledTime.isAfter(now)) {
      // Avoid scheduling notifications in the past.
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      shoppingChannelId,
      shoppingChannelName,
      channelDescription: shoppingChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    await _plugin.zonedSchedule(
      notificationId,
      title ?? 'Promemoria spesa',
      body ?? 'Domani alle 18:30 prepara la lista per la spesa.',
      scheduledTime,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  tz.TZDateTime _resolveScheduleTime(DateTime shoppingDate, tz.Location location) {
    final reminderDay = shoppingDate.subtract(const Duration(days: 1));
    final base = DateTime(
      reminderDay.year,
      reminderDay.month,
      reminderDay.day,
      18,
      30,
    );
    return tz.TZDateTime.from(base, location);
  }
}
