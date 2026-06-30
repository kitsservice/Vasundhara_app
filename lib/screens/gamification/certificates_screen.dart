import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/user_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/certificate_service.dart';
import '../../theme/app_colors.dart';

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMarathi = context.watch<SettingsProvider>().isMarathi;
    final userProvider = context.watch<UserProvider>();
    final treesPlanted = userProvider.totalTreesPlanted;
    final userName =
        FirebaseAuth.instance.currentUser?.displayName ?? 'Green Guardian';

    // Define the milestones
    final milestones = [
      {
        'title': '🌱 Seedling',
        'requirement': 1,
        'description': isMarathi
            ? 'पहिले झाड लावले'
            : 'Awarded for planting your very first tree.',
      },
      {
        'title': '🌿 Green Guardian',
        'requirement': 11,
        'description': isMarathi
            ? '११ झाडे लावली'
            : 'Awarded for reaching the milestone of 11 trees.',
      },
      {
        'title': '🌳 Forest Master',
        'requirement': 50,
        'description': isMarathi
            ? '५० झाडे लावली'
            : 'Awarded for an extraordinary contribution of 50 trees.',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          isMarathi ? 'माझी प्रमाणपत्रे' : 'My Certificates',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: milestones.length,
        itemBuilder: (context, index) {
          final milestone = milestones[index];
          final requirement = milestone['requirement'] as int;
          final isUnlocked = treesPlanted >= requirement;
          final title = milestone['title'] as String;
          final desc = milestone['description'] as String;

          return Card(
            elevation: isUnlocked ? 4 : 0,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isUnlocked
                  ? BorderSide.none
                  : BorderSide(color: Colors.grey.shade300),
            ),
            color: isUnlocked ? Colors.white : Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked
                              ? AppColors.primary
                              : Colors.grey.shade500,
                        ),
                      ),
                      if (isUnlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'UNLOCKED',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        )
                      else
                        Icon(
                          CupertinoIcons.lock_fill,
                          color: Colors.grey.shade400,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isUnlocked
                          ? AppColors.textSecondary
                          : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isUnlocked)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          try {
                            await CertificateService
                                .generateAndShareMilestoneCertificate(
                              userName: userName.isNotEmpty
                                  ? userName
                                  : 'Green Guardian',
                              badgeName: title.substring(3), // Remove emoji
                              treesPlanted: treesPlanted,
                            );
                            if (context.mounted) {
                              Navigator.pop(context); // Hide loading
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context); // Hide loading
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error generating certificate: $e',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(
                          CupertinoIcons.doc_text,
                          color: Colors.white,
                        ),
                        label: Text(
                          isMarathi
                              ? 'प्रमाणपत्र डाउनलोड करा'
                              : 'Download Certificate',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          isMarathi
                              ? '${requirement - treesPlanted} आणखी झाडे आवश्यक आहेत'
                              : 'Plant ${requirement - treesPlanted} more trees to unlock',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                          ),
                        ),
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
}
