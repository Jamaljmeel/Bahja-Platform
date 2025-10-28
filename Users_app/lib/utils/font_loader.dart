import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class CustomFontLoader {
  static Future<ByteData> loadNetworkFont(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return ByteData.view(response.bodyBytes.buffer);
    }
    throw Exception('Failed to load font from $url');
  }

  static Future<void> initializeFonts() async {
    try {
      await loadFont(
        'ElMessiri',
        'https://fonts.googleapis.com/css2?family=El+Messiri&display=swap',
      );
    } catch (e) {
      print('Error loading font: $e');
      // يمكنك استخدام خط بديل هنا إذا فشل التحميل
    }
  }

  static Future<void> loadFont(String fontName, String url) async {
    final fontLoader = FontLoader(fontName);
    fontLoader.addFont(loadNetworkFont(url));
    await fontLoader.load();
  }
}