import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../controller/product_cubit.dart';
import '../controller/product_state.dart';
import '../models/product_model.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product;
  
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _hsnController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final p = widget.product!;
      _nameController.text = p.productname;
      _descController.text = p.description ?? '';
      _priceController.text = p.price.toString();
      _hsnController.text = p.hsncode ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _hsnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add New Product', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _buildSectionTitle('Product Information'),
            CustomTextField(
              label: 'Product Name *', 
              icon: Icons.inventory_2_outlined,
              controller: _nameController,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Description', 
              icon: Icons.description_outlined,
              controller: _descController,
              maxLines: 3,
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Pricing Details'),
            CustomTextField(
              label: 'Price (₹) *', 
              icon: Icons.currency_rupee, 
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              controller: _priceController,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'HSN Code', 
              icon: Icons.numbers_outlined,
              controller: _hsnController,
            ),

            const SizedBox(height: 40),
            BlocConsumer<ProductCubit, ProductState>(
              listener: (context, state) {
                if (state is ProductAdded) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? 'Product Updated Successfully!' : 'Product Saved Successfully!'), 
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.pop();
                } else if (state is ProductAddError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message), 
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return GradientButton(
                  text: isEditing ? 'Update Product' : 'Save Product',
                  icon: Icons.check_circle_outline,
                  isLoading: state is ProductAdding,
                  onPressed: state is ProductAdding ? () {} : () {
                    if (_formKey.currentState!.validate()) {
                      final product = ProductModel(
                        id: isEditing ? widget.product!.id : null,
                        productname: _nameController.text.trim(),
                        description: _descController.text.trim(),
                        price: double.parse(_priceController.text.trim()),
                        hsncode: _hsnController.text.trim().isEmpty ? null : _hsnController.text.trim(),
                      );
                      
                      if (isEditing) {
                        context.read<ProductCubit>().updateProduct(product);
                      } else {
                        context.read<ProductCubit>().addProduct(product);
                      }
                    }
                  },
                );
              },
            ),
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
}
