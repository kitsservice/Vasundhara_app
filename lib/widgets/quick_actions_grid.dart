import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:easy_localization/easy_localization.dart';
import '../theme/app_colors.dart';
import '../screens/gamification/my_progress_screen.dart';
import '../screens/gamification/user_trees_list_screen.dart';
import '../widgets/pledge_dialog.dart';
import '../screens/core/donate_screen.dart';
import '../screens/gamification/communities_list_screen.dart';
import '../screens/map/location_picker_screen.dart';
import '../services/firestore_marker_service.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              tr('ui_key_175'),
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ).animate().fade(delay: 400.ms),
        const SizedBox(height: 20),

        // 2x2 Grid of square cards
        Row(
          children: [
            Expanded(
              child: SquareActionCard(
                icon: CupertinoIcons.location_solid,
                title: tr('ui_key_176'),
                iconColor: const Color(0xFF047857),
                iconBackgroundColor: const Color(0xFFBBEBDB),
                backgroundGradient: const [
                  Color(0xFFECFDF7),
                  Color(0xFFD1F2E6),
                ],
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LocationPickerScreen(),
                    ),
                  );

                  if (result != null && result is LatLng && context.mounted) {
                    _showSuggestSiteDialog(context, result);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SquareActionCard(
                icon: CupertinoIcons.camera_fill,
                title: tr('ui_key_177'),
                iconColor: const Color(0xFF065F46),
                iconBackgroundColor: const Color(0xFFBADCD3),
                backgroundGradient: const [
                  Color(0xFFECF5F2),
                  Color(0xFFCBE5DE),
                ],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UserTreesListScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SquareActionCard(
                icon: Icons.handshake,
                title: tr('ui_key_178'),
                iconColor: const Color(0xFF022C22),
                iconBackgroundColor: const Color(0xFFB2CFC5),
                backgroundGradient: const [
                  Color(0xFFEFF4F2),
                  Color(0xFFC5D9D2),
                ],
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const PledgeDialog(),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SquareActionCard(
                icon: Icons.bar_chart_rounded,
                title: tr('ui_key_179'),
                iconColor: const Color(0xFF4B5563),
                iconBackgroundColor: const Color(0xFFD4D8DD),
                backgroundGradient: const [
                  Color(0xFFF9FAFB),
                  Color(0xFFE2E2E9),
                ],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyProgressScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ).animate().fade(delay: 600.ms).slideY(begin: 0.1),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SquareActionCard(
                icon: CupertinoIcons.heart_solid,
                title: tr('ui_key_180'),
                iconColor: const Color(0xFFBE123C),
                iconBackgroundColor: const Color(0xFFFECDD3),
                backgroundGradient: const [
                  Color(0xFFFFF1F2),
                  Color(0xFFFEE2E2),
                ],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DonateScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SquareActionCard(
                icon: CupertinoIcons.person_3_fill,
                title: tr('ui_key_234'),
                iconColor: const Color(0xFF1D4ED8),
                iconBackgroundColor: const Color(0xFFDBEAFE),
                backgroundGradient: const [
                  Color(0xFFEFF6FF),
                  Color(0xFFBFDBFE),
                ],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CommunitiesListScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ).animate().fade(delay: 700.ms).slideY(begin: 0.1),
      ],
    );
  }

  void _showSuggestSiteDialog(BuildContext context, LatLng location) {
    final TextEditingController descController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Suggest Planting Site'),
        content: TextField(
          controller: descController,
          decoration: const InputDecoration(
            hintText: 'Enter a brief description (e.g., Empty field in park)',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (descController.text.trim().isEmpty) return;
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await FirestoreMarkerService().addSuggestedSite({
                  'latitude': location.latitude,
                  'longitude': location.longitude,
                  'description': descController.text.trim(),
                  'userId': user.uid,
                  'timestamp': DateTime.now(),
                });

                // Notify Admin
                await FirebaseFirestore.instance.collection('admin_notifications').add({
                  'title': 'New Site Suggested',
                  'message': '${user.displayName ?? 'A user'} suggested a new planting site.',
                  'type': 'site_suggested',
                  'userName': user.displayName ?? 'Unknown',
                  'isRead': false,
                  'createdAt': FieldValue.serverTimestamp(),
                });
              }
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Suggested site submitted successfully!')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class SquareActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color iconBackgroundColor;
  final List<Color> backgroundGradient;
  final VoidCallback onTap;

  const SquareActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.backgroundGradient,
    required this.onTap,
  });

  @override
  State<SquareActionCard> createState() => _SquareActionCardState();
}

class _SquareActionCardState extends State<SquareActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 110, // Slightly taller for premium feel
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.backgroundGradient.first.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.iconColor
                    .withValues(alpha: 0.08), // Colored elegant shadow
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.iconColor.withValues(alpha: 0.1),
                      widget.iconColor.withValues(alpha: 0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
