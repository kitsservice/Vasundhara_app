// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final file = File('lib/screens/gamification/my_forest_screen.dart');
  var content = file.readAsStringSync();
  
  const target1 = '''                      itemBuilder: (context, index) {
                        return _buildTreeCard(trees[index]);
                      },''';
  const replacement1 = '''                      itemBuilder: (context, index) {
                        return _buildTreeCard(context, trees[index]);
                      },''';
                      
  const target2 = 'Widget _buildTreeCard(PlantedTree tree) {';
  const replacement2 = 'Widget _buildTreeCard(BuildContext context, PlantedTree tree) {';
  
  content = content.replaceFirst(target1, replacement1);
  content = content.replaceFirst(target2, replacement2);
  
  file.writeAsStringSync(content);
  print('Fixed my_forest_screen context issue');
}
