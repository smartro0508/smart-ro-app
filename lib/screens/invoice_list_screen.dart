import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import '../theme/app_colors.dart';
import '../controller/invoice_cubit.dart';
import '../controller/invoice_state.dart';
import '../models/invoice_model.dart';
import '../utils/pdf_service.dart';
import '../widgets/premium_animated_app_bar.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _loadingPdfInvoiceId;
  String _selectedType = 'All';

  @override
  void initState() {
    super.initState();
    context.read<InvoiceCubit>().getInvoices(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<InvoiceCubit>().getInvoices();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PremiumAnimatedAppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search invoices...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/app-logo.png', height: 28),
                  const SizedBox(width: 8),
                  const Text('Invoices', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
        centerTitle: !_isSearching,
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              )
            : null,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _buildDateFilter(context),
          _buildTypeFilter(),
          Expanded(
            child: BlocBuilder<InvoiceCubit, InvoiceState>(
              builder: (context, state) {
                if (state is InvoiceLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is InvoiceError) {
                  return Center(child: Text(state.message, style: const TextStyle(color: AppColors.error)));
                } else if (state is InvoiceLoaded) {
                  final allInvoices = state.invoices;
                  final searchFiltered = _searchQuery.isEmpty
                      ? allInvoices
                      : allInvoices.where((i) {
                          final cName = (i.customerData['fullName'] ?? i.customerData['name'] ?? '').toString().toLowerCase();
                          final iNum = (i.invoiceNumber ?? '').toLowerCase();
                          return cName.contains(_searchQuery) || iNum.contains(_searchQuery);
                        }).toList();
                        
                  final filtered = _selectedType == 'All' 
                      ? searchFiltered 
                      : searchFiltered.where((i) {
                          if (_selectedType == 'GST') return i.isGstApplied;
                          if (_selectedType == 'Non-GST') return !i.isGstApplied;
                          return true;
                        }).toList();
                      
                  if (filtered.isEmpty) {
                    return const Center(child: Text('No invoices found.'));
                  }
                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0),
                    itemCount: filtered.length + (state.hasReachedMax ? 0 : 1),
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      if (index >= filtered.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _buildInvoiceCard(filtered[index]);
                    },
                  );
                }
                return const Center(child: Text('No data.'));
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


  Widget _buildInvoiceCard(InvoiceModel invoice) {
    final String customerName =
        invoice.customerData['fullName'] ??
            invoice.customerData['name'] ??
            'Unknown Customer';

    final String itemsText =
    invoice.items.map((e) => e.product.name).join(', ');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            // ───────────────── HEADER ─────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
              child: Row(
                children: [
                  // Invoice icon
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 21,
                      color: AppColors.primaryDark,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Invoice number
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'INVOICE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          invoice.invoiceNumber ?? 'INV-N/A',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Invoice type
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      invoice.type,
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.textSecondary.withOpacity(0.08),
            ),

            // ───────────────── CUSTOMER + TOTAL ─────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer avatar
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          size: 22,
                          color: Colors.orange,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Customer information
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CUSTOMER',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              customerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 11,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  invoice.invoiceDate,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Total
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'TOTAL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '₹${invoice.grandTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ───────────────── ITEMS ─────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.textSecondary.withOpacity(0.07),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.water_drop_outlined,
                            size: 16,
                            color: Colors.teal,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ITEMS',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.7,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                itemsText.isEmpty
                                    ? 'No items'
                                    : itemsText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        // View and Share PDF
                        if (_loadingPdfInvoiceId == invoice.id)
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 17,
                                height: 17,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.info,
                                ),
                              ),
                            ),
                          )
                        else
                          Row(
                            children: [
                              _buildInvoiceIconButton(
                                Icons.remove_red_eye_outlined,
                                Colors.indigo,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Scaffold(
                                        appBar: AppBar(
                                          title: const Text('Invoice Preview'),
                                        ),
                                        body: PdfPreview(
                                          build: (format) => PdfService.generateInvoicePdfBytes(invoice),
                                          allowPrinting: true,
                                          allowSharing: true,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildInvoiceIconButton(
                                Icons.edit_outlined,
                                Colors.orange,
                                () {
                                  context.push('/create-invoice', extra: invoice);
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildInvoiceIconButton(
                                Icons.share_outlined,
                                AppColors.info,
                                    () async {
                                  setState(() {
                                    _loadingPdfInvoiceId = invoice.id;
                                  });

                                  try {
                                    await PdfService.shareInvoicePdf(invoice);
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _loadingPdfInvoiceId = null;
                                      });
                                    }
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildInvoiceIconButton(
                                Icons.delete_outline,
                                AppColors.error,
                                () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Invoice'),
                                      content: const Text('Are you sure you want to delete this invoice?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true && invoice.id != null) {
                                    context.read<InvoiceCubit>().deleteInvoice(invoice.id!);
                                  }
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  Widget _buildDateFilter(BuildContext context) {
    final cubit = context.read<InvoiceCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(cubit.fromDate ?? DateTime.now().toIso8601String()),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  cubit.updateDates(date.toIso8601String().split('T')[0], cubit.toDate!);
                  setState(() {});
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(cubit.fromDate ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('TO', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 12)),
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(cubit.toDate ?? DateTime.now().toIso8601String()),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  cubit.updateDates(cubit.fromDate!, date.toIso8601String().split('T')[0]);
                  setState(() {});
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(cubit.toDate ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      child: Row(
        children: [
          _buildChoiceChip('All'),
          const SizedBox(width: 8),
          _buildChoiceChip('GST'),
          const SizedBox(width: 8),
          _buildChoiceChip('Non-GST'),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label) {
    final isSelected = _selectedType == label;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.2),
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedType = label;
          });
        }
      },
    );
  }
}
