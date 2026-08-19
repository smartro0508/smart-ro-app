import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/invoices')) return 0;
    if (location.startsWith('/customers')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/invoices'); break;
      case 1: context.go('/customers'); break;
      case 2: context.go('/settings'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, 0, currentIndex, Icons.receipt_long_outlined, Icons.receipt_long, 'Invoices'),
                _buildNavItem(context, 1, currentIndex, Icons.people_outline, Icons.people, 'Customers'),
                _buildNavItem(context, 2, currentIndex, Icons.settings_outlined, Icons.settings, 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, int currentIndex, IconData icon, IconData activeIcon, String label) {
    final isSelected = index == currentIndex;
    final color = isSelected ? AppColors.primary : AppColors.textSecondary.withAlpha(150);

    return GestureDetector(
      onTap: () => _onItemTapped(index, context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 70,
        color: Colors.transparent, 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              transform: Matrix4.translationValues(0, isSelected ? -2 : 0, 0),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: color,
                size: isSelected ? 28 : 24,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isSelected ? 1.0 : 0.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                height: 4,
                width: isSelected ? 16 : 4,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
