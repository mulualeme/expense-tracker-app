import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_tracker/screens/home_screen.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/screens/settings_screen.dart';

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
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(CategoryAdapter());

  // Open boxes
  await Hive.openBox<Expense>('expenses');
  await Hive.openBox('settings');

  runApp(
    ProviderScope(
      overrides: [
        // Initialize theme provider after boxes are opened
        themeProvider.overrideWith((ref) {
          final settingsBox = Hive.box('settings');
          final isDarkMode = settingsBox.get('darkMode', defaultValue: false);
          return isDarkMode ? ThemeMode.dark : ThemeMode.light;
        }),
      ],
      child: const MyApp(),
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
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
