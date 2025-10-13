import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({Key? key}) : super(key: key);

  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  html.File? _selectedFile;
  String? _previewUrl;
  bool _isUploading = false;
  String? _uploadedUrl;

  // 👇 Paste your deployed Google Apps Script Web App URL here
  final String scriptUrl =
      "https://script.google.com/macros/s/AKfycbwjfY2m8G5C1gyRE8WYvLSbbllJkPT5RyfwsqhY9MmPFXJZMOHRm95yYekRt-H8Vkw25w/exec";

  void pickImage() {
    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();
    uploadInput.onChange.listen((e) {
      final file = uploadInput.files!.first;
      final reader = html.FileReader();

      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((event) {
        setState(() {
          _selectedFile = file;
          _previewUrl = reader.result as String?;
          _uploadedUrl = null; // reset old uploaded link
        });
      });
    });
  }

  Future<void> uploadImage() async {
    if (_selectedFile == null) return;

    setState(() => _isUploading = true);

    final reader = html.FileReader();
    reader.readAsDataUrl(_selectedFile!);
    await reader.onLoadEnd.first;

    final base64Image = reader.result.toString().split(',').last;

    final response = await http.post(
      Uri.parse(scriptUrl),
      body: {'file': base64Image, 'filename': _selectedFile!.name},
    );

    setState(() => _isUploading = false);

    if (response.statusCode == 200 && !response.body.contains("Error")) {
      setState(() {
        _uploadedUrl = response.body.trim();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Image uploaded successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Upload failed: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Image to Drive")),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Preview selected image
                if (_previewUrl != null)
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      image: DecorationImage(
                        image: NetworkImage(_previewUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Pick image button
                ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: const Icon(Icons.photo),
                  label: const Text("Choose Image"),
                ),

                const SizedBox(height: 16),

                // Upload button
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : uploadImage,
                  icon: const Icon(Icons.cloud_upload),
                  label: Text(
                    _isUploading ? "Uploading..." : "Upload to Drive",
                  ),
                ),

                const SizedBox(height: 24),

                // Show uploaded link or image
                if (_uploadedUrl != null) ...[
                  const Text("Uploaded Image:", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Image.network(_uploadedUrl!, width: 200, height: 200),
                  TextButton(
                    onPressed: () => html.window.open(_uploadedUrl!, "_blank"),
                    child: const Text("View in Google Drive"),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
