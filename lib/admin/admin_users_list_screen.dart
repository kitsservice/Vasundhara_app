import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';

class AdminUsersListScreen extends StatefulWidget {
  const AdminUsersListScreen({super.key});

  @override
  State<AdminUsersListScreen> createState() => _AdminUsersListScreenState();
}

class _AdminUsersListScreenState extends State<AdminUsersListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Active Users',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users by name or email...',
                prefixIcon: const Icon(
                  CupertinoIcons.search,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('createdAt', descending: true)
                  .limit(100)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('An error occurred loading users.'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No Users Found',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs.where((doc) {
                  if (_searchQuery.isEmpty) return true;
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery) ||
                      email.contains(_searchQuery);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(
                    child: Text('No users found matching your search.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'Unknown User';
                    final email = data['email'] ?? 'No email';
                    final role = data['role'] ?? 'user';
                    final isBanned = data['isBanned'] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isBanned ? Colors.grey.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: isBanned 
                              ? Colors.grey.withValues(alpha: 0.1) 
                              : AppColors.primary.withValues(alpha: 0.1),
                          child: Icon(
                            CupertinoIcons.person_fill,
                            color: isBanned ? Colors.grey : AppColors.primary,
                          ),
                        ),
                        title: Text(
                          name,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration: isBanned ? TextDecoration.lineThrough : null,
                            color: isBanned ? Colors.grey : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(email, style: GoogleFonts.inter(fontSize: 13, color: isBanned ? Colors.grey : null)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: role == 'admin'
                                        ? Colors.purple.shade100
                                        : Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    role.toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: role == 'admin'
                                          ? Colors.purple.shade700
                                          : Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                                if (isBanned) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'BANNED',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
