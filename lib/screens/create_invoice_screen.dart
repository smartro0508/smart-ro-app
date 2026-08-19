import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';

class Customer {
  final String id;
  final String name;
  final String phone;
  final String address;
  Customer(this.id, this.name, this.phone, this.address);
}

class Product {
  final String id;
  final String name;
  final double price;
  Product(this.id, this.name, this.price);
}

class InvoiceItem {
  final Product product;
  int quantity;
  InvoiceItem(this.product, this.quantity);
  double get total => product.price * quantity;
}

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _paymentStatus = 'Pending';
  String _paymentMethod = 'UPI';
  bool _applyGST = true;

  Customer? _selectedCustomer;
  final List<InvoiceItem> _invoiceItems = [];

  final List<Customer> _mockCustomers = [
    Customer('C1', 'Ramesh Kumar', '+91 9876543210', '123 Main St, Chennai'),
    Customer('C2', 'Suresh Raina', '+91 8765432109', '45 Park Ave, Madurai'),
    Customer('C3', 'Anita Desai', '+91 7654321098', '78 Lake View, Coimbatore'),
  ];

  final List<Product> _mockProducts = [
    Product('P1', 'RO Filter Set', 850.0),
    Product('P2', 'RO Membrane (75 GPD)', 1200.0),
    Product('P3', 'AMC Service Charge', 2500.0),
    Product('P4', 'UV Lamp', 600.0),
    Product('P5', 'Solenoid Valve', 450.0),
  ];

  double get subtotal => _invoiceItems.fold(0, (sum, item) => sum + item.total);
  double get gstAmount => _applyGST ? subtotal * 0.18 : 0.0;
  double get grandTotal => subtotal + gstAmount;

  void _addProduct(Product product) {
    setState(() {
      final existingIndex = _invoiceItems.indexWhere((item) => item.product.id == product.id);
      if (existingIndex >= 0) {
        _invoiceItems[existingIndex].quantity += 1;
      } else {
        _invoiceItems.add(InvoiceItem(product, 1));
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
        title: const Text('Create Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
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
              Autocomplete<Customer>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) return const Iterable<Customer>.empty();
                  return _mockCustomers.where((c) => c.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                displayStringForOption: (Customer option) => option.name,
                onSelected: (Customer selection) {
                  setState(() => _selectedCustomer = selection);
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: _inputDecoration('Search Customer by Name', Icons.search),
                  );
                },
              )
            else
              _buildSelectedCustomerCard(),

            const SizedBox(height: 24),
            Row(
              children: const [
                Expanded(child: CustomTextField(label: 'Invoice No.', icon: Icons.receipt_outlined, readOnly: true)),
                SizedBox(width: 16),
                Expanded(child: CustomTextField(label: 'Date', icon: Icons.calendar_today, readOnly: true)),
              ],
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Add Products / Services'),
            Autocomplete<Product>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<Product>.empty();
                return _mockProducts.where((p) => p.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              displayStringForOption: (Product option) => option.name,
              onSelected: (Product selection) {
                _addProduct(selection);
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: _inputDecoration('Search Product/Service to add', Icons.add_shopping_cart),
                );
              },
            ),
            
            const SizedBox(height: 16),
            if (_invoiceItems.isNotEmpty) ..._invoiceItems.asMap().entries.map((entry) {
              int idx = entry.key;
              InvoiceItem item = entry.value;
              return _buildInvoiceItemCard(idx, item);
            }),

            const SizedBox(height: 24),
            _buildSectionTitle('Tax Settings'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SwitchListTile(
                title: const Text('Apply GST (18%)', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Calculate 18% tax on subtotal'),
                activeTrackColor: AppColors.primary,
                value: _applyGST,
                onChanged: (val) => setState(() => _applyGST = val),
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Payment Details'),
            DropdownButtonFormField<String>(
              initialValue: _paymentStatus,
              decoration: _inputDecoration('Payment Status', Icons.info_outline),
              items: ['Paid', 'Pending', 'Partial'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _paymentStatus = val!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _paymentMethod,
              decoration: _inputDecoration('Payment Method', Icons.payment),
              items: ['Cash', 'UPI', 'Card', 'Bank Transfer'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _paymentMethod = val!),
            ),

            const SizedBox(height: 32),
            // Total Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.waterGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: AppColors.primaryLight.withAlpha(76), blurRadius: 12, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Subtotal', '₹ ${subtotal.toStringAsFixed(2)}'),
                  if (_applyGST) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow('GST (18%)', '₹ ${gstAmount.toStringAsFixed(2)}'),
                  ],
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white54),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Grand Total', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('₹ ${grandTotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            GradientButton(
              text: 'Save Invoice',
              icon: Icons.save,
              onPressed: () {
                if (_selectedCustomer == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a customer!'), backgroundColor: AppColors.error));
                  return;
                }
                if (_invoiceItems.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one product!'), backgroundColor: AppColors.error));
                  return;
                }
                context.pop();
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
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
      ),
    );
  }

  Widget _buildSelectedCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight),
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
                Text(_selectedCustomer!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(_selectedCustomer!.phone, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                Text(_selectedCustomer!.address, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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

  Widget _buildInvoiceItemCard(int index, InvoiceItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                onPressed: () {
                  setState(() => _invoiceItems.removeAt(index));
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹ ${item.product.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textSecondary)),
              Row(
                children: [
                  _qtyButton(Icons.remove, () => _updateQuantity(index, -1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  _qtyButton(Icons.add, () => _updateQuantity(index, 1)),
                ],
              ),
              Text('₹ ${item.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
            ],
          )
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
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.primaryLight, size: 22),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5)),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
