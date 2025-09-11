import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/selection_screen.dart';
import 'screens/analytics_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auth Pages',
      theme: ThemeData(primarySwatch: Colors.blue),

      // Default to login, but register is available
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/selection': (context) => const SelectionScreen(),
        '/analytics': (context) => AnalyticsScreen(),
      },
    );
  }
}
