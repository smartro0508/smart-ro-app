import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Paid', 'Pending', 'Partial'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: 6,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildInvoiceCard(index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/create-invoice');
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 60,
      color: AppColors.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(_filters[index]),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedFilter = index);
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: AppColors.background,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInvoiceCard(int index) {
    // Mock status logic
    Color statusColor;
    String statusText;
    if (index % 3 == 0) {
      statusColor = AppColors.success;
      statusText = 'Paid';
    } else if (index % 3 == 1) {
      statusColor = AppColors.error;
      statusText = 'Pending';
    } else {
      statusColor = AppColors.warning;
      statusText = 'Partial';
    }

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'INV-${1000 + index}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primaryDark),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.accent.withAlpha(76),
                  radius: 18,
                  child: const Icon(Icons.person, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer Name ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const Text('12 Oct 2026', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                const Text(
                  '₹ 2,499',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                const Icon(Icons.water_drop_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'RO Filter Change, AMC Service',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 20, color: AppColors.primary),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.download_outlined, size: 20, color: AppColors.primary),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
