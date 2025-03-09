import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});

class NotificationState {
  final DateTime lastNotificationDate;
  final bool hasUnreadWeeklyReport;
  final bool hasUnreadMonthlyReport;

  NotificationState({
    required this.lastNotificationDate,
    this.hasUnreadWeeklyReport = false,
    this.hasUnreadMonthlyReport = false,
  });

  NotificationState copyWith({
    DateTime? lastNotificationDate,
    bool? hasUnreadWeeklyReport,
    bool? hasUnreadMonthlyReport,
  }) {
    return NotificationState(
      lastNotificationDate: lastNotificationDate ?? this.lastNotificationDate,
      hasUnreadWeeklyReport:
          hasUnreadWeeklyReport ?? this.hasUnreadWeeklyReport,
      hasUnreadMonthlyReport:
          hasUnreadMonthlyReport ?? this.hasUnreadMonthlyReport,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier()
      : super(NotificationState(lastNotificationDate: DateTime.now())) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadLastNotificationDate();
    _checkReports();
    _setupPeriodicCheck();
  }

  void _setupPeriodicCheck() {
    Future.delayed(const Duration(minutes: 1), () {
      _checkReports();
      _setupPeriodicCheck(); // Setup next check
    });
  }

  Future<void> _loadLastNotificationDate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastWeeklyTimestamp = prefs.getInt('lastWeeklyNotification');
    final lastMonthlyTimestamp = prefs.getInt('lastMonthlyNotification');

    final now = DateTime.now();
    final lastWeekly = lastWeeklyTimestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(lastWeeklyTimestamp)
        : now.subtract(const Duration(days: 8)); // Ensure first check works
    final lastMonthly = lastMonthlyTimestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(lastMonthlyTimestamp)
        : DateTime(now.year, now.month - 1, now.day); // Previous month

    state = NotificationState(
      lastNotificationDate: now,
      hasUnreadWeeklyReport: _isWeeklyReportDue(lastWeekly),
      hasUnreadMonthlyReport: _isMonthlyReportDue(lastMonthly),
    );
  }

  void _checkReports() {
    final hasWeeklyReport = _isWeeklyReportDue(state.lastNotificationDate);
    final hasMonthlyReport = _isMonthlyReportDue(state.lastNotificationDate);

    if (hasWeeklyReport || hasMonthlyReport) {
      state = state.copyWith(
        hasUnreadWeeklyReport: hasWeeklyReport,
        hasUnreadMonthlyReport: hasMonthlyReport,
      );
    }
  }

  bool _isWeeklyReportDue(DateTime lastCheck) {
    final now = DateTime.now();
    // Check if it's Sunday and after 6 PM
    if (now.weekday == DateTime.sunday && now.hour >= 18) {
      // Check if we haven't shown notification this Sunday
      return !_isSameDay(lastCheck, now);
    }
    return false;
  }

  bool _isMonthlyReportDue(DateTime lastCheck) {
    final now = DateTime.now();
    // Get the last day of current month
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    // Check if it's the last day of month and after 6 PM
    if (now.day == lastDayOfMonth.day && now.hour >= 18) {
      // Check if we haven't shown notification this month
      return lastCheck.month != now.month || lastCheck.year != now.year;
    }
    return false;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> markNotificationShown() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    if (state.hasUnreadWeeklyReport) {
      await prefs.setInt('lastWeeklyNotification', now.millisecondsSinceEpoch);
    }
    if (state.hasUnreadMonthlyReport) {
      await prefs.setInt('lastMonthlyNotification', now.millisecondsSinceEpoch);
    }

    state = state.copyWith(
      lastNotificationDate: now,
      hasUnreadWeeklyReport: false,
      hasUnreadMonthlyReport: false,
    );
  }

  bool hasUnreadNotifications() {
    return state.hasUnreadWeeklyReport || state.hasUnreadMonthlyReport;
  }
}
