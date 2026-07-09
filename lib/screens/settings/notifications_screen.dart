import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This watches the real notifications fetched from Firebase Firestore
    final notifications = context.watch<UserProvider>().notifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.bell_slash, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No new notifications',
                    style: GoogleFonts.inter(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                
                // Parse Live Data
                final title = notif['title'] ?? 'Notification';
                final message = notif['message'] ?? '';
                final type = notif['type'] ?? 'general';
                
                final Timestamp? timestamp = notif['createdAt'];
                final timeStr = timestamp != null
                    ? timeago.format(timestamp.toDate())
                    : 'Just now';

                // Determine styling based on real backend type
                IconData icon = CupertinoIcons.bell;
                Color iconColor = Colors.blue;
                Color bgColor = Colors.blue.shade50;

                if (type == '6_month_update') {
                  icon = CupertinoIcons.camera_viewfinder;
                  iconColor = Colors.orange;
                  bgColor = Colors.orange.shade50;
                } else if (type == 'growth') {
                  icon = CupertinoIcons.leaf_arrow_circlepath;
                  iconColor = Colors.green;
                  bgColor = Colors.green.shade50;
                } else if (type == 'leaderboard') {
                  icon = CupertinoIcons.rosette;
                  iconColor = Colors.purple;
                  bgColor = Colors.purple.shade50;
                }

                return _buildNotificationCard(
                  icon: icon,
                  iconColor: iconColor,
                  backgroundColor: bgColor,
                  title: title,
                  message: message,
                  time: timeStr,
                  isRead: notif['isRead'] ?? false,
                  onTap: () {
                    // Mark as read in Firestore when tapped
                    if (notif['id'] != null && !(notif['isRead'] ?? false)) {
                      context.read<UserProvider>().markNotificationAsRead(notif['id']);
                    }
                  },
                );
              },
            ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String message,
    required String time,
    required bool isRead,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : Colors.blue.shade50.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isRead ? Colors.grey.shade200 : Colors.blue.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.inter(
                            fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isRead ? Colors.grey.shade500 : Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
