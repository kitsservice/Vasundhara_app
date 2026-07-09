// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final mapFile = File('lib/screens/ola_map_screen.dart');
  var mapContent = mapFile.readAsStringSync();
  
  const target = '''      appBar: widget.showBackButton ? AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ) : null,
      appBar: AppBar(
        title: Text('ui_key_100'.tr()),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showNurseries ? Icons.park : Icons.storefront,
              color: AppColors.primary,
            ),
            onPressed: () {
              setState(() {
                _showNurseries = !_showNurseries;
                if (_mapReady) {
                  _channel?.invokeMethod('clearMarkers');
                  _addMarkersToMap();
                }
              });
            },
            tooltip: _showNurseries ? 'ui_key_101'.tr() : 'Show Nurseries',
          ),
        ],
      ),''';
      
  const replacement = '''      appBar: widget.showBackButton ? AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ) : AppBar(
        title: Text('ui_key_100'.tr()),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showNurseries ? Icons.park : Icons.storefront,
              color: AppColors.primary,
            ),
            onPressed: () {
              setState(() {
                _showNurseries = !_showNurseries;
                if (_mapReady) {
                  _channel?.invokeMethod('clearMarkers');
                  _addMarkersToMap();
                }
              });
            },
            tooltip: _showNurseries ? 'ui_key_101'.tr() : 'Show Nurseries',
          ),
        ],
      ),''';
      
  mapContent = mapContent.replaceFirst(target, replacement);
  mapFile.writeAsStringSync(mapContent);
  print('Fixed duplicate appBar in ola_map_screen.dart');
}
