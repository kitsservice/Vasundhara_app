import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'ozllvd6a';
  static const String uploadPreset = 'Vasundhara-preset';

  /// Uploads an image file to Cloudinary and returns the secure URL
  static Future<String?> uploadImage(File imageFile) async {
    try {
      final url =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);

      if (response.statusCode == 200) {
        return jsonMap['secure_url'];
      } else {
        throw Exception(jsonMap['error']['message'] ?? 'Unknown Cloudinary Error');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
