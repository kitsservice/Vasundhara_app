import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../theme/app_colors.dart';
import '../../services/cloudinary_service.dart';

class ProfileAvatarWidget extends StatefulWidget {
  const ProfileAvatarWidget({super.key});

  @override
  State<ProfileAvatarWidget> createState() => _ProfileAvatarWidgetState();
}

class _ProfileAvatarWidgetState extends State<ProfileAvatarWidget> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isUploading = true);

      try {
        final String? url = await CloudinaryService.uploadImage(File(image.path));
        
        if (url != null) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await user.updatePhotoURL(url);
            
            // Also update Firestore to keep user data in sync across the app
            await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
              {'photoUrl': url},
              SetOptions(merge: true),
            );
          }
          
          // Force a rebuild to reflect the new photoURL
          if (mounted) {
            setState(() {});
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Setup required: $e'),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }

      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoURL = FirebaseAuth.instance.currentUser?.photoURL;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _isUploading ? null : _pickAndUploadImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            key: ValueKey(photoURL),
            radius: 50,
            backgroundColor: Colors.white24,
            backgroundImage:
                photoURL != null ? CachedNetworkImageProvider(photoURL) : null,
            child: photoURL == null
                ? const Icon(
                    CupertinoIcons.person_solid,
                    size: 50,
                    color: Colors.white,
                  )
                : null,
          ),
          if (_isUploading)
            const CircularProgressIndicator(color: Colors.white),
          if (!_isUploading)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.camera_fill,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
