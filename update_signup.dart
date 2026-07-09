// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final file = File('lib/screens/auth/signup_screen.dart');
  
  const content = '''import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Community fields
  String _selectedRole = 'Individual';
  final TextEditingController _communityNameController = TextEditingController();
  final TextEditingController _communityAddressController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();

  Future<void> _signUp() async {
    final auth = context.read<AuthProvider>();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all basic fields.')),
      );
      return;
    }

    if (_selectedRole == 'Community based') {
      if (_communityNameController.text.trim().isEmpty ||
          _communityAddressController.text.trim().isEmpty ||
          _contactPhoneController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all community fields.')),
        );
        return;
      }
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    final success = await auth.signUpWithEmail(
      name, 
      email, 
      password,
      role: _selectedRole,
      communityName: _selectedRole == 'Community based' ? _communityNameController.text.trim() : null,
      communityAddress: _selectedRole == 'Community based' ? _communityAddressController.text.trim() : null,
      contactPhone: _selectedRole == 'Community based' ? _contactPhoneController.text.trim() : null,
    );
    
    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _communityNameController.dispose();
    _communityAddressController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join our community of earth guardians.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  if (auth.errorMessage == null) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.exclamationmark_circle,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            auth.errorMessage!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Role Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'Account Type',
                  prefixIcon: const Icon(CupertinoIcons.person_3, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'Individual', child: Text('Individual')),
                  DropdownMenuItem(value: 'Community based', child: Text('Community based')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Conditional Community Fields
              if (_selectedRole == 'Community based') ...[
                TextField(
                  controller: _communityNameController,
                  decoration: InputDecoration(
                    labelText: 'Name of Community',
                    prefixIcon: const Icon(CupertinoIcons.building_2_fill, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _communityAddressController,
                  decoration: InputDecoration(
                    labelText: 'Address of the Community',
                    prefixIcon: const Icon(CupertinoIcons.location_solid, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contactPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone No. of Respected Person',
                    prefixIcon: const Icon(CupertinoIcons.phone_fill, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Name Field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: _selectedRole == 'Community based' ? 'Contact Person Name' : 'Full Name',
                  prefixIcon: const Icon(CupertinoIcons.person, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Email Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(CupertinoIcons.mail, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(CupertinoIcons.lock, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password Field
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(CupertinoIcons.lock_shield, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                child: Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    return ElevatedButton(
                      onPressed: auth.isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
''';

  file.writeAsStringSync(content);
  print('Rewrote signup_screen.dart');
}
