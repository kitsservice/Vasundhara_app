// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final file = File('lib/admin/admin_dashboard_screen.dart');
  var content = file.readAsStringSync();

  // 1. Add Import
  content = content.replaceFirst(
    "import 'admin_nurseries_list_screen.dart';",
    "import 'admin_nurseries_list_screen.dart';\nimport 'admin_communities_view.dart';",
  );

  // 2. Add to _views
  content = content.replaceFirst(
    'const AdminSettingsView(), // Settings',
    'const AdminSettingsView(), // Settings\n    const AdminCommunitiesView(), // Communities',
  );

  // 3. Add to Drawer
  const drawerTarget = '''          ListTile(
            leading: const Icon(
              CupertinoIcons.settings,
              color: AppColors.textPrimary,
            ),
            title: Text(
              'Settings',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 4;
              });
            },
          ),''';

  const drawerReplacement = '''          ListTile(
            leading: const Icon(
              CupertinoIcons.settings,
              color: AppColors.textPrimary,
            ),
            title: Text(
              'Settings',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 4;
              });
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.apartment,
              color: AppColors.textPrimary,
            ),
            title: Text(
              'Communities',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 5;
              });
            },
          ),''';

  content = content.replaceFirst(drawerTarget, drawerReplacement);

  file.writeAsStringSync(content);
  print('Updated admin_dashboard_screen.dart');
}
