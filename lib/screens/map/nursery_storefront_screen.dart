import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';

class NurseryStorefrontScreen extends StatelessWidget {
  final Map<String, dynamic> nurseryData;
  final String nurseryId;

  const NurseryStorefrontScreen({
    super.key,
    required this.nurseryData,
    required this.nurseryId,
  });

  Future<void> _contactNursery(BuildContext context, bool isMarathi) async {
    final mobileNo = nurseryData['mobileNo']?.toString() ?? '';
    if (mobileNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ui_key_92'.tr(),
          ),
        ),
      );
      return;
    }

    final Uri url = Uri.parse('tel:$mobileNo');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ui_key_93'.tr(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMarathi = context.locale.languageCode == 'mr';
    final name = nurseryData['name_en'] ?? 'Unknown Nursery';
    final ownerName = nurseryData['ownerName'] ?? 'Unknown';
    final address = nurseryData['address'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _contactNursery(context, isMarathi),
        backgroundColor: AppColors.primary,
        icon: const Icon(CupertinoIcons.phone_fill, color: Colors.white),
        label: Text(
          'ui_key_94'.tr(),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Elegant Header
          SliverAppBar(
            expandedHeight: 220.0,
            pinned: true,
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/realistic_plant.png',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.person_alt_circle,
                              size: 16,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              ownerName,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        if (address.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                CupertinoIcons.location_solid,
                                size: 16,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  address,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Inventory Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ui_key_96'.tr(),
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (nurseryData['plants'] != null && nurseryData['plants'].toString().trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: nurseryData['plants']
                          .toString()
                          .split(',')
                          .map((plant) => plant.trim())
                          .where((plant) => plant.isNotEmpty)
                          .map((plant) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  plant,
                                  style: GoogleFonts.inter(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),)
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Inventory Grid
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('nurseries')
                .doc(nurseryId)
                .collection('inventory')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'ui_key_97'.tr(),
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                if (nurseryData['plants'] != null && nurseryData['plants'].toString().trim().isNotEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox(height: 100));
                }
                
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.cube_box,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ui_key_98'.tr(),
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ui_key_99'.tr(),
                          style:
                              GoogleFonts.inter(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return SliverPadding(
                padding:
                    const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75, // Taller cards for images
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final productName = data['name'] ?? 'Unknown';
                      final price = data['price'] ?? 0;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image Placeholder
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    CupertinoIcons.tree,
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            // Product Info
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      productName,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '₹$price',
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: docs.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
