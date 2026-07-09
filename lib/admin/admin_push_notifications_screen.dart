import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AdminPushNotificationsScreen extends StatefulWidget {
  const AdminPushNotificationsScreen({super.key});

  @override
  State<AdminPushNotificationsScreen> createState() => _AdminPushNotificationsScreenState();
}

class _AdminPushNotificationsScreenState extends State<AdminPushNotificationsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  String _selectedType = 'global_alert';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Push Notifications',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.campaign, color: AppColors.primary, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Global In-App Notifications\nSend an alert or event that all users will see.',
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Notification Type',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'global_alert', child: Text('General Alert')),
                    DropdownMenuItem(value: 'organized_program', child: Text('Event / Program')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedType = val;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Notification Title',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g. Mega Tree Plantation Drive!',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (_selectedType == 'organized_program') ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _dateController,
                          decoration: InputDecoration(
                            hintText: 'e.g. 24 Oct, 10 AM',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Location', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            hintText: 'e.g. Central Park',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Notification Message',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter the full details here...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendNotification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Send to All Users',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendNotification() async {
    final title = _titleController.text.trim();
    String message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both a title and message.')),
      );
      return;
    }

    if (_selectedType == 'organized_program') {
      final date = _dateController.text.trim();
      final location = _locationController.text.trim();
      if (date.isEmpty || location.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter Date and Location for events.')),
        );
        return;
      }
      message = 'Date: $date\nLocation: $location\n\n$message';
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('announcements').add({
        'title': title,
        'message': message,
        'type': _selectedType,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _titleController.clear();
        _messageController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification broadcasted successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
