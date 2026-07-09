import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';

class AdminDonationsScreen extends StatelessWidget {
  const AdminDonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Donations',
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
            .collection('donations')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No donations or pledges found.'));
          }

          final docs = snapshot.data!.docs;
          
          double totalAmount = 0.0;
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'confirmed'; // Default confirmed for older records
            if (status == 'confirmed') {
              totalAmount += (data['amount'] as num?)?.toDouble() ?? 0.0;
            }
          }

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Funds/Items Raised',
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          totalAmount.toStringAsFixed(0),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Icon(CupertinoIcons.heart_fill, color: Colors.white, size: 48),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    final name = data['userName'] ?? 'Anonymous';
                    final amount = data['amount'] ?? 0;
                    final type = data['type'] ?? 'Donation'; 
                    final status = data['status'] ?? 'confirmed';
                    final isPending = status == 'pending';
                    final userId = data['userId'];

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          // Show all donor info in bottom sheet
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Donor Details', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 16),
                                    _buildDetailRow('Name', name),
                                    _buildDetailRow('Phone', data['phone'] ?? 'N/A'),
                                    _buildDetailRow('Type', type),
                                    _buildDetailRow('Quantity/Amount', amount.toString()),
                                    _buildDetailRow('Address', data['address'] ?? 'N/A'),
                                    _buildDetailRow('Reason', data['reason'] ?? 'N/A'),
                                    const SizedBox(height: 16),
                                    if (isPending)
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          onPressed: () async {
                                            Navigator.pop(context); // Close sheet
                                            await FirebaseFirestore.instance.collection('donations').doc(doc.id).update({'status': 'confirmed'});
                                            if (userId != null && userId != 'anonymous') {
                                              await FirebaseFirestore.instance.collection('users').doc(userId).collection('notifications').add({
                                                'title': 'Donation Confirmed!',
                                                'message': 'Your donation request for $type has been approved. Thank you!',
                                                'isRead': false,
                                                'createdAt': FieldValue.serverTimestamp(),
                                                'type': 'donation_approved',
                                              });
                                            }
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Donation Approved!')));
                                            }
                                          },
                                          child: const Text('Approve Donation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: const Icon(
                              CupertinoIcons.gift_fill,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                          subtitle: Text(type),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                amount.toString(),
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 16,
                                ),
                              ),
                              if (isPending)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('Pending', style: GoogleFonts.inter(fontSize: 10, color: Colors.orange.shade800, fontWeight: FontWeight.bold)),
                                ),
                              if (!isPending)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('Confirmed', style: GoogleFonts.inter(fontSize: 10, color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14)),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
