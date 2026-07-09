import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../services/cloudinary_service.dart';

class UserTreesListScreen extends StatefulWidget {
  const UserTreesListScreen({super.key});

  @override
  State<UserTreesListScreen> createState() => _UserTreesListScreenState();
}

class _UserTreesListScreenState extends State<UserTreesListScreen> {
  final Map<String, bool> _uploadingStates = {};

  Future<void> _uploadGrowthPhoto(String treeId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _uploadingStates[treeId] = true;
      });

      try {
        final File imageFile = File(pickedFile.path);
        // Upload to Cloudinary
        final String? imageUrl = await CloudinaryService.uploadImage(imageFile);

        if (imageUrl != null) {
          if (!mounted) return;
          // Update Firestore via UserProvider
          await context.read<UserProvider>()
              .uploadGrowthPhoto(treeId, imageUrl);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'ui_key_61'.tr(),
                ),
                backgroundColor: AppColors.success,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error uploading growth photo: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'ui_key_62'.tr(),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _uploadingStates[treeId] = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trees = context.select<UserProvider, List<PlantedTree>>(
      (provider) => provider.plantedTrees,
    );

    // Trees are already sorted by the provider
    final sortedTrees = trees;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'ui_key_63'.tr(),
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: sortedTrees.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.tree,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ui_key_64'.tr(),
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedTrees.length,
              itemBuilder: (context, index) {
                final tree = sortedTrees[index];
                final bool isUploading = _uploadingStates[tree.id] ?? false;
                final bool hasGrowthPhoto = tree.growthImageUrl != null &&
                    tree.growthImageUrl!.isNotEmpty;
                final DateTime nextUploadDate = DateTime(
                  tree.datePlanted.year,
                  tree.datePlanted.month + 6,
                  tree.datePlanted.day,
                );
                final bool canUpload = DateTime.now().isAfter(nextUploadDate);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            image: (tree.imageUrls != null && tree.imageUrls!.isNotEmpty) 
                                ? DecorationImage(
                                    image: NetworkImage(tree.imageUrls!.first),
                                    fit: BoxFit.cover,
                                  )
                                : tree.imageUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(tree.imageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                          ),
                          child: Stack(
                            children: [
                              if ((tree.imageUrls == null || tree.imageUrls!.isEmpty) && tree.imageUrl == null)
                                const Center(
                                  child: Icon(
                                    CupertinoIcons.tree,
                                    color: AppColors.primary,
                                    size: 32,
                                  ),
                                ),
                              if (tree.imageUrls != null && tree.imageUrls!.length > 1)
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '+${tree.imageUrls!.length - 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tree.speciesName,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${'ui_key_65'.tr()} ${DateFormat('MMM dd, yyyy').format(tree.datePlanted)}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tree.location,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 12),

                              // Action Button / Status
                              if (hasGrowthPhoto)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        CupertinoIcons.check_mark_circled_solid,
                                        color: AppColors.success,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'ui_key_66'.tr(),
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                SizedBox(
                                  width: double.infinity,
                                  height: 36,
                                  child: ElevatedButton.icon(
                                    onPressed: (!canUpload || isUploading || tree.id == null)
                                        ? null
                                        : () => _uploadGrowthPhoto(tree.id!),
                                    icon: isUploading
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Icon(
                                            canUpload ? CupertinoIcons.camera_fill : CupertinoIcons.lock_fill,
                                            size: 16,
                                            color: canUpload ? Colors.white : Colors.grey.shade400,
                                          ),
                                    label: Text(
                                      canUpload 
                                        ? 'ui_key_67'.tr() 
                                        : 'Available ${DateFormat('MMM dd, yyyy').format(nextUploadDate)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: canUpload ? Colors.white : Colors.grey.shade500,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: canUpload ? AppColors.primary : Colors.grey.shade200,
                                      disabledBackgroundColor: Colors.grey.shade200,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
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
