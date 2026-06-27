import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/user_provider.dart';
import '../theme/app_colors.dart';
import 'certificate_screen.dart';

class CertificatesListScreen extends StatelessWidget {
  const CertificatesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final totalTrees = userProvider.totalTreesPlanted;

    // Calculate earned certificates based on 1, 10, 20, 30... scale
    final List<Map<String, dynamic>> certificates = [];

    if (totalTrees >= 1) {
      certificates.add({
        'title': 'Green Starter',
        'milestone': '1st Tree Planted',
        'earnedAt':
            DateTime.now(), // In a real app, track exact date of 1st tree
        'trees': 1,
      });
    }

    // Add milestones for every 10 trees
    for (int i = 10; i <= totalTrees; i += 10) {
      certificates.add({
        'title': _getTitleForMilestone(i),
        'milestone': '$i Trees Planted',
        'earnedAt': DateTime.now(), // Mock date
        'trees': i,
      });
    }

    // Sort so newest is at the top
    certificates.sort((a, b) => b['trees'].compareTo(a['trees']));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Certificates',
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: certificates.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.doc_plaintext,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Certificates Yet',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Plant your first tree to earn your first certificate!',
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: certificates.length,
              itemBuilder: (context, index) {
                final cert = certificates[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CertificateScreen(
                          userName:
                              FirebaseAuth.instance.currentUser?.displayName ??
                                  'Eco Guardian',
                          title: cert['title'],
                          milestone: cert['milestone'],
                          trees: cert['trees'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                          ),
                          child: const Icon(
                            CupertinoIcons.rosette,
                            color: Colors.yellow,
                            size: 40,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cert['title'],
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1B5E20),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cert['milestone'],
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF2E7D32),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Icon(
                            CupertinoIcons.chevron_right,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _getTitleForMilestone(int trees) {
    if (trees >= 100) return 'Global Earth Saver';
    if (trees >= 50) return 'Green Ambassador';
    if (trees >= 30) return 'Eco Champion';
    if (trees >= 20) return 'Nature Guardian';
    return 'Green Warrior';
  }
}
