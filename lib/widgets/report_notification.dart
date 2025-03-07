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
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const androidInitialize =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInitialize = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iOSInitialize,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (context.mounted) {
          // Navigate using MaterialPageRoute
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SummaryScreen(),
            ),
          );
        }
      },
    );
  }

  Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'expense_reports',
      'Expense Reports',
      channelDescription: 'Notifications for expense reports',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iOSDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(notificationProvider.notifier);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (notifier.shouldShowWeeklyNotification() ||
        notifier.shouldShowMonthlyNotification()) {
      final isMonthly = notifier.shouldShowMonthlyNotification();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Show system notification
        _showNotification(
          'Report Ready!',
          isMonthly
              ? 'Your monthly expense report is ready to view.'
              : 'Your weekly expense report is ready to view.',
        );

        // Show in-app dialog
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
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Later'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate using MaterialPageRoute
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
      });
    }

    return const SizedBox.shrink();
  }
}
