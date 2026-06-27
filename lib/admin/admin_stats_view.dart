import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminStatsView extends StatelessWidget {
  const AdminStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overlapping Welcome Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.tree,
                      color: Color(0xFF2E7D32),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, Admin',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          'Manage and monitor all activities',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.calendar,
                          color: Color(0xFF16A34A),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM yyyy').format(DateTime.now()),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Overview Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overview',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2x2 Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildGridCard(
                        'Total Trees Planted',
                        '12,450',
                        '+ 18.6%',
                        CupertinoIcons.tree,
                        const Color(0xFF16A34A),
                        const Color(0xFFF0FDF4),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildGridCard(
                        'Trees Survived',
                        '10,230',
                        '+ 15.3%',
                        CupertinoIcons.tree,
                        const Color(0xFF3B82F6),
                        const Color(0xFFEFF6FF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildGridCard(
                        'Locations',
                        '258',
                        '+ 8.4%',
                        CupertinoIcons.location_solid,
                        const Color(0xFFF59E0B),
                        const Color(0xFFFFFBEB),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildGridCard(
                        'Active Users',
                        '1,245',
                        '+ 22.1%',
                        CupertinoIcons.person_2_fill,
                        const Color(0xFF8B5CF6),
                        const Color(0xFFF5F3FF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Quick Actions',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickAction(
                    CupertinoIcons.tree,
                    'Add Campaign',
                    const Color(0xFFE8F5E9),
                    const Color(0xFF2E7D32),
                  ),
                  _buildQuickAction(
                    CupertinoIcons.person_2_fill,
                    'Manage Users',
                    const Color(0xFFEFF6FF),
                    const Color(0xFF1D4ED8),
                  ),
                  _buildQuickAction(
                    CupertinoIcons.tree,
                    'Verify Trees',
                    const Color(0xFFFFF7ED),
                    const Color(0xFFC2410C),
                  ),
                  _buildQuickAction(
                    CupertinoIcons.chart_bar_alt_fill,
                    'Reports',
                    const Color(0xFFF5F3FF),
                    const Color(0xFF6D28D9),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Recent Activities
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activities',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildActivityRow(
                    icon: CupertinoIcons.tree,
                    iconBg: const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF2E7D32),
                    title: '100 Trees Planted',
                    subtitle: 'Green City Campaign',
                    location: 'Nagpur, Maharashtra',
                    time: '2 min ago',
                    status: 'Approved',
                    statusColor: const Color(0xFF16A34A),
                    statusBg: const Color(0xFFDCFCE7),
                  ),
                  const Divider(height: 1, indent: 70, endIndent: 20),
                  _buildActivityRow(
                    icon: CupertinoIcons.person_solid,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF1D4ED8),
                    title: 'New User Registered',
                    subtitle: 'Rahul Sharma',
                    location: 'Pune, Maharashtra',
                    time: '15 min ago',
                    status: 'Active',
                    statusColor: const Color(0xFF2563EB),
                    statusBg: const Color(0xFFDBEAFE),
                  ),
                  const Divider(height: 1, indent: 70, endIndent: 20),
                  _buildActivityRow(
                    icon: CupertinoIcons.doc_text,
                    iconBg: const Color(0xFFFFF7ED),
                    iconColor: const Color(0xFFC2410C),
                    title: 'Tree Verification Pending',
                    subtitle: '50 Trees • Eco Drive',
                    location: 'Amravati, Maharashtra',
                    time: '30 min ago',
                    status: 'Pending',
                    statusColor: const Color(0xFFD97706),
                    statusBg: const Color(0xFFFEF3C7),
                  ),
                  const Divider(height: 1, indent: 70, endIndent: 20),
                  _buildActivityRow(
                    icon: CupertinoIcons.flag,
                    iconBg: const Color(0xFFF0FDF4),
                    iconColor: const Color(0xFF16A34A),
                    title: 'Campaign Completed',
                    subtitle: 'Save Nature Campaign',
                    location: 'Aurangabad, Maharashtra',
                    time: '1 hour ago',
                    status: 'Completed',
                    statusColor: const Color(0xFF16A34A),
                    statusBg: const Color(0xFFDCFCE7),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 100), // Space for bottom nav
        ],
      ),
    );
  }

  Widget _buildGridCard(
    String title,
    String value,
    String change,
    IconData icon,
    Color mainColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bgColor.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: mainColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: mainColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: mainColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                CupertinoIcons.arrow_up,
                color: Color(0xFF16A34A),
                size: 10,
              ),
              const SizedBox(width: 2),
              Text(
                change,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'vs last month',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String location,
    required String time,
    required String status,
    required Color statusColor,
    required Color statusBg,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      location,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
