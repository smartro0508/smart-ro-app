import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';
import '../models/customer_model.dart';
import '../models/product_model.dart';
import '../models/invoice_model.dart';
import '../controller/invoice_cubit.dart';
import '../controller/invoice_state.dart';
import '../service/customer_service.dart';
import '../service/product_service.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _applyGST = true;

  CustomerModel? _selectedCustomer;
  final List<InvoiceItemModel> _invoiceItems = [];

  double get subtotal => _invoiceItems.fold(0, (sum, item) => sum + item.total);
  double get totalDiscount => 0.0;
  double get taxableAmount => subtotal - totalDiscount;
  double get cgst => _applyGST ? taxableAmount * 0.09 : 0.0;
  double get sgst => _applyGST ? taxableAmount * 0.09 : 0.0;
  double get igst => 0.0;
  double get grandTotal => taxableAmount + cgst + sgst + igst;

  void _addProduct(ProductModel product) {
    setState(() {
      final existingIndex = _invoiceItems.indexWhere(
        (item) => item.product.id == product.id,
      );
      if (existingIndex >= 0) {
        _invoiceItems[existingIndex].quantity += 1;
      } else {
        _invoiceItems.add(InvoiceItemModel(product: product, quantity: 1));
      }
    });
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      _invoiceItems[index].quantity += delta;
      if (_invoiceItems[index].quantity <= 0) {
        _invoiceItems.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Invoice',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  _buildSectionTitle('Customer Details'),
                  if (_selectedCustomer == null)
                    Autocomplete<CustomerModel>(
                      optionsBuilder: (TextEditingValue textEditingValue) async {
                        if (textEditingValue.text.isEmpty)
                          return const Iterable<CustomerModel>.empty();
                        try {
                          final customerService = CustomerService();
                          final customers = await customerService.searchCustomers(textEditingValue.text);
                          return customers;
                        } catch (e) {
                          return const Iterable<CustomerModel>.empty();
                        }
                      },
                      displayStringForOption: (CustomerModel option) =>
                          option.fullName,
                      onSelected: (CustomerModel selection) {
                        setState(() => _selectedCustomer = selection);
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onFieldSubmitted) {
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryDark.withOpacity(0.04),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
                                decoration: _inputDecoration(
                                  'Search Customer by Name',
                                  Icons.search,
                                ),
                              ),
                            );
                          },
                    )
                  else
                    _buildSelectedCustomerCard(),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Add Products / Services'),
                  Autocomplete<ProductModel>(
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      if (textEditingValue.text.isEmpty)
                        return const Iterable<ProductModel>.empty();
                      try {
                        final productService = ProductService();
                        final products = await productService.searchProducts(textEditingValue.text);
                        return products;
                      } catch (e) {
                        return const Iterable<ProductModel>.empty();
                      }
                    },
                    displayStringForOption: (ProductModel option) =>
                        option.name,
                    onSelected: (ProductModel selection) {
                      _addProduct(selection);
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryDark.withOpacity(0.04),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
                              decoration: _inputDecoration(
                                'Search Product/Service to add',
                                Icons.add_shopping_cart,
                              ),
                            ),
                          );
                        },
                  ),

                  const SizedBox(height: 16),
                  if (_invoiceItems.isNotEmpty)
                    ..._invoiceItems.asMap().entries.map((entry) {
                      int idx = entry.key;
                      InvoiceItemModel item = entry.value;
                      return _buildInvoiceItemCard(idx, item);
                    }),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Tax Settings'),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        'Apply GST (18%)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Calculate 18% tax on subtotal'),
                      activeTrackColor: AppColors.primary,
                      value: _applyGST,
                      onChanged: (val) => setState(() => _applyGST = val),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),



                  const SizedBox(height: 32),
                  // Total Summary
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.waterGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryLight.withAlpha(76),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          'Subtotal',
                          '₹ ${subtotal.toStringAsFixed(2)}',
                        ),
                        if (_applyGST) ...[
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'CGST (9%)',
                            '₹ ${cgst.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'SGST (9%)',
                            '₹ ${sgst.toStringAsFixed(2)}',
                          ),
                        ],
                        const SizedBox(height: 8),
                        const Divider(color: Colors.white54),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Grand Total',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹ ${grandTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  BlocConsumer<InvoiceCubit, InvoiceState>(
                    listener: (context, state) {
                      if (state is InvoiceAdded) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invoice saved!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        context.pop();
                      } else if (state is InvoiceAddError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return GradientButton(
                        text: 'Save Invoice',
                        icon: Icons.save,
                        isLoading: state is InvoiceAdding,
                        onPressed: state is InvoiceAdding
                            ? () {}
                            : () {
                                if (_selectedCustomer == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please select a customer!',
                                      ),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                  return;
                                }
                                if (_invoiceItems.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please add at least one product!',
                                      ),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                  return;
                                }

                                final invoice = InvoiceModel(
                                  invoiceDate: DateTime.now().toIso8601String().split('T')[0],
                                  type: _applyGST ? 'Tax Invoice' : 'Bill of Supply',
                                  customerData: {
                                    'id': _selectedCustomer!.id,
                                    'name': _selectedCustomer!.fullName,
                                    'phone': _selectedCustomer!.phoneNumber,
                                    'address': _selectedCustomer!.address,
                                  },
                                  items: _invoiceItems,
                                  subtotal: subtotal,
                                  totalDiscount: totalDiscount,
                                  taxableAmount: taxableAmount,
                                  isGstApplied: _applyGST,
                                  cgst: cgst,
                                  sgst: sgst,
                                  igst: igst,
                                  roundOff: 0.0,
                                  grandTotal: grandTotal,
                                );

                                context.read<InvoiceCubit>().addInvoice(
                                  invoice,
                                );
                              },
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, top: 8.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              gradient: AppColors.waterGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withAlpha(25),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedCustomer!.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedCustomer?.phoneNumber ?? '',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  _selectedCustomer?.address ?? '',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.error),
            onPressed: () => setState(() => _selectedCustomer = null),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItemCard(int index, InvoiceItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _invoiceItems.removeAt(index));
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹ ${item.product.price.toStringAsFixed(2)}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              Row(
                children: [
                  _qtyButton(Icons.remove, () => _updateQuantity(index, -1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _qtyButton(Icons.add, () => _updateQuantity(index, 1)),
                ],
              ),
              Text(
                '₹ ${item.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
