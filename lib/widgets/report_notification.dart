import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/providers/notification_provider.dart';
import 'package:expense_tracker/screens/summary_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

class ReportNotification extends ConsumerStatefulWidget {
  const ReportNotification({super.key});

  @override
  ConsumerState<ReportNotification> createState() => _ReportNotificationState();
}

class _ReportNotificationState extends ConsumerState<ReportNotification> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _notificationsInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      // Initialize Android settings
      const androidInitialize =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iOSInitialize = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initializationSettings = InitializationSettings(
        android: androidInitialize,
        iOS: iOSInitialize,
      );

      // Initialize plugin
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SummaryScreen(),
              ),
            );
          }
        },
      );

      // Request permissions
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>();

        final bool? granted =
            await androidImplementation?.requestNotificationsPermission();
        setState(() {
          _notificationsInitialized = granted ?? false;
        });
      } else if (Platform.isIOS) {
        // For iOS, permissions are requested during initialization
        setState(() {
          _notificationsInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      setState(() {
        _notificationsInitialized = false;
      });
    }
  }

  Future<void> _showNotification(String title, String body) async {
    if (!_notificationsInitialized) {
      debugPrint('Notifications not initialized or permission denied');
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'expense_reports',
        'Expense Reports',
        channelDescription: 'Notifications for expense reports',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

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
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(notificationProvider.notifier);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (notifier.shouldShowWeeklyNotification() ||
        notifier.shouldShowMonthlyNotification()) {
      final isMonthly = notifier.shouldShowMonthlyNotification();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Show system notification
        await _showNotification(
          'Report Ready!',
          isMonthly
              ? 'Your monthly expense report is ready to view.'
              : 'Your weekly expense report is ready to view.',
        );

        if (context.mounted) {
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
