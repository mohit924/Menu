// import 'dart:typed_data';
// import 'dart:html' as html;
// import 'package:flutter/material.dart';

// class DriveImageHelper {
//   // Your Google Apps Script URL for fetching images by itemId
//   final String _scriptUrl =
//       "https://script.google.com/macros/s/AKfycbxBZ1Ye-mOyf-7qIcsPsSOK_V0f3z4ZR8avF_9aCefN3c1rMplUBJonIsPrgRdzUqvQ/exec";

//   /// Returns image bytes from Drive for the given itemId
//   Future<Uint8List?> getImageBytes(String itemId) async {
//     try {
//       final response = await html.HttpRequest.request(
//         '$_scriptUrl?itemId=$itemId',
//         method: 'GET',
//         responseType: 'arraybuffer', // important to get raw bytes
//       );

//       if (response.status == 200 && response.response != null) {
//         return Uint8List.view(response.response as ByteBuffer);
//       } else {
//         throw Exception('Failed to fetch image for itemID: $itemId');
//       }
//     } catch (e) {
//       print('Error fetching image: $e');
//       return null;
//     }
//   }
// }
