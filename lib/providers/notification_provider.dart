import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, DateTime>((ref) {
  return NotificationNotifier();
});

class NotificationNotifier extends StateNotifier<DateTime> {
  NotificationNotifier() : super(DateTime.now()) {
    _loadLastNotificationDate();
    _setupPeriodicCheck();
  }

  Future<void> _loadLastNotificationDate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastNotificationTimestamp = prefs.getInt('lastNotificationDate');
    if (lastNotificationTimestamp != null) {
      state = DateTime.fromMillisecondsSinceEpoch(lastNotificationTimestamp);
    }
  }

  void _setupPeriodicCheck() {
    // Check every day at midnight
    Future.delayed(Duration(minutes: 1), () async {
      final now = DateTime.now();

      // Check for end of week (Sunday)
      if (now.weekday == DateTime.sunday && shouldShowWeeklyNotification()) {
        await _saveLastWeeklyNotificationDate(now);
      }

      // Check for end of month
      final tomorrow = now.add(const Duration(days: 1));
      if (tomorrow.day == 1 && shouldShowMonthlyNotification()) {
        await _saveLastMonthlyNotificationDate(now);
      }

      // Setup next check
      _setupPeriodicCheck();
    });
  }

  Future<void> _saveLastNotificationDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastNotificationDate', date.millisecondsSinceEpoch);
    state = date;
  }

  Future<void> _saveLastWeeklyNotificationDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastWeeklyNotification', date.millisecondsSinceEpoch);
  }

  Future<void> _saveLastMonthlyNotificationDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastMonthlyNotification', date.millisecondsSinceEpoch);
  }

  bool shouldShowWeeklyNotification() {
    final now = DateTime.now();
    final lastSunday = now.subtract(Duration(days: now.weekday));
    return state.isBefore(lastSunday);
  }

  bool shouldShowMonthlyNotification() {
    final now = DateTime.now();
    final lastMonthEnd = DateTime(now.year, now.month, 0);
    return state.isBefore(lastMonthEnd);
  }

  Future<void> markNotificationShown() async {
    await _saveLastNotificationDate(DateTime.now());
  }
}
