import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminVerifyTreesScreen extends StatelessWidget {
  const AdminVerifyTreesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Verify Trees',
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
            .collection('planted_trees')
            .orderBy('plantedAt', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No trees available for verification.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              final status = data['status'] as String? ?? 'Pending';
              final speciesName = data['speciesName'] ?? 'Unknown Species';
              final userName = data['userName'] ?? 'Unknown User';
              final userId = data['userId'] as String?;
              final imageUrl = data['imageUrl'] as String?;
              final growthImageUrl = data['growthImageUrl'] as String?;
              final quantity = data['quantity'] ?? 1;
              final double? lat = (data['latitude'] as num?)?.toDouble();
              final double? lng = (data['longitude'] as num?)?.toDouble();
              final String locationName = data['location'] as String? ?? 'Unknown Location';

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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  speciesName,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'By $userName • Qty: $quantity',
                                  style: GoogleFonts.inter(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () async {
                                    if (lat != null && lng != null) {
                                      final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url, mode: LaunchMode.externalApplication);
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Could not open map.')),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(CupertinoIcons.location_solid, size: 14, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          locationName,
                                          style: GoogleFonts.inter(
                                            color: AppColors.primary,
                                            fontSize: 12,
                                            decoration: TextDecoration.underline,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildStatusBadge(status),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.ellipsis_circle),
                            onPressed: () {
                              _showUpdateStatusBottomSheet(context, doc.id, userId, status);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Photos Section
                      Row(
                        children: [
                          Expanded(
                            child: _buildPhotoColumn(context, 'Planting Photo', imageUrl),
                          ),
                          if (growthImageUrl != null && growthImageUrl.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildPhotoColumn(context, '6-Month Photo', growthImageUrl),
                            ),
                          ],
                        ],
                      ),
                      if (status == 'Pending') ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _updateTreeStatus(context, doc.id, userId, 'Verified'),
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Approve'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _updateTreeStatus(context, doc.id, userId, 'Rejected'),
                                icon: const Icon(Icons.cancel),
                                label: const Text('Reject'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildPhotoColumn(BuildContext context, String title, String? url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            if (url != null && url.isNotEmpty) {
              _showFullScreenImage(context, url);
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: url != null && url.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: url,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade200,
                      width: double.infinity,
                      height: 160,
                      child: const Center(child: CupertinoActivityIndicator()),
                    ),
                    errorWidget: (context, url, error) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 120,
      color: Colors.grey.shade200,
      child: const Icon(CupertinoIcons.tree, color: Colors.grey),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'survived':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        break;
      case 'healthy':
      case 'verified':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
        break;
      case 'dead':
      case 'rejected':
      case 'banned':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      case 'needs water':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF4B5563);
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

  void _showUpdateStatusBottomSheet(BuildContext context, String docId, String? userId, String currentStatus) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Tree Status',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildStatusOption(context, docId, userId, 'Survived (6-Month verified)', 'survived', currentStatus),
              _buildStatusOption(context, docId, userId, 'Verified / Healthy', 'healthy', currentStatus),
              _buildStatusOption(context, docId, userId, 'Needs Water', 'needs water', currentStatus),
              _buildStatusOption(context, docId, userId, 'Dead', 'dead', currentStatus),
              const Divider(height: 32),
              _buildStatusOption(
                context, 
                docId, 
                userId, 
                'Reject & Ban User', 
                'banned', 
                currentStatus,
                isDestructive: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusOption(BuildContext context, String docId, String? userId, String label, String value, String currentStatus, {bool isDestructive = false}) {
    final isSelected = currentStatus.toLowerCase() == value.toLowerCase();
    
    return ListTile(
      onTap: () async {
        Navigator.pop(context);
        try {
          await FirebaseFirestore.instance.collection('planted_trees').doc(docId).update({
            'status': value,
          });
          
          // If banning the user, update the user's document
          if (value == 'banned' && userId != null) {
            await FirebaseFirestore.instance.collection('users').doc(userId).update({
              'isBanned': true,
              'status': 'cancelled',
            });
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tree rejected and user registration cancelled/banned.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
            return; // Skip the standard snackbar
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Status updated to $label')),
            );
          }
        } catch (e) {
          debugPrint('Error updating status: $e');
        }
      },
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isDestructive ? Colors.red : null,
        ),
      ),
      trailing: isSelected ? const Icon(CupertinoIcons.checkmark_alt, color: AppColors.primary) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isSelected ? AppColors.primary.withValues(alpha: 0.1) : (isDestructive ? Colors.red.withValues(alpha: 0.05) : null),
    );
  }

  Future<void> _updateTreeStatus(BuildContext context, String docId, String? userId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('planted_trees').doc(docId).update({
        'status': newStatus,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $newStatus')),
        );
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }
}
