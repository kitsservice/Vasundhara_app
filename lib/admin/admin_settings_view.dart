import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AdminSettingsView extends StatelessWidget {
  const AdminSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1F2937),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your admin account and preferences.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.person_solid,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  title: Text(
                    'Profile Details',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  subtitle: Text(
                    'admin@vasundhara.app',
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                  trailing: const Icon(
                    CupertinoIcons.chevron_right,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
                const Divider(height: 1, indent: 70),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF2F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.square_arrow_right,
                      color: Colors.redAccent,
                    ),
                  ),
                  title: Text(
                    'Logout',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  onTap: () {
                    // Show confirmation dialog before logging out
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Text(
                            'Logout',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to log out of the Admin panel?',
                            style: GoogleFonts.inter(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Provider.of<AuthProvider>(
                                  context,
                                  listen: false,
                                ).signOut();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Logout',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
