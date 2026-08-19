import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for editable fields
  final _companyNameController = TextEditingController(text: 'AURO Water Solutions');
  final _emailController = TextEditingController(text: 'support@auro.com');
  final _phoneController = TextEditingController(text: '+91 1800-RO-WATER');
  final _addressController = TextEditingController(text: '123 Tech Park, Water Purifier Hub\nNew Delhi, India');

  @override
  void dispose() {
    _companyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings Updated Successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out from Smart RO?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            const Text(
              'Company Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 20),
            
            CustomTextField(
              label: 'Company Name',
              icon: Icons.business,
              controller: _companyNameController,
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              label: 'Support Email',
              icon: Icons.email_outlined,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              label: 'Business Address',
              icon: Icons.location_on_outlined,
              controller: _addressController,
              maxLines: 3,
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 32),
            
            GradientButton(
              text: 'Save Changes',
              icon: Icons.save_outlined,
              onPressed: _saveSettings,
            ),
            
            const SizedBox(height: 48),
            
            ElevatedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error.withAlpha(25),
                foregroundColor: AppColors.error,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
