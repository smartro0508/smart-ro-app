import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../controller/setting_cubit.dart';
import '../controller/setting_state.dart';
import '../models/setting_model.dart';
import '../widgets/premium_animated_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for editable fields
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SettingCubit>().getSettings();
  }

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
      final setting = SettingModel(
        companyName: _companyNameController.text.trim(),
        supportEmail: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        businessAddress: _addressController.text.trim(),
      );
      context.read<SettingCubit>().updateSettings(setting);
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

  void _showQrCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Shop QR Code', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200.0,
              height: 200.0,
              child: QrImageView(
                data: 'https://www.smartro.shop/',
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Scan to visit our shop', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                final qrValidationResult = QrValidator.validate(
                  data: 'https://www.smartro.shop/',
                  version: QrVersions.auto,
                  errorCorrectionLevel: QrErrorCorrectLevel.L,
                );

                if (qrValidationResult.status == QrValidationStatus.valid) {
                  final qrCode = qrValidationResult.qrCode;
                  final painter = QrPainter.withQr(
                    qr: qrCode!,
                    color: const Color(0xFF000000),
                    emptyColor: const Color(0xFFFFFFFF),
                    gapless: true,
                  );

                  final picData = await painter.toImageData(2048, format: ui.ImageByteFormat.png);
                  if (picData != null) {
                    final tempDir = await getTemporaryDirectory();
                    final file = File('${tempDir.path}/smartro_shop_qr.png');
                    await file.writeAsBytes(picData.buffer.asUint8List());
                    
                    await Share.shareXFiles(
                      [XFile(file.path)], 
                      text: 'Check out our shop at https://www.smartro.shop/'
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to share QR code: $e')),
                  );
                }
              }
            },
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Share Link'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
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
            const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        centerTitle: true,
      ),
      body: BlocListener<SettingCubit, SettingState>(
        listener: (context, state) {
          if (state is SettingLoaded) {
            _companyNameController.text = state.setting.companyName;
            _emailController.text = state.setting.supportEmail;
            _phoneController.text = state.setting.phoneNumber;
            _addressController.text = state.setting.businessAddress;
          } else if (state is SettingUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Settings Updated Successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is SettingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          } else if (state is SettingUpdateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        child: Form(
          key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Padding(
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
                  const Text(
                    'Company Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            
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
            
            BlocBuilder<SettingCubit, SettingState>(
              builder: (context, state) {
                if (state is SettingLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return GradientButton(
                  text: 'Save Changes',
                  icon: Icons.save_outlined,
                  isLoading: state is SettingUpdating,
                  onPressed: state is SettingUpdating ? () {} : _saveSettings,
                );
              },
            ),
            
            const SizedBox(height: 48),
            
            ElevatedButton.icon(
              onPressed: () => _showQrCodeDialog(context),
              icon: const Icon(Icons.qr_code_2),
              label: const Text('Share Shop Link (QR)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withAlpha(25),
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),

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
      ),
    );
  }
}
