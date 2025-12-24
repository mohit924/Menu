import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Reusable Image Upload Widget
class ImageUploaderWidget extends StatefulWidget {
  final String itemId; // Pass the ID for filename
  final void Function(String uploadedUrl) onUploaded; // Callback

  const ImageUploaderWidget({
    Key? key,
    required this.itemId,
    required this.onUploaded,
  }) : super(key: key);

  @override
  State<ImageUploaderWidget> createState() => _ImageUploaderWidgetState();
}

class _ImageUploaderWidgetState extends State<ImageUploaderWidget> {
  html.File? _selectedFile;
  String? _previewUrl;
  bool _isUploading = false;

  // ✅ Put your Apps Script URL here once
  final String _scriptUrl =
      "https://script.google.com/macros/s/AKfycbxlk1ztjNDP2loEM_imUQTv_GAnnWsnqOKJeConCSXf-PQLC79x_64OyYt4ncq5cpBr/exec";

  /// Pick image from file picker
  Future<void> _pickImage() async {
    final completer = Completer<html.File?>();
    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      if (uploadInput.files != null && uploadInput.files!.isNotEmpty) {
        completer.complete(uploadInput.files!.first);
      } else {
        completer.complete(null);
      }
    });

    final file = await completer.future;
    if (file == null) return;

    final reader = html.FileReader();
    reader.readAsDataUrl(file);
    await reader.onLoadEnd.first;

    setState(() {
      _selectedFile = file;
      _previewUrl = reader.result as String?;
    });
  }

  /// Upload image to Google Drive
  Future<void> _uploadImage() async {
    if (_selectedFile == null) return;

    setState(() => _isUploading = true);

    final reader = html.FileReader();
    reader.readAsDataUrl(_selectedFile!);
    await reader.onLoadEnd.first;

    final base64Image = reader.result.toString().split(',').last;

    final response = await http.post(
      Uri.parse(_scriptUrl),
      body: {
        'file': base64Image,
        'filename': '${widget.itemId}-${_selectedFile!.name}',
      },
    );

    setState(() => _isUploading = false);

    if (response.statusCode == 200 && !response.body.contains("Error")) {
      final uploadedUrl = response.body.trim();
      widget.onUploaded(uploadedUrl);
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
    return Column(
      children: [
        // Preview
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

        // Pick Image
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.photo),
          label: const Text("Choose Image"),
        ),
        const SizedBox(height: 16),

        // Upload
        ElevatedButton.icon(
          onPressed: _isUploading ? null : _uploadImage,
          icon: const Icon(Icons.cloud_upload),
          label: Text(_isUploading ? "Uploading..." : "Upload"),
        ),
      ],
    );
  }
}
