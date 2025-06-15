import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/auth/register_scree.dart';

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    '/': (context) => const SplashScreen(),
    '/dashboard': (context) => const DashboardScreen(),
    '/login': (context) => const LoginScreen(),
    '/settings': (context) => const SettingsScreen(),
    '/register': (_) => const RegisterScreen(),
  };
}
