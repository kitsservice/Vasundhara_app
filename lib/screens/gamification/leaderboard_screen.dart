import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/leaderboard_podium.dart';
import '../../widgets/leaderboard_list_item.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMarathi = context.watch<SettingsProvider>().isMarathi;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          isMarathi ? 'लीडरबोर्ड' : 'Community Leaderboard',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final leaderboard = userProvider.leaderboard;

          if (leaderboard.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.tree, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    isMarathi
                        ? 'अद्याप कुणीही झाडे लावली नाहीत'
                        : 'No planters yet. Be the first!',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Top 3 Podium
          final top3 = leaderboard.take(3).toList();
          final rest = leaderboard.skip(3).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (top3.length > 1)
                        LeaderboardPodium(user: top3[1], rank: 2, height: 120),
                      if (top3.isNotEmpty)
                        LeaderboardPodium(user: top3[0], rank: 1, height: 160),
                      if (top3.length > 2)
                        LeaderboardPodium(user: top3[2], rank: 3, height: 100),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final user = rest[index];
                      final rank = index + 4;
                      return LeaderboardListItem(user: user, rank: rank);
                    },
                    childCount: rest.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
