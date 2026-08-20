import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';
import '../screens/invoice_list_screen.dart';
import '../screens/create_invoice_screen.dart';
import '../screens/customer_list_screen.dart';
import '../screens/customer_onboarding_screen.dart';
import '../screens/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: (Hive.box('authBox').get('token') != null && Hive.box('authBox').get('token').toString().isNotEmpty) ? '/invoices' : '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/invoices',
          builder: (context, state) => const InvoiceListScreen(),
        ),
        GoRoute(
          path: '/create-invoice',
          builder: (context, state) => const CreateInvoiceScreen(),
        ),
        GoRoute(
          path: '/customers',
          builder: (context, state) => const CustomerListScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/add-customer',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CustomerOnboardingScreen(),
    ),
  ],
);
