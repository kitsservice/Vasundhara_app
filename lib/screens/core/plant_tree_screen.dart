import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../theme/app_colors.dart';
import '../../widgets/tree_form_widget.dart';

class PlantTreeScreen extends StatelessWidget {
  const PlantTreeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('ui_key_52'.tr()),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: const TreeFormWidget(),
    );
  }
}
