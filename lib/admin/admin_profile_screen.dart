import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  bool _showPublicContact = false;
  bool _isLoading = true;
  final _user = FirebaseAuth.instance.currentUser;

  int _verifiedTreesCount = 0;
  int _nurseriesCount = 0;
  int _donationsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (_user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();
      if (doc.exists && doc.data()!.containsKey('showPublicContact')) {
        _showPublicContact = doc.data()!['showPublicContact'] ?? false;
      }

      final treesSnapshot = await FirebaseFirestore.instance
          .collection('planted_trees')
          .where('status', isEqualTo: 'verified')
          .count()
          .get();
      final nurseriesSnapshot = await FirebaseFirestore.instance
          .collection('nurseries')
          .count()
          .get();
      final donationsSnapshot = await FirebaseFirestore.instance
          .collection('donations')
          .where('status', isEqualTo: 'confirmed')
          .count()
          .get();

      setState(() {
        _verifiedTreesCount = treesSnapshot.count ?? 0;
        _nurseriesCount = nurseriesSnapshot.count ?? 0;
        _donationsCount = donationsSnapshot.count ?? 0;
      });
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _togglePublicContact(bool value) async {
    if (_user == null) return;
    setState(() => _showPublicContact = value);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .set({'showPublicContact': value}, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? 'Your contact is now visible to users for support.'
                  : 'Your contact is now hidden.',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      // Revert if failed
      setState(() => _showPublicContact = !value);
      debugPrint('Error updating profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = _user?.displayName ?? 'Admin';
    final userEmail = _user?.email ?? 'admin@vasundhara.app';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Admin Profile',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            CupertinoIcons.person_solid,
                            size: 50,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userName,
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Super Admin',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Stats Section
                  Text(
                    'Activity & Impact',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Verified\nTrees',
                          '$_verifiedTreesCount',
                          CupertinoIcons.checkmark_seal_fill,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Nurseries\nOnboarded',
                          '$_nurseriesCount',
                          CupertinoIcons.house_fill,
                          Colors.teal,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Donations\nProcessed',
                          '$_donationsCount',
                          CupertinoIcons.gift_fill,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Preferences Section
                  Text(
                    'Preferences',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SwitchListTile(
                      value: _showPublicContact,
                      onChanged: _togglePublicContact,
                      activeThumbColor: AppColors.primary,
                      title: Text(
                        'Public Contact Display',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Show my email/phone to users for Support',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.phone_circle_fill,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
