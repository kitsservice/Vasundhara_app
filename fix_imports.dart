import 'dart:io';

void main() async {
  final dir = Directory('lib');
  final entities = await dir.list(recursive: true).toList();

  for (var entity in entities) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = await entity.readAsString();

      // Fix imports missing the new folder structure
      content = content.replaceAll(
        "import '../screens/plant_tree_screen.dart'",
        "import '../screens/core/plant_tree_screen.dart'",
      );
      content = content.replaceAll(
        "import '../screens/profile_screen.dart'",
        "import '../screens/core/profile_screen.dart'",
      );
      content = content.replaceAll(
        "import '../screens/certificates_screen.dart'",
        "import '../screens/gamification/certificates_screen.dart'",
      );
      content = content.replaceAll(
        "import '../screens/location_picker_screen.dart'",
        "import '../screens/map/location_picker_screen.dart'",
      );
      content = content.replaceAll(
        "import '../screens/nursery_screen.dart'",
        "import '../screens/map/nursery_screen.dart'",
      );
      content = content.replaceAll(
        "import '../screens/campaign_hub_screen.dart'",
        "import '../screens/core/campaign_hub_screen.dart'",
      );
      content = content.replaceAll(
        "import '../screens/leaderboard_screen.dart'",
        "import '../screens/gamification/leaderboard_screen.dart'",
      );
      content = content.replaceAll(
        "import '../screens/auth_wrapper.dart'",
        "import '../screens/auth/auth_wrapper.dart'",
      );
      content = content.replaceAll(
        "import '../screens/splash_screen.dart'",
        "import '../screens/auth/splash_screen.dart'",
      );
      content = content.replaceAll(
        "import '../screens/onboarding_screen.dart'",
        "import '../screens/auth/onboarding_screen.dart'",
      );
      content = content.replaceAll(
        "import '../screens/login_screen.dart'",
        "import '../screens/auth/login_screen.dart'",
      );
      content = content.replaceAll(
        "import '../screens/signup_screen.dart'",
        "import '../screens/auth/signup_screen.dart'",
      );

      // Cross-domain fixes in screens folder
      content = content.replaceAll(
        "import 'main_navigation.dart'",
        "import '../core/main_navigation.dart'",
      );
      content = content.replaceAll(
        "import 'leaderboard_screen.dart'",
        "import '../gamification/leaderboard_screen.dart'",
      );
      content = content.replaceAll(
        "import 'map_screen.dart'",
        "import '../map/map_screen.dart'",
      );
      content = content.replaceAll(
        "import 'my_forest_screen.dart'",
        "import '../gamification/my_forest_screen.dart'",
      );
      content = content.replaceAll(
        "import 'nursery_screen.dart'",
        "import '../map/nursery_screen.dart'",
      );
      content = content.replaceAll(
        "import 'privacy_policy_screen.dart'",
        "import '../settings/privacy_policy_screen.dart'",
      );
      content = content.replaceAll(
        "import 'help_support_screen.dart'",
        "import '../settings/help_support_screen.dart'",
      );
      content = content.replaceAll(
        "import 'certificates_list_screen.dart'",
        "import '../gamification/certificates_list_screen.dart'",
      );

      if (content != (await entity.readAsString())) {
        await entity.writeAsString(content);
        // ignore: avoid_print
        print('Updated cross-domain: ${entity.path}');
      }
    }
  }
}
