import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';

class AdminSuggestedSitesScreen extends StatelessWidget {
  const AdminSuggestedSitesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Suggested Sites',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('suggested_sites')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No suggested sites available.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              final description = data['description'] as String? ?? 'No description';
              final status = data['status'] as String? ?? 'pending';
              
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              description,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          _buildStatusBadge(status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(CupertinoIcons.location, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Lat: ${(data['latitude'] ?? 0).toStringAsFixed(4)}, Lng: ${(data['longitude'] ?? 0).toStringAsFixed(4)}',
                            style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (status == 'pending')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _updateStatus(context, doc.id, 'rejected'),
                              child: Text(
                                'Reject',
                                style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _updateStatus(context, doc.id, 'approved'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                'Approve',
                                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'approved':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
        break;
      case 'rejected':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      default:
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.inter(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, String docId, String status) async {
    try {
      await FirebaseFirestore.instance.collection('suggested_sites').doc(docId).update({
        'status': status,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Site marked as $status')),
        );
      }
    } catch (e) {
      debugPrint('Error updating suggested site status: $e');
    }
  }
}
