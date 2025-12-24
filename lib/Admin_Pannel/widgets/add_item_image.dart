import 'dart:html' as html;
import 'package:http/http.dart' as http;

class ImageUploaderWidgetHelper {
  final String _scriptUrl =
      "https://script.google.com/macros/s/AKfycbwh--iJXZ8YR8-JmckTlIHqhMQ5vyZNsT8S9w-BoONhOgW3VDwiQM_lR6I-e7ZRza6W/exec";

  Future<String> uploadImage(html.File file, String itemId) async {
    final reader = html.FileReader();
    reader.readAsDataUrl(file);
    await reader.onLoadEnd.first;

    final base64Image = reader.result.toString().split(',').last;

    // ✅ Filename is only itemId
    final response = await http.post(
      Uri.parse(_scriptUrl),
      body: {'file': base64Image, 'filename': itemId},
    );

    if (response.statusCode == 200 && !response.body.contains("Error")) {
      return response.body.trim(); // returned fileId or URL
    } else {
      throw Exception('Upload failed: ${response.body}');
    }
  }
}
