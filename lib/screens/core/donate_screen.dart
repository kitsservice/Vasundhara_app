import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/settings_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/custom_text_field.dart';

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

  void _submitForm(bool isMarathi) {
    if (_formKey.currentState!.validate()) {
      // Dummy Submission Logic
      // Unlock Gamification Badge
      context.read<UserProvider>().unlockBadge('green_philanthropist');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isMarathi
                ? 'तुमच्या दानाबद्दल धन्यवाद! तुम्हाला "ग्रीन फिलान्थ्रोपिस्ट" बॅज मिळाला आहे!'
                : 'Donation Accepted! You earned the "Green Philanthropist" badge!',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMarathi = context.watch<SettingsProvider>().isMarathi;
    final List<String> currentTypes =
        isMarathi ? _donationTypesMr : _donationTypesEn;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isMarathi ? 'दान करा' : 'Make a Donation',
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
                isMarathi
                    ? 'तुम्ही वसुंधरासाठी काय दान करू इच्छिता?'
                    : 'What would you like to donate for Vasundhara?',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
              const SizedBox(height: 12),
              Text(
                isMarathi
                    ? 'हरित वसुंधरा अभियान अधिक प्रभावी बनवण्यासाठी तुम्ही जमीन, रोपे किंवा इतर साहित्य दान करू शकता.'
                    : 'Help make the Green Vasundhara Abhiyan more effective by donating land, saplings, or other materials.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
              const SizedBox(height: 32),

              // Name Field
              CustomLabel(text: isMarathi ? 'पूर्ण नाव' : 'Full Name'),
              CustomTextField(
                controller: _nameController,
                icon: CupertinoIcons.person_solid,
                hintText:
                    isMarathi ? 'तुमचे नाव प्रविष्ट करा' : 'Enter your name',
                validatorText: isMarathi
                    ? 'कृपया नाव प्रविष्ट करा'
                    : 'Please enter a name',
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 20),

              // Phone Field
              CustomLabel(text: isMarathi ? 'फोन नंबर' : 'Phone Number'),
              CustomTextField(
                controller: _phoneController,
                icon: CupertinoIcons.phone_fill,
                hintText: isMarathi
                    ? 'तुमचा फोन नंबर प्रविष्ट करा'
                    : 'Enter your phone number',
                keyboardType: TextInputType.phone,
                validatorText: isMarathi
                    ? 'कृपया वैध फोन नंबर प्रविष्ट करा'
                    : 'Please enter a valid phone number',
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 20),

              // Donation Type Dropdown
              CustomLabel(text: isMarathi ? 'दान प्रकार' : 'Donation Type'),
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
                text: isMarathi ? 'तपशील किंवा प्रमाण' : 'Details or Quantity',
              ),
              CustomTextField(
                controller: _quantityController,
                icon: CupertinoIcons.info_circle_fill,
                hintText: isMarathi
                    ? 'उदा. ५०० बीजगोळे, २ एकर जमीन'
                    : 'e.g., 500 Seed balls, 2 acres land',
                validatorText: isMarathi
                    ? 'कृपया तपशील प्रविष्ट करा'
                    : 'Please enter details',
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 20),

              // Location / Address
              CustomLabel(
                text: isMarathi ? 'पत्ता / ठिकाण' : 'Address / Location',
              ),
              CustomTextField(
                controller: _addressController,
                icon: CupertinoIcons.location_solid,
                hintText: isMarathi
                    ? 'पूर्ण पत्ता प्रविष्ट करा'
                    : 'Enter complete address',
                maxLines: 3,
                validatorText: isMarathi
                    ? 'कृपया पत्ता प्रविष्ट करा'
                    : 'Please enter an address',
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 20),

              // Reason for Donation
              CustomLabel(
                text:
                    isMarathi ? 'दानाचा उद्देश / कारण' : 'Reason for Donation',
              ),
              CustomTextField(
                controller: _reasonController,
                icon: CupertinoIcons.text_quote,
                hintText: isMarathi
                    ? 'दानाचा उद्देश सांगा (उदा. वाढदिवस, स्मरणार्थ)'
                    : 'State the reason (e.g. Birthday, Memorial)',
                maxLines: 2,
                validatorText: isMarathi
                    ? 'कृपया दानाचे कारण सांगा'
                    : 'Please provide a reason',
              ).animate().fadeIn(delay: 650.ms),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _submitForm(isMarathi),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  child: Text(
                    isMarathi ? 'दान पाठवा' : 'Submit Donation Request',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
