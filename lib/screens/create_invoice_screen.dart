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
import '../service/service_service.dart';
import '../models/service_model.dart';
import '../widgets/premium_animated_app_bar.dart';

class CreateInvoiceScreen extends StatefulWidget {
  final InvoiceModel? invoice;

  const CreateInvoiceScreen({super.key, this.invoice});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _discountController = TextEditingController(text: '0');
  final _termsNotesController = TextEditingController();
  final _remindersDaysController = TextEditingController();

  TextEditingController? _productSearchController;
  TextEditingController? _serviceSearchController;

  bool _applyGST = false;

  bool _isSearchingCustomer = false;
  bool _isSearchingProduct = false;
  bool _isSearchingService = false;

  CustomerModel? _selectedCustomer;
  final List<InvoiceItemModel> _invoiceItems = [];

  String _paymentMethod = 'Cash';
  String _paymentStatus = 'Paid';

  final List<String> _paymentMethods = [
    'Cash',
    'Card',
    'UPI',
    'Bank Transfer',
    'None',
  ];
  final List<String> _paymentStatuses = ['Paid', 'Unpaid', 'Partial'];

  @override
  void initState() {
    super.initState();
    if (widget.invoice != null) {
      final inv = widget.invoice!;
      try {
        _selectedCustomer = CustomerModel.fromJson(inv.customerData);
      } catch (e) {
        _selectedCustomer = null;
      }
      _invoiceItems.addAll(inv.items);
      _applyGST = inv.isGstApplied;
      _discountController.text = inv.totalDiscount.toString();
      _paymentMethod = inv.paymentmethod ?? 'Cash';
      _paymentStatus = inv.paymentstatus ?? 'Unpaid';
      _termsNotesController.text = inv.termsnotes ?? '';
      _remindersDaysController.text = inv.reminderdays?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _discountController.dispose();
    _termsNotesController.dispose();
    _remindersDaysController.dispose();
    super.dispose();
  }

  double get subtotal => _invoiceItems.fold(0, (sum, item) => sum + item.total);

  double get totalDiscount => double.tryParse(_discountController.text) ?? 0.0;

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

  void _addService(ServiceModel service) {
    if (service.servicecost > 0 ||
        (service.servicecost == 0 && service.serviceproductcost == 0)) {
      _addProduct(
        ProductModel(
          id: '${service.id}_svc',
          productname: '${service.servicename} (Service)',
          description: service.description,
          price: service.servicecost,
        ),
      );
    }
    if (service.serviceproductcost > 0) {
      _addProduct(
        ProductModel(
          id: '${service.id}_prd',
          productname: '${service.servicename} (Product)',
          description: service.description,
          price: service.serviceproductcost,
        ),
      );
    }
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
      appBar: PremiumAnimatedAppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/app-logo.png', height: 28),
            const SizedBox(width: 8),
            Text(
              widget.invoice != null ? 'Edit Invoice' : 'Create Invoice',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
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
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<CustomerModel>.empty();
                  }
                  setState(() => _isSearchingCustomer = true);
                  try {
                    final customerService = CustomerService();
                    final customers = await customerService.searchCustomers(
                      textEditingValue.text,
                    );
                    setState(() => _isSearchingCustomer = false);
                    return customers;
                  } catch (e) {
                    setState(() => _isSearchingCustomer = false);
                    return const Iterable<CustomerModel>.empty();
                  }
                },
                displayStringForOption: (CustomerModel option) =>
                    option.fullName,
                onSelected: (CustomerModel selection) {
                  setState(() => _selectedCustomer = selection);
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return _buildOptionsView<CustomerModel>(
                    context,
                    onSelected,
                    options,
                    (c) => c.fullName,
                    (c) =>
                        '${c.phoneNumber} ${c.city != null ? '• ${c.city}' : ''}'
                            .trim(),
                  );
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                      return Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryDark.withValues(
                                      alpha: 0.04,
                                    ),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: _inputDecoration(
                                  'Search Customer by Name',
                                  Icons.search,
                                  suffixIcon: _isSearchingCustomer
                                      ? const Padding(
                                          padding: EdgeInsets.all(12),
                                          child: SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.person_add_alt_1,
                                color: AppColors.primary,
                              ),
                              onPressed: () => context.push('/add-customer'),
                              tooltip: 'Create Customer',
                            ),
                          ),
                        ],
                      );
                    },
              )
            else
              _buildSelectedCustomerCard(),

            const SizedBox(height: 24),
            _buildSectionTitle('Add Products / Services'),
            Autocomplete<ProductModel>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<ProductModel>.empty();
                }
                setState(() => _isSearchingProduct = true);
                try {
                  final productService = ProductService();
                  final products = await productService.searchProducts(
                    textEditingValue.text,
                  );
                  setState(() => _isSearchingProduct = false);
                  return products;
                } catch (e) {
                  setState(() => _isSearchingProduct = false);
                  return const Iterable<ProductModel>.empty();
                }
              },
              displayStringForOption: (ProductModel option) => option.name,
              onSelected: (ProductModel selection) {
                _addProduct(selection);
                Future.delayed(const Duration(milliseconds: 50), () {
                  _productSearchController?.clear();
                });
              },
              optionsViewBuilder: (context, onSelected, options) {
                return _buildOptionsView<ProductModel>(
                  context,
                  onSelected,
                  options,
                  (p) => p.name,
                  (p) => '₹ ${p.price.toStringAsFixed(2)}',
                );
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    _productSearchController = controller;
                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryDark.withValues(
                                    alpha: 0.04,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: _inputDecoration(
                                'Search Product to add',
                                Icons.inventory_2_outlined,
                                suffixIcon: _isSearchingProduct
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add_box_outlined,
                              color: AppColors.primary,
                            ),
                            onPressed: () => context.push('/add-product'),
                            tooltip: 'Create Product',
                          ),
                        ),
                      ],
                    );
                  },
            ),

            const SizedBox(height: 16),
            Autocomplete<ServiceModel>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<ServiceModel>.empty();
                }
                setState(() => _isSearchingService = true);
                try {
                  final serviceService = ServiceService();
                  final services = await serviceService.searchServices(
                    textEditingValue.text,
                  );
                  setState(() => _isSearchingService = false);
                  return services;
                } catch (e) {
                  setState(() => _isSearchingService = false);
                  return const Iterable<ServiceModel>.empty();
                }
              },
              displayStringForOption: (ServiceModel option) =>
                  option.servicename,
              onSelected: (ServiceModel selection) {
                _addService(selection);
                Future.delayed(const Duration(milliseconds: 50), () {
                  _serviceSearchController?.clear();
                });
              },
              optionsViewBuilder: (context, onSelected, options) {
                return _buildOptionsView<ServiceModel>(
                  context,
                  onSelected,
                  options,
                  (s) => s.servicename,
                  (s) =>
                      '₹ ${(s.servicecost + s.serviceproductcost).toStringAsFixed(2)}',
                );
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    _serviceSearchController = controller;
                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryDark.withValues(
                                    alpha: 0.04,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: _inputDecoration(
                                'Search Service to add',
                                Icons.home_repair_service_outlined,
                                suffixIcon: _isSearchingService
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: AppColors.primary,
                            ),
                            onPressed: () => context.push('/add-service'),
                            tooltip: 'Create Service',
                          ),
                        ),
                      ],
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
            _buildSectionTitle('Discount'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _discountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (value) {
                  setState(() {});
                },
                decoration: _inputDecoration(
                  'Discount Amount (₹)',
                  Icons.local_offer_outlined,
                ),
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Tax Settings'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.04),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Additional Details'),
            if (_applyGST) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(
                              alpha: 0.04,
                            ),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: _paymentMethod,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        decoration: _inputDecoration(
                          'Payment Method',
                          Icons.payment,
                        ),
                        items: _paymentMethods.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        selectedItemBuilder: (BuildContext context) {
                          return _paymentMethods.map((String value) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList();
                        },
                        onChanged: (String? newValue) {
                          if (newValue == null) return;

                          setState(() {
                            _paymentMethod = newValue;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(
                              alpha: 0.04,
                            ),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: _paymentStatus,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        decoration: _inputDecoration(
                          'Payment Status',
                          Icons.info_outline,
                        ),
                        items: _paymentStatuses.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        selectedItemBuilder: (BuildContext context) {
                          return _paymentStatuses.map((String value) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList();
                        },
                        onChanged: (String? newValue) {
                          if (newValue == null) return;
                          setState(() {
                            _paymentStatus = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _termsNotesController,
                maxLines: 2,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _inputDecoration('Terms & Conditions', Icons.gavel),
              ),
            ),

            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _remindersDaysController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _inputDecoration('Reminders Days *', Icons.calendar_today),
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
                  if (totalDiscount > 0) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Discount',
                      '- ₹ ${totalDiscount.toStringAsFixed(2)}',
                    ),
                  ],
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
                  text: widget.invoice != null
                      ? 'Update Invoice'
                      : 'Save Invoice',
                  icon: Icons.save,
                  isLoading: state is InvoiceAdding,
                  onPressed: state is InvoiceAdding
                      ? () {}
                      : () {
                          if (_selectedCustomer == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a customer!'),
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

                          if (_remindersDaysController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter Reminders Days!',
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          final invoice = InvoiceModel(
                            id: widget.invoice?.id,
                            invoiceNumber: widget.invoice?.invoiceNumber,
                            invoiceDate:
                                widget.invoice?.invoiceDate ??
                                DateTime.now().toIso8601String().split('T')[0],
                            type: _applyGST ? 'Tax Invoice' : 'Bill of Supply',
                            customerData: _selectedCustomer!.toJson(),
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
                            paymentmethod: _paymentMethod,
                            paymentstatus: _paymentStatus,
                            termsnotes: _termsNotesController.text,
                            reminderdays: int.tryParse(_remindersDaysController.text.trim()),
                          );

                          if (widget.invoice != null &&
                              widget.invoice!.id != null) {
                            context.read<InvoiceCubit>().updateInvoice(
                              widget.invoice!.id!,
                              invoice,
                            );
                          } else {
                            context.read<InvoiceCubit>().addInvoice(invoice);
                          }
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
            color: AppColors.primaryDark.withValues(alpha: 0.04),
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
            color: AppColors.primaryDark.withValues(alpha: 0.04),
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
                  '${item.product.name}${item.product.hsncode != null && item.product.hsncode!.isNotEmpty ? ' (HSN: ${item.product.hsncode})' : ''}',
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
              SizedBox(
                width: 100,
                child: TextFormField(
                  key: ValueKey('price_${item.product.id}_$index'),
                  initialValue: (item.product.price == item.product.price.toInt()) 
                      ? item.product.price.toInt().toString()
                      : item.product.price.toStringAsFixed(2),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onChanged: (val) {
                    final newPrice = double.tryParse(val) ?? 0.0;
                    setState(() {
                      _invoiceItems[index].product = ProductModel(
                        id: item.product.id,
                        productname: item.product.productname,
                        description: item.product.description,
                        price: newPrice,
                        hsncode: item.product.hsncode,
                      );
                    });
                  },
                ),
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

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      suffixIcon: suffixIcon,
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

  Widget _buildOptionsView<T extends Object>(
    BuildContext context,
    AutocompleteOnSelected<T> onSelected,
    Iterable<T> options,
    String Function(T) displayString,
    String Function(T)? subtitleString,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 8.0,
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surface,
        child: Container(
          width: MediaQuery.of(context).size.width - 40,
          constraints: const BoxConstraints(maxHeight: 250),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: Colors.black12),
            itemBuilder: (BuildContext context, int index) {
              final T option = options.elementAt(index);
              return InkWell(
                onTap: () => onSelected(option),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayString(option),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (subtitleString != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitleString(option),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
