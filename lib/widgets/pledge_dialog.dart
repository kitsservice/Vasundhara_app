import 'package:flutter/material.dart';
import '../providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class PledgeDialog extends StatefulWidget {
  const PledgeDialog({
    super.key,
  });

  @override
  State<PledgeDialog> createState() => _PledgeDialogState();
}

class _PledgeDialogState extends State<PledgeDialog> {
  bool get isMarathi => context.watch<SettingsProvider>().isMarathi;
  int _targetTrees = 10;
  bool _isSaving = false;

  void _savePledge() async {
    setState(() => _isSaving = true);
    // Simulate network delay for saving to Firebase
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isMarathi
              ? 'शपथ घेतली! तुमचे लक्ष्य $_targetTrees झाडे आहे.'
              : 'Pledge taken! Your goal is $_targetTrees trees.',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.handshake, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              isMarathi ? 'माझी हरित शपथ' : 'My Green Pledge',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isMarathi
                  ? 'या वर्षी तुम्ही किती झाडे लावण्याची शपथ घेता?'
                  : 'How many trees do you pledge to plant this year?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _targetTrees > 1
                      ? () => setState(() => _targetTrees--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppColors.primary,
                  iconSize: 32,
                ),
                Container(
                  width: 80,
                  alignment: Alignment.center,
                  child: Text(
                    '$_targetTrees',
                    style: GoogleFonts.outfit(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _targetTrees++),
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.primary,
                  iconSize: 32,
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _savePledge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isMarathi ? 'शपथ घ्या' : 'Confirm Pledge',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                isMarathi ? 'रद्द करा' : 'Cancel',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
