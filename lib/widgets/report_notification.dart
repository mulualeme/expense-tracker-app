import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/providers/notification_provider.dart';
import 'package:expense_tracker/screens/summary_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ReportNotification extends ConsumerStatefulWidget {
  const ReportNotification({super.key});

  @override
  ConsumerState<ReportNotification> createState() => _ReportNotificationState();
}

class _ReportNotificationState extends ConsumerState<ReportNotification> {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    setState(() => _isInitialized = true);
  }

  void _handleNotificationTap(NotificationResponse details) {
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SummaryScreen()),
      );
    }
  }

  Future<void> _showNotification(String title, String body) async {
    if (!_isInitialized) return;

    const androidDetails = AndroidNotificationDetails(
      'expense_reports',
      'Expense Reports',
      channelDescription: 'Notifications for expense reports',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(0, title, body, notificationDetails);
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (notifier.hasUnreadNotifications()) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final isMonthly = notificationState.hasUnreadMonthlyReport;

        await _showNotification(
          'Report Ready!',
          isMonthly
              ? 'Your monthly expense report is ready to view.'
              : 'Your weekly expense report is ready to view.',
        );

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor:
                  isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              title: Text(
                'Report Ready!',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              content: Text(
                isMonthly
                    ? 'Your monthly expense report is ready to view.'
                    : 'Your weekly expense report is ready to view.',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey : Colors.grey.shade600,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Later'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SummaryScreen(),
                      ),
                    );
                    notifier.markNotificationShown();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C446E),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('View Report'),
                ),
              ],
            ),
          );
        }
      });
    }

    return const SizedBox.shrink();
  }
}
