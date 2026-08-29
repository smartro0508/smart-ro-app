import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../controller/service_cubit.dart';
import '../controller/service_state.dart';
import '../models/service_model.dart';

class ServiceFormScreen extends StatefulWidget {
  final ServiceModel? service;
  
  const ServiceFormScreen({super.key, this.service});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _costController = TextEditingController();
  final _productCostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      final s = widget.service!;
      _nameController.text = s.servicename;
      _descController.text = s.description ?? '';
      _costController.text = s.servicecost.toString();
      _productCostController.text = s.serviceproductcost.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _costController.dispose();
    _productCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.service != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Service' : 'Add New Service', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _buildSectionTitle('Service Information'),
            CustomTextField(
              label: 'Service Name *', 
              icon: Icons.home_repair_service_outlined,
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
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Service Cost *', 
                    icon: Icons.currency_rupee, 
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    controller: _costController,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Enter a valid number';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'Product Cost', 
                    icon: Icons.shopping_cart_outlined, 
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    controller: _productCostController,
                    validator: (v) {
                      if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
            BlocConsumer<ServiceCubit, ServiceState>(
              listener: (context, state) {
                if (state is ServiceAdded) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? 'Service Updated Successfully!' : 'Service Saved Successfully!'), 
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.pop();
                } else if (state is ServiceAddError) {
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
                  text: isEditing ? 'Update Service' : 'Save Service',
                  icon: Icons.check_circle_outline,
                  isLoading: state is ServiceAdding,
                  onPressed: state is ServiceAdding ? () {} : () {
                    if (_formKey.currentState!.validate()) {
                      final service = ServiceModel(
                        id: isEditing ? widget.service!.id : null,
                        servicename: _nameController.text.trim(),
                        description: _descController.text.trim(),
                        servicecost: double.parse(_costController.text.trim()),
                        serviceproductcost: _productCostController.text.trim().isEmpty 
                          ? 0.0 
                          : double.parse(_productCostController.text.trim()),
                      );
                      
                      if (isEditing) {
                        context.read<ServiceCubit>().updateService(service);
                      } else {
                        context.read<ServiceCubit>().addService(service);
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
