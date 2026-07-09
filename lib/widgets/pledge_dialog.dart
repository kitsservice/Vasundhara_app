import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/user_provider.dart';
import '../services/notification_service.dart';

class PledgeDialog extends StatefulWidget {
  const PledgeDialog({
    super.key,
  });

  @override
  State<PledgeDialog> createState() => _PledgeDialogState();
}

class _PledgeDialogState extends State<PledgeDialog> {
  int _targetTrees = 10;
  bool _isSaving = false;

  void _savePledge() async {
    setState(() => _isSaving = true);
    
    await context.read<UserProvider>().savePledge(_targetTrees);
    await NotificationService().scheduleMonthlyPledgeReminder(_targetTrees);

    if (!mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ui_key_163'.tr(namedArgs: {'targetTrees': '$_targetTrees'}),
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
              'ui_key_164'.tr(),
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ui_key_165'.tr(),
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
              child: ElevatedButton(
                onPressed: _isSaving ? null : _savePledge,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                  disabledForegroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'ui_key_166'.tr(),
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
                'ui_key_167'.tr(),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
