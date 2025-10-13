import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_scan_web/Menu/Screen/Menu_Screen.dart';
import 'dart:html' as html;
import 'package:menu_scan_web/firebase_options.dart';
import 'package:menu_scan_web/image_upload.dart';
import 'package:menu_scan_web/name.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

  // Get the id from the URL query parameter
  final uri = Uri.parse(html.window.location.href);
  final idFromQR = uri.queryParameters['id'] ?? 'unknown';

  runApp(MyApp(idFromQR: idFromQR));
}

class MyApp extends StatelessWidget {
  final String idFromQR;

  MyApp({required this.idFromQR});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Name Collector',
      theme: ThemeData(primarySwatch: Colors.blue),
      // home: NamePage(idFromQR: idFromQR),
      home: MenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
