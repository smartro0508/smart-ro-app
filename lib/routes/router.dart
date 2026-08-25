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
import '../screens/product_list_screen.dart';
import '../screens/service_list_screen.dart';
import '../screens/product_form_screen.dart';
import '../screens/service_form_screen.dart';
import '../models/product_model.dart';
import '../models/service_model.dart';

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
          path: '/products',
          builder: (context, state) => const ProductListScreen(),
        ),
        GoRoute(
          path: '/services',
          builder: (context, state) => const ServiceListScreen(),
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
    GoRoute(
      path: '/add-product',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final product = state.extra as ProductModel?;
        return ProductFormScreen(product: product);
      },
    ),
    GoRoute(
      path: '/add-service',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final service = state.extra as ServiceModel?;
        return ServiceFormScreen(service: service);
      },
    ),
  ],
);
