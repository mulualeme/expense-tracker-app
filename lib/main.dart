import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_tracker/screens/home_screen.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/screens/settings_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Create a provider to track theme changes
final themeProvider = StateProvider<ThemeMode>((ref) {
  try {
    final settingsBox = Hive.box('settings');
    final isDarkMode = settingsBox.get('darkMode', defaultValue: false);
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  } catch (e) {
    // Return default theme mode if box is not ready
    return ThemeMode.system;
  }
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(CategoryAdapter());

  // Open boxes
  await Hive.openBox<Expense>('expenses');
  await Hive.openBox('settings');

  // Initialize notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize notification settings
  const initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettingsIOS = DarwinInitializationSettings();
  const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Request notification permissions
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      home: const DoubleTapToClose(
        child: HomeScreen(),
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF000000),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFEEEEEE)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF000000),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      themeMode: themeMode,
      routes: {
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class DoubleTapToClose extends StatefulWidget {
  final Widget child;

  const DoubleTapToClose({
    super.key,
    required this.child,
  });

  @override
  State<DoubleTapToClose> createState() => _DoubleTapToCloseState();
}

class _DoubleTapToCloseState extends State<DoubleTapToClose> {
  DateTime? _lastTapTime;

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
      _lastTapTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Center(
            child: Text(
              'Please press back again to exit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          backgroundColor: Colors.grey[800],
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(
            horizontal: 50.0,
            vertical: 16.0,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: widget.child,
    );
  }
}
