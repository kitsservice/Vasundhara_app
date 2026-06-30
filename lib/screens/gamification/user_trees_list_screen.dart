import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/settings_provider.dart';
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
          // Update Firestore via UserProvider
          await Provider.of<UserProvider>(context, listen: false).uploadGrowthPhoto(treeId, imageUrl);
          
          if (mounted) {
            final isMarathi = context.read<SettingsProvider>().isMarathi;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isMarathi ? 'फोटो यशस्वीरित्या अपलोड झाला!' : 'Photo uploaded successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error uploading growth photo: $e');
        if (mounted) {
          final isMarathi = context.read<SettingsProvider>().isMarathi;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isMarathi ? 'फोटो अपलोड करण्यात त्रुटी.' : 'Error uploading photo.'),
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
    final isMarathi = context.watch<SettingsProvider>().isMarathi;
    final userProvider = context.watch<UserProvider>();
    final trees = userProvider.plantedTrees;

    // Sort trees: newest planted first
    final sortedTrees = List<PlantedTree>.from(trees)
      ..sort((a, b) => b.datePlanted.compareTo(a.datePlanted));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isMarathi ? 'माझी झाडे' : 'My Planted Trees',
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
                    isMarathi ? 'अद्याप कोणतीही झाडे लावली नाहीत' : 'No trees planted yet',
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
                final bool hasGrowthPhoto = tree.growthImageUrl != null && tree.growthImageUrl!.isNotEmpty;

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
                            image: tree.imageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(tree.imageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: tree.imageUrl == null
                              ? const Icon(CupertinoIcons.tree, color: AppColors.primary, size: 32)
                              : null,
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
                                '${isMarathi ? 'लावले:' : 'Planted:'} ${DateFormat('MMM dd, yyyy').format(tree.datePlanted)}',
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
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(CupertinoIcons.check_mark_circled_solid, color: AppColors.success, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        isMarathi ? 'वाढीचा फोटो जोडला' : 'Growth Photo Added',
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
                                    onPressed: isUploading || tree.id == null ? null : () => _uploadGrowthPhoto(tree.id!),
                                    icon: isUploading
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          )
                                        : const Icon(CupertinoIcons.camera_fill, size: 16, color: Colors.white),
                                    label: Text(
                                      isMarathi ? 'वाढीचा फोटो अपलोड करा' : 'Upload Growth Photo',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
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
