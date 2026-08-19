import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';

class CustomerOnboardingScreen extends StatefulWidget {
  const CustomerOnboardingScreen({super.key});

  @override
  State<CustomerOnboardingScreen> createState() => _CustomerOnboardingScreenState();
}

class _CustomerOnboardingScreenState extends State<CustomerOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

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
            const CustomTextField(label: 'Customer Name *', icon: Icons.person),
            const SizedBox(height: 16),
            const CustomTextField(label: 'Mobile Number *', icon: Icons.phone, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            const CustomTextField(label: 'WhatsApp Number', icon: Icons.chat),
            const SizedBox(height: 16),
            const CustomTextField(label: 'Email Address', icon: Icons.email, keyboardType: TextInputType.emailAddress),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Address Details'),
            const CustomTextField(label: 'Street Address', icon: Icons.home_outlined),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(child: CustomTextField(label: 'City', icon: Icons.location_city)),
                SizedBox(width: 16),
                Expanded(child: CustomTextField(label: 'State', icon: Icons.map_outlined)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(child: CustomTextField(label: 'Pincode', icon: Icons.pin_drop_outlined, keyboardType: TextInputType.number)),
                SizedBox(width: 16),
                Expanded(child: CustomTextField(label: 'Country', icon: Icons.public)),
              ],
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('RO Machine Details'),
            const CustomTextField(label: 'Machine Model', icon: Icons.water_drop_outlined),
            const SizedBox(height: 16),
            const CustomTextField(label: 'Installation Date', icon: Icons.calendar_month, readOnly: true),
            const SizedBox(height: 16),
            const CustomTextField(label: 'Service Notes', icon: Icons.notes, maxLines: 3),

            const SizedBox(height: 40),
            GradientButton(
              text: 'Save Customer',
              icon: Icons.check_circle_outline,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Customer Saved Successfully!'), 
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.pop();
                }
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
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}
