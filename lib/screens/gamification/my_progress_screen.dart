import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

import 'package:easy_localization/easy_localization.dart';
import '../../widgets/campaign/campaign_progress_section.dart';
import '../../widgets/campaign/campaign_leaderboard_preview.dart';

class MyProgressScreen extends StatefulWidget {
  const MyProgressScreen({super.key});

  @override
  State<MyProgressScreen> createState() => _MyProgressScreenState();
}

class _MyProgressScreenState extends State<MyProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;
    final isMarathi = currentLocale.languageCode == 'mr';
    final leaderboard = context.select<UserProvider, dynamic>((p) => p.leaderboard);
    final pledgeTarget = context.select<UserProvider, int>((p) => p.pledgeTarget);
    final unlockedBadges = context.select<UserProvider, List<String>>((p) => p.unlockedBadges);
    return Selector<UserProvider, List<PlantedTree>>(
      selector: (_, p) => p.plantedTrees,
      builder: (context, trees, _) {
        final totalPlanted = trees.fold(0, (sum, t) => sum + t.quantity);

        return Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(CupertinoIcons.back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Column(
              children: [
                const Text(
                  'My Progress',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your green journey in numbers.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: Colors.grey.shade200, height: 1),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBadgesSection(totalPlanted, unlockedBadges),
                  const SizedBox(height: 28),
                  
                  _buildPledgeSection(pledgeTarget, totalPlanted),
                  const SizedBox(height: 28),
                  
                  _buildImpactEquivalencies(totalPlanted),
                  const SizedBox(height: 28),
                  
                  ProgressSection(isMarathi: isMarathi),
                  const SizedBox(height: 28),

                  LeaderboardPreview(
                    isMarathi: isMarathi,
                    leaderboard: leaderboard,
                  ),
                  const SizedBox(height: 28),

                  _buildDiversityRing(trees),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgesSection(int totalPlanted, List<String> unlockedBadges) {
    final badges = [
      {'title': 'First Seed', 'isUnlocked': totalPlanted >= 1, 'icon': Icons.spa},
      {'title': 'Green Guardian', 'isUnlocked': totalPlanted >= 10, 'icon': Icons.shield},
      {'title': 'Botanist', 'isUnlocked': unlockedBadges.contains('botanist'), 'icon': Icons.local_florist},
      {'title': 'Caregiver', 'isUnlocked': unlockedBadges.contains('caregiver'), 'icon': Icons.favorite},
      {'title': 'Oxygen Hero', 'isUnlocked': totalPlanted >= 50, 'icon': Icons.air},
      {'title': 'Forest Creator', 'isUnlocked': totalPlanted >= 100, 'icon': Icons.park},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Badges & Milestones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              final isUnlocked = badge['isUnlocked'] as bool;
              return Container(
                width: 90,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isUnlocked ? const Color(0xFFE8F5E9) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isUnlocked ? const Color(0xFF4CAF50) : Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(badge['icon'] as IconData, color: isUnlocked ? const Color(0xFF4CAF50) : Colors.grey, size: 32),
                    const SizedBox(height: 8),
                    Text(badge['title'] as String, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isUnlocked ? Colors.black87 : Colors.grey)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPledgeSection(int target, int planted) {
    if (target == 0) return const SizedBox.shrink();
    final double progress = (planted / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('My Green Pledge', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.1),
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
                  const Text('Target', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                  Text('$target Trees', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: Colors.green.shade50,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$planted / $target planted',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImpactEquivalencies(int totalPlanted) {
    if (totalPlanted == 0) return const SizedBox.shrink();
    final double co2 = totalPlanted * 21.7;
    final double carsOffset = co2 / 4600.0;
    final int oxygenPeople = totalPlanted * 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Real-World Impact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_car, color: Color(0xFF00695C), size: 28),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Offsets ${carsOffset.toStringAsFixed(3)} cars driving for a year', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF004D40)))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.group, color: Color(0xFF00695C), size: 28),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Generates oxygen for ~$oxygenPeople people', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF004D40)))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildDiversityRing(List<PlantedTree> trees) {
    if (trees.isEmpty) return const SizedBox.shrink();
    
    final Map<String, int> speciesCount = {};
    for (var t in trees) {
      speciesCount[t.speciesName] = (speciesCount[t.speciesName] ?? 0) + t.quantity;
    }
    
    final sortedSpecies = speciesCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topSpecies = sortedSpecies.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tree Diversity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(value: 1.0, color: Colors.green.shade100, strokeWidth: 8),
                  ),
                  const SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(value: 0.6, color: Colors.green, strokeWidth: 8),
                  ),
                  const Icon(Icons.forest, color: Colors.green),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: topSpecies.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s.key.isEmpty ? 'Unknown' : s.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('${s.value} planted', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
