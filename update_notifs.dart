// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final file = File('lib/providers/user_provider.dart');
  var content = file.readAsStringSync();

  const personalTarget = '''      for (var doc in personalSnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        allNotifs.add(data);
      }''';

  const personalReplacement = '''      for (var doc in personalSnapshot.docs) {
        final data = doc.data();
        
        // Expiry Logic
        bool isExpired = false;
        if (data['visibleUntil'] != null) {
          final visibleUntil = (data['visibleUntil'] as dynamic).toDate();
          if (DateTime.now().isAfter(visibleUntil)) isExpired = true;
        }
        if (data['expiryDate'] != null) {
          final expiryDate = (data['expiryDate'] as dynamic).toDate();
          if (DateTime.now().isAfter(expiryDate)) isExpired = true;
        }
        
        if (isExpired) continue;

        data['id'] = doc.id;
        allNotifs.add(data);
      }''';

  const globalTarget = '''      for (var doc in globalSnapshot.docs) {
        final data = doc.data();
        final createdAt = data['createdAt'] as Timestamp?;

        if (lastCleared != null && createdAt != null) {
          if (createdAt.compareTo(lastCleared) <= 0) {
            continue;
          }
        }

        data['id'] = doc.id;
        // Global announcements are unread by default, maybe handled differently in UI
        allNotifs.add(data);
      }''';

  const globalReplacement = '''      for (var doc in globalSnapshot.docs) {
        final data = doc.data();
        final createdAt = data['createdAt'] as dynamic;

        if (lastCleared != null && createdAt != null) {
          if (createdAt.compareTo(lastCleared) <= 0) {
            continue;
          }
        }
        
        // Expiry Logic
        bool isExpired = false;
        if (data['visibleUntil'] != null) {
          final visibleUntil = (data['visibleUntil'] as dynamic).toDate();
          if (DateTime.now().isAfter(visibleUntil)) isExpired = true;
        }
        if (data['expiryDate'] != null) {
          final expiryDate = (data['expiryDate'] as dynamic).toDate();
          if (DateTime.now().isAfter(expiryDate)) isExpired = true;
        }
        
        if (isExpired) continue;

        data['id'] = doc.id;
        // Global announcements are unread by default, maybe handled differently in UI
        allNotifs.add(data);
      }''';

  content = content.replaceFirst(personalTarget, personalReplacement);
  content = content.replaceFirst(globalTarget, globalReplacement);

  file.writeAsStringSync(content);
  print('Updated user_provider.dart with expiry logic');
}
