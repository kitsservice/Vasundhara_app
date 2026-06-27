import 'package:flutter/material.dart';
import '../providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_colors.dart';

class NurseryScreen extends StatefulWidget {
  const NurseryScreen({super.key});

  @override
  State<NurseryScreen> createState() => _NurseryScreenState();
}

class _NurseryScreenState extends State<NurseryScreen> {
  final List<Map<String, dynamic>> nurseries = [
    {
      'name_en': 'Green Leaf Nursery',
      'name_mr': 'ग्रीन लीफ रोपवाटिका',
      'distance': '2.4 km',
      'rating': 4.8,
      'plants': 'Mango, Neem, Banyan, Rose...',
    },
    {
      'name_en': 'Vasundhara Plants Hub',
      'name_mr': 'वसुंधरा प्लांट्स हब',
      'distance': '3.8 km',
      'rating': 4.9,
      'plants': 'Tulsi, Aloe Vera, Guava...',
    },
    {
      'name_en': 'Eco Roots Nursery',
      'name_mr': 'इको रूट्स रोपवाटिका',
      'distance': '5.1 km',
      'rating': 4.5,
      'plants': 'Bamboo, Peepal, Hibiscus...',
    },
    {
      'name_en': 'Savitribai Phule Garden Center',
      'name_mr': 'सावित्रीबाई फुले गार्डन सेंटर',
      'distance': '7.0 km',
      'rating': 4.7,
      'plants': 'Jackfruit, Papaya, Lemon...',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isMarathi = context.watch<SettingsProvider>().isMarathi;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isMarathi ? 'जवळपासच्या रोपवाटिका' : 'Nearby Nurseries'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                context.read<SettingsProvider>().toggleLanguage();
              });
            },
            child: Text(
              isMarathi ? 'EN' : 'MR',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: nurseries.length,
        itemBuilder: (context, index) {
          final nursery = nurseries[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Placeholder
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5E7EB),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                    image: DecorationImage(
                      image: AssetImage('assets/images/realistic_plant.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            nursery['rating'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isMarathi
                                  ? nursery['name_mr']
                                  : nursery['name_en'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.location_solid,
                                size: 14,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                nursery['distance'],
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${isMarathi ? 'उपलब्ध झाडे:' : 'Available Plants:'} ${nursery['plants']}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isMarathi
                                      ? 'खरेदी वैशिष्ट्य लवकरच येत आहे!'
                                      : 'Buying feature coming soon!',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.shopping_bag_outlined,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            isMarathi ? 'रोपे खरेदी करा' : 'Buy Plants',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
