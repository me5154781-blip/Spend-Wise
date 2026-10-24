import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/auth_page.dart';
import 'screens/shell.dart';
import 'services/store.dart';

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(primary: kOrange, surface: kCard),
        useMaterial3: true,
      ),
      home: ListenableBuilder(
        listenable: store,
        builder: (_, __) => store.loggedIn ? const Shell() : const AuthPage(),
      ),
    );
  }
}
