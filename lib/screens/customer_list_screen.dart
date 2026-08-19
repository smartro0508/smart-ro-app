import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: 6,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.accent.withAlpha(128),
                        foregroundColor: AppColors.primaryDark,
                        radius: 24,
                        child: Text('C${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'John Doe ${index + 1}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  'Chennai, Tamil Nadu',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                        itemBuilder: (context) => [
                          const PopupMenuItem(child: Text('View Details')),
                          const PopupMenuItem(child: Text('Edit Customer')),
                        ],
                      )
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(height: 1),
                  ),
                  Row(
                    children: [
                      _buildInfoChip(Icons.water_drop_outlined, 'Aqua Grand+'),
                      const SizedBox(width: 12),
                      _buildInfoChip(Icons.calendar_month_outlined, '12 Oct 2026'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildActionButton(Icons.phone, 'Call', AppColors.primary, () {}),
                      const SizedBox(width: 8),
                      _buildActionButton(Icons.chat, 'WhatsApp', AppColors.success, () {}),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/add-customer');
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Customer', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
