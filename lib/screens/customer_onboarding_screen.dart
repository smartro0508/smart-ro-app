import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../controller/customer_cubit.dart';
import '../controller/customer_state.dart';
import '../models/customer_model.dart';

class CustomerOnboardingScreen extends StatefulWidget {
  const CustomerOnboardingScreen({super.key});

  @override
  State<CustomerOnboardingScreen> createState() => _CustomerOnboardingScreenState();
}

class _CustomerOnboardingScreenState extends State<CustomerOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Customer', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _buildSectionTitle('Personal Details'),
            CustomTextField(
              label: 'Customer Name *', 
              icon: Icons.person,
              controller: _nameController,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Mobile Number *', 
              icon: Icons.phone, 
              keyboardType: TextInputType.phone,
              controller: _phoneController,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),

            const SizedBox(height: 16),
            CustomTextField(
              label: 'Email Address', 
              icon: Icons.email, 
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Address Details'),
            CustomTextField(label: 'Street Address', icon: Icons.home_outlined, controller: _addressController),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: CustomTextField(label: 'City', icon: Icons.location_city, controller: _cityController)),
                const SizedBox(width: 16),
                Expanded(child: CustomTextField(label: 'State', icon: Icons.map_outlined, controller: _stateController)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: CustomTextField(label: 'Pincode', icon: Icons.pin_drop_outlined, keyboardType: TextInputType.number, controller: _pincodeController)),
                const SizedBox(width: 16),
                Expanded(child: CustomTextField(label: 'Country', icon: Icons.public, controller: _countryController)),
              ],
            ),



            const SizedBox(height: 40),
            BlocConsumer<CustomerCubit, CustomerState>(
              listener: (context, state) {
                if (state is CustomerAdded) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Customer Saved Successfully!'), 
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.pop();
                } else if (state is CustomerAddError) {
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
                  text: 'Save Customer',
                  icon: Icons.check_circle_outline,
                  isLoading: state is CustomerAdding,
                  onPressed: state is CustomerAdding ? () {} : () {
                    if (_formKey.currentState!.validate()) {
                      final customer = CustomerModel(
                        fullName: _nameController.text.trim(),
                        phoneNumber: _phoneController.text.trim(),
                        email: _emailController.text.trim(),
                        address: _addressController.text.trim(),
                        city: _cityController.text.trim(),
                        state: _stateController.text.trim(),
                        pincode: _pincodeController.text.trim(),
                        country: _countryController.text.trim(),
                      );
                      context.read<CustomerCubit>().addCustomer(customer);
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 20),
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
