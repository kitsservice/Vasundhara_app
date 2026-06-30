import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import '../theme/app_colors.dart';

class AdminNurseryRegistrationSheet extends StatefulWidget {
  const AdminNurseryRegistrationSheet({super.key});

  @override
  State<AdminNurseryRegistrationSheet> createState() =>
      _AdminNurseryRegistrationSheetState();
}

class _AdminNurseryRegistrationSheetState
    extends State<AdminNurseryRegistrationSheet> {
  final _nameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _mobileNoController = TextEditingController();
  final _plantsController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _registerNursery() async {
    final name = _nameController.text.trim();
    final ownerName = _ownerNameController.text.trim();
    final mobileNo = _mobileNoController.text.trim();
    final plants = _plantsController.text.trim();

    final address = _addressController.text.trim();

    if (name.isEmpty ||
        ownerName.isEmpty ||
        mobileNo.isEmpty ||
        plants.isEmpty ||
        address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields, including a full address'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Default to Pune city center in case geocoding fails (common on emulators)
      double lat = 18.5204;
      double lng = 73.8567;

      try {
        final List<Location> locations = await locationFromAddress(address)
            .timeout(const Duration(seconds: 5));
        if (locations.isNotEmpty) {
          lat = locations.first.latitude;
          lng = locations.first.longitude;
        }
      } catch (e) {
        debugPrint('Geocoding failed, using fallback coordinates: $e');
      }

      await FirebaseFirestore.instance.collection('nurseries').add({
        'name_en': name,
        'ownerName': ownerName,
        'mobileNo': mobileNo,
        'plants': plants,
        'location': GeoPoint(lat, lng),
        'address': address,
        'rating': 5.0, // Default rating for new nurseries
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context); // Close the bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nursery Registered Successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error registering nursery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerNameController.dispose();
    _mobileNoController.dispose();
    _plantsController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Register Nursery',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new nursery to the global map.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Nursery Name'),
                  const SizedBox(height: 8),
                  _buildTextField(_nameController, 'e.g., Green Leaf Nursery'),
                  const SizedBox(height: 16),
                  _buildLabel('Owner Name'),
                  const SizedBox(height: 8),
                  _buildTextField(_ownerNameController, 'e.g., Ramesh Patel'),
                  const SizedBox(height: 16),
                  _buildLabel('Mobile Number'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    _mobileNoController,
                    'e.g., 9876543210',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Available Plants'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    _plantsController,
                    'e.g., Mango, Neem, Tulsi...',
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Full Address (Auto-Geocoded)'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    _addressController,
                    'e.g., 123 Green Street, Pune, Maharashtra',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _registerNursery,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Register Nursery',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
