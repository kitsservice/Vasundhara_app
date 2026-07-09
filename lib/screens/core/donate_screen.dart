import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _quantityController = TextEditingController();
  final _addressController = TextEditingController();
  final _reasonController = TextEditingController();
  String _selectedDonationType = 'Trees / Saplings';
  bool _isSubmitting = false;

  final List<String> _donationTypesEn = [
    'Trees / Saplings',
    'Land for Plantation',
    'Seed Balls',
    'Fertilizers',
  ];

  final List<String> _donationTypesMr = [
    'झाडे / रोपे',
    'वृक्षारोपणासाठी जमीन',
    'सीड बॉल्स (बीजगोळे)',
    'खते',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _quantityController.dispose();
    _addressController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(bool isMarathi) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      try {
        final user = FirebaseAuth.instance.currentUser;
        final amountOrQty = double.tryParse(_quantityController.text.trim()) ?? 0.0;

        // Save to donations collection
        await FirebaseFirestore.instance.collection('donations').add({
          'userId': user?.uid ?? 'anonymous',
          'userName': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'type': _selectedDonationType,
          'amount': amountOrQty,
          'address': _addressController.text.trim(),
          'reason': _reasonController.text.trim(),
          'status': 'pending',
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Notify Admin
        await FirebaseFirestore.instance.collection('admin_notifications').add({
          'title': 'New Donation Request',
          'message': '${_nameController.text.trim()} requested to donate $_selectedDonationType',
          'type': 'donation_request',
          'userName': _nameController.text.trim(),
          'amount': amountOrQty,
          'status': 'pending',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Unlock Gamification Badge
        if (mounted) {
          context.read<UserProvider>().unlockBadge('green_philanthropist');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ui_key_25'.tr()),
              backgroundColor: AppColors.primary,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        debugPrint('Error submitting donation: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error submitting request.')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMarathi = context.locale.languageCode == 'mr';
    final List<String> currentTypes =
        isMarathi ? _donationTypesMr : _donationTypesEn;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'ui_key_26'.tr(),
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ui_key_27'.tr(),
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
              const SizedBox(height: 12),
              Text(
                'ui_key_28'.tr(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
              const SizedBox(height: 32),

              // Name Field
              CustomLabel(text: 'ui_key_29'.tr()),
              CustomTextField(
                controller: _nameController,
                icon: CupertinoIcons.person_solid,
                hintText:
                    'ui_key_30'.tr(),
                validatorText: 'ui_key_31'.tr(),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 20),

              // Phone Field
              CustomLabel(text: 'ui_key_32'.tr()),
              CustomTextField(
                controller: _phoneController,
                icon: CupertinoIcons.phone_fill,
                hintText: 'ui_key_33'.tr(),
                keyboardType: TextInputType.phone,
                validatorText: 'ui_key_34'.tr(),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 20),

              // Donation Type Dropdown
              CustomLabel(text: 'ui_key_35'.tr()),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: isMarathi
                      ? _donationTypesMr[
                          _donationTypesEn.indexOf(_selectedDonationType)]
                      : _selectedDonationType,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      CupertinoIcons.gift_fill,
                      color: AppColors.primary,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  icon: const Icon(
                    CupertinoIcons.chevron_down,
                    color: Colors.grey,
                  ),
                  items: currentTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(
                        type,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        // Keep internal state in English to maintain consistency, or map back
                        if (isMarathi) {
                          _selectedDonationType =
                              _donationTypesEn[_donationTypesMr.indexOf(val)];
                        } else {
                          _selectedDonationType = val;
                        }
                      });
                    }
                  },
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 20),

              // Quantity / Details
              CustomLabel(
                text: 'ui_key_36'.tr(),
              ),
              CustomTextField(
                controller: _quantityController,
                icon: CupertinoIcons.info_circle_fill,
                hintText: 'ui_key_37'.tr(),
                validatorText: 'ui_key_38'.tr(),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 20),

              // Location / Address
              CustomLabel(
                text: 'ui_key_39'.tr(),
              ),
              CustomTextField(
                controller: _addressController,
                icon: CupertinoIcons.location_solid,
                hintText: 'ui_key_40'.tr(),
                maxLines: 3,
                validatorText: 'ui_key_41'.tr(),
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 20),

              // Reason for Donation
              CustomLabel(
                text:
                    'ui_key_42'.tr(),
              ),
              CustomTextField(
                controller: _reasonController,
                icon: CupertinoIcons.text_quote,
                hintText: 'ui_key_43'.tr(),
                maxLines: 2,
                validatorText: 'ui_key_44'.tr(),
              ).animate().fadeIn(delay: 650.ms),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submitForm(isMarathi),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : Text(
                        'ui_key_45'.tr(),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                ),
              ).animate().fadeIn(delay: 750.ms).slideY(begin: 0.2),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
