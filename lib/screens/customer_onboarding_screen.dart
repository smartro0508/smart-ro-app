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
  final CustomerModel? customer;

  const CustomerOnboardingScreen({super.key, this.customer});

  @override
  State<CustomerOnboardingScreen> createState() =>
      _CustomerOnboardingScreenState();
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
  final _gstController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      final c = widget.customer!;
      _nameController.text = c.fullName;
      _phoneController.text = c.phoneNumber ?? '';
      _emailController.text = c.email ?? '';
      _addressController.text = c.address ?? '';
      _cityController.text = c.city ?? '';
      _stateController.text = c.state ?? '';
      _pincodeController.text = c.pincode ?? '';
      _countryController.text = c.country ?? '';
      _gstController.text = c.gstnumber ?? '';
    }
  }

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
    _gstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customer != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Customer' : 'Add New Customer',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
            const SizedBox(height: 16),
            CustomTextField(
              label: 'GST Number (Optional)',
              icon: Icons.confirmation_number_outlined,
              controller: _gstController,
              textCapitalization: TextCapitalization.characters,
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Address Details'),
            CustomTextField(
              label: 'Street Address',
              icon: Icons.home_outlined,
              controller: _addressController,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'City',
                    icon: Icons.location_city,
                    controller: _cityController,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'State',
                    icon: Icons.map_outlined,
                    controller: _stateController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Pincode',
                    icon: Icons.pin_drop_outlined,
                    keyboardType: TextInputType.number,
                    controller: _pincodeController,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'Country',
                    icon: Icons.public,
                    controller: _countryController,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
            BlocConsumer<CustomerCubit, CustomerState>(
              listener: (context, state) {
                if (state is CustomerAdded || state is CustomerUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state is CustomerUpdated
                            ? 'Customer Updated Successfully!'
                            : 'Customer Saved Successfully!',
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.pop();
                } else if (state is CustomerAddError ||
                    state is CustomerUpdateError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state is CustomerAddError
                            ? state.message
                            : (state as CustomerUpdateError).message,
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return GradientButton(
                  text: isEditing ? 'Update Customer' : 'Save Customer',
                  icon: Icons.check_circle_outline,
                  isLoading:
                      state is CustomerAdding || state is CustomerUpdating,
                  onPressed:
                      (state is CustomerAdding || state is CustomerUpdating)
                      ? () {}
                      : () {
                          if (_formKey.currentState!.validate()) {
                            final customer = CustomerModel(
                              id: isEditing ? widget.customer!.id : null,
                              fullName: _nameController.text.trim(),
                              phoneNumber: _phoneController.text.trim(),
                              email: _emailController.text.trim(),
                              address: _addressController.text.trim(),
                              city: _cityController.text.trim(),
                              state: _stateController.text.trim(),
                              pincode: _pincodeController.text.trim(),
                              country: _countryController.text.trim(),
                              gstnumber: _gstController.text.trim().isEmpty
                                  ? null
                                  : _gstController.text.trim(),
                            );
                            if (isEditing) {
                              context.read<CustomerCubit>().updateCustomer(
                                customer.id!,
                                customer,
                              );
                            } else {
                              context.read<CustomerCubit>().addCustomer(
                                customer,
                              );
                            }
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
