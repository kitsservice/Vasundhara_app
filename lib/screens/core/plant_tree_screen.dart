import 'package:flutter/material.dart';
import '../../providers/settings_provider.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/tree_form_widget.dart';

class PlantTreeScreen extends StatelessWidget {
  const PlantTreeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isMarathi = context.watch<SettingsProvider>().isMarathi;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isMarathi ? 'झाड लावा' : 'Plant a Tree'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: const TreeFormWidget(),
    );
  }
}
