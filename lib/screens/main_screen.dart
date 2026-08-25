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
    if (location.startsWith('/products')) return 2;
    if (location.startsWith('/services')) return 3;
    if (location.startsWith('/settings')) return 4;

    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/invoices');
        break;
      case 1:
        context.go('/customers');
        break;
      case 2:
        context.go('/products');
        break;
      case 3:
        context.go('/services');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
        child: _buildBottomNavigation(context, currentIndex),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context, int currentIndex) {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),

        border: Border.all(
          color: AppColors.primaryDark.withValues(alpha: 0.06),
          width: 1,
        ),

        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.08),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),

        child: Row(
          children: [
            Expanded(
              child: _buildNavItem(
                context: context,
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
                label: 'Invoices',
              ),
            ),

            Expanded(
              child: _buildNavItem(
                context: context,
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.people_outline_rounded,
                activeIcon: Icons.people_rounded,
                label: 'Customers',
              ),
            ),

            Expanded(
              child: _buildNavItem(
                context: context,
                index: 2,
                currentIndex: currentIndex,
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2_rounded,
                label: 'Products',
              ),
            ),

            Expanded(
              child: _buildNavItem(
                context: context,
                index: 3,
                currentIndex: currentIndex,
                icon: Icons.home_repair_service_outlined,
                activeIcon: Icons.home_repair_service_rounded,
                label: 'Services',
              ),
            ),

            Expanded(
              child: _buildNavItem(
                context: context,
                index: 4,
                currentIndex: currentIndex,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings_rounded,
                label: 'Settings',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => _onItemTapped(index, context),
      behavior: HitTestBehavior.opaque,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,

        margin: const EdgeInsets.symmetric(horizontal: 3),

        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.10)
              : Colors.transparent,

          borderRadius: BorderRadius.circular(20),
        ),

        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),

                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },

                    child: Icon(
                      isSelected ? activeIcon : icon,
                      key: ValueKey(isSelected),
                      size: 23,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary.withValues(alpha: 0.65),
                    ),
                  ),

                  const SizedBox(height: 4),

                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),

                    curve: Curves.easeOut,

                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primaryDark
                          : AppColors.textSecondary.withValues(alpha: 0.65),
                    ),

                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Active indicator
            Positioned(
              bottom: 2,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,

                width: isSelected ? 20 : 0,
                height: 3,

                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
