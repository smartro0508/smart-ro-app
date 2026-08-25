import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../controller/product_cubit.dart';
import '../controller/product_state.dart';
import '../models/product_model.dart';
import '../utils/api_constants.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product;
  
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _descController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _discountController = TextEditingController();
  final _priceController = TextEditingController();
  final _featuresController = TextEditingController();
  final _specsController = TextEditingController();
  final _warrantyController = TextEditingController();
  
  String _status = 'Active';
  bool _isFeatured = false;
  
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final p = widget.product!;
      _nameController.text = p.name;
      _shortDescController.text = p.shortDescription ?? '';
      _descController.text = p.description ?? '';
      _originalPriceController.text = p.originalPrice?.toString() ?? '';
      _discountController.text = p.discount?.toString() ?? '';
      _priceController.text = p.price.toString();
      _featuresController.text = p.features?.join('\n') ?? '';
      
      if (p.specifications != null) {
        _specsController.text = p.specifications!.entries.map((e) => '${e.key}: ${e.value}').join('\n');
      }
      
      _warrantyController.text = p.warranty ?? '';
      _status = p.status == 'Inactive' ? 'Inactive' : 'Active';
      _isFeatured = p.isFeatured ?? false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortDescController.dispose();
    _descController.dispose();
    _originalPriceController.dispose();
    _discountController.dispose();
    _priceController.dispose();
    _featuresController.dispose();
    _specsController.dispose();
    _warrantyController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = picked;
      });
    }
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
            _buildSectionTitle('Product Image'),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryLight, width: 2),
                    image: _imageFile != null
                        ? DecorationImage(image: FileImage(File(_imageFile!.path)), fit: BoxFit.cover)
                        : (isEditing && widget.product?.mainImage != null
                            ? DecorationImage(
                                image: NetworkImage('${ApiConstants.imageBaseUrl}${widget.product!.mainImage}'),
                                fit: BoxFit.cover,
                              )
                            : null),
                  ),
                  child: (_imageFile == null && !(isEditing && widget.product?.mainImage != null))
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: AppColors.primary, size: 40),
                            SizedBox(height: 8),
                            Text('Upload Image', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ],
                        )
                      : null,
                ),
              ),
            ),
              
            const SizedBox(height: 32),
            _buildSectionTitle('Basic Information'),
            CustomTextField(
              label: 'Product Name *', 
              icon: Icons.inventory_2_outlined,
              controller: _nameController,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Short Description', 
              icon: Icons.short_text,
              controller: _shortDescController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Full Description', 
              icon: Icons.description_outlined,
              controller: _descController,
              maxLines: 3,
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Pricing Details'),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Original Price (₹)', 
                    icon: Icons.currency_rupee, 
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    controller: _originalPriceController,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'Discount (%)', 
                    icon: Icons.percent, 
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    controller: _discountController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Selling Price (₹) *', 
              icon: Icons.currency_rupee, 
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              controller: _priceController,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Enter a valid number';
                return null;
              },
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Features & Specifications'),
            CustomTextField(
              label: 'Key Features (One per line)', 
              icon: Icons.featured_play_list_outlined,
              controller: _featuresController,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Technical Specs (Key: Value)', 
              icon: Icons.list_alt,
              controller: _specsController,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Warranty Details', 
              icon: Icons.verified_user_outlined,
              controller: _warrantyController,
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Publish Status'),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: InputDecoration(
                labelText: 'Status',
                prefixIcon: const Icon(Icons.public, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Active', child: Text('Active / Published')),
                DropdownMenuItem(value: 'Inactive', child: Text('Inactive / Hidden')),
              ],
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                title: const Text('Mark as Featured Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                value: _isFeatured,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _isFeatured = v),
              ),
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
                      
                      final features = _featuresController.text.split('\n').where((s) => s.trim().isNotEmpty).toList();
                      
                      final Map<String, dynamic> specs = {};
                      final specsLines = _specsController.text.split('\n');
                      for (var line in specsLines) {
                        final idx = line.indexOf(':');
                        if (idx > -1) {
                          final k = line.substring(0, idx).trim();
                          final v = line.substring(idx + 1).trim();
                          if (k.isNotEmpty && v.isNotEmpty) {
                            specs[k] = v;
                          }
                        }
                      }

                      final product = ProductModel(
                        id: isEditing ? widget.product!.id : null,
                        name: _nameController.text.trim(),
                        shortDescription: _shortDescController.text.trim(),
                        description: _descController.text.trim(),
                        originalPrice: double.tryParse(_originalPriceController.text.trim()),
                        discount: double.tryParse(_discountController.text.trim()),
                        price: double.parse(_priceController.text.trim()),
                        features: features,
                        specifications: specs,
                        warranty: _warrantyController.text.trim(),
                        status: _status,
                        isFeatured: _isFeatured,
                      );
                      
                      if (isEditing) {
                        context.read<ProductCubit>().updateProduct(product, imageFile: _imageFile);
                      } else {
                        context.read<ProductCubit>().addProduct(product, imageFile: _imageFile);
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
