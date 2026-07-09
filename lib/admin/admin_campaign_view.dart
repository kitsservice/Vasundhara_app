import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class AdminCampaignView extends StatefulWidget {
  const AdminCampaignView({super.key});

  @override
  State<AdminCampaignView> createState() => _AdminCampaignViewState();
}

class _AdminCampaignViewState extends State<AdminCampaignView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Campaign Hub',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Active Campaigns', icon: Icon(Icons.park)),
            Tab(text: 'Events & Programs', icon: Icon(Icons.event)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCampaignsTab(),
          _buildEventsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _showCreateCampaignSheet(context);
          } else {
            _showCreateEventSheet(context);
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          _tabController.index == 0 ? 'New Campaign' : 'New Event',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  // ==========================================
  // CAMPAIGNS TAB
  // ==========================================

  Widget _buildCampaignsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('campaigns')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No active campaigns.\nTap "New Campaign" to start one!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final title = data['title'] ?? 'Untitled Campaign';
            final target = data['target'] ?? 0;
            final progress = data['progress'] ?? 0;
            final endDate = data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : null;

            final double percent = target > 0 ? (progress / target) : 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF0D9488)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white70),
                        onPressed: () {
                          FirebaseFirestore.instance.collection('campaigns').doc(doc.id).delete();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (endDate != null)
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Ends ${DateFormat('MMM dd, yyyy').format(endDate)}',
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$progress planted',
                        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Target: $target',
                        style: GoogleFonts.inter(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percent.clamp(0.0, 1.0),
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateCampaignSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 24, right: 24, top: 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('New Campaign', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Campaign Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: targetCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Tree Target (e.g. 50000)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(selectedDate == null ? 'Select End Date' : DateFormat('MMM dd, yyyy').format(selectedDate!)),
                    trailing: const Icon(Icons.calendar_month),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (picked != null) {
                        setSheetState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleCtrl.text.isEmpty || targetCtrl.text.isEmpty || selectedDate == null) return;
                        
                        await FirebaseFirestore.instance.collection('campaigns').add({
                          'title': titleCtrl.text.trim(),
                          'target': int.tryParse(targetCtrl.text.trim()) ?? 0,
                          'progress': 0,
                          'endDate': Timestamp.fromDate(selectedDate!),
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Launch Campaign', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // EVENTS TAB
  // ==========================================

  Widget _buildEventsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .where('type', isEqualTo: 'organized_program')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No upcoming events.\nTap "New Event" to create one!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final title = data['title'] ?? 'Event';
            final message = data['message'] ?? '';
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.event, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            FirebaseFirestore.instance.collection('announcements').doc(doc.id).delete();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      style: GoogleFonts.inter(color: AppColors.textSecondary, height: 1.5),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateEventSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24, right: 24, top: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Event', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(labelText: 'Event Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dateCtrl,
                      decoration: InputDecoration(labelText: 'Date & Time', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: locCtrl,
                      decoration: InputDecoration(labelText: 'Location', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.isEmpty || dateCtrl.text.isEmpty || locCtrl.text.isEmpty) return;
                    
                    final message = 'Date: ${dateCtrl.text.trim()}\nLocation: ${locCtrl.text.trim()}\n\n${descCtrl.text.trim()}';

                    await FirebaseFirestore.instance.collection('announcements').add({
                      'title': 'New Program: ${titleCtrl.text.trim()}',
                      'message': message,
                      'type': 'organized_program',
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Event created & Users notified!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Post Event', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
