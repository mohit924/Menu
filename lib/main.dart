import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:menu_scan_web/Admin_Pannel/ui/Dashboard.dart';
import 'package:menu_scan_web/Admin_Pannel/ui/login.dart';
import 'package:menu_scan_web/Customer/Screen_Ui/Menu_screen.dart';
import 'package:menu_scan_web/Customer/Widgets/Language_Bttom_Sheet%20.dart';
import 'package:menu_scan_web/firebase_options.dart';
import 'dart:html' as html;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

  final uri = Uri.parse(html.window.location.href);
  final segments = uri.pathSegments;

  String? hotelID;
  String? tableID;

  if (segments.length >= 2) {
    // New URL format: /Menu_Scan_Web/$hotelID/$tableID
    hotelID = segments[segments.length - 2];
    tableID = segments.last;
  }

  // Load saved hotelID from SharedPreferences (owner)
  final prefs = await SharedPreferences.getInstance();
  final savedHotelID = prefs.getString('hotelID');

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: MyApp(
        hotelID: hotelID,
        tableID: tableID,
        savedHotelID: savedHotelID,
        isRootUrl: segments.isEmpty,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? hotelID;
  final String? tableID;
  final String? savedHotelID;
  final bool isRootUrl;

  const MyApp({
    this.hotelID,
    this.tableID,
    this.savedHotelID,
    this.isRootUrl = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget home;

    if (hotelID != null && tableID != null) {
      // CUSTOMER URL → always open MenuScreen
      home = MenuScreen(hotelID: hotelID!, tableID: tableID!);
    } else if (isRootUrl && savedHotelID != null && savedHotelID!.isNotEmpty) {
      // OWNER visiting root URL after login → AdminDashboard
      home = const AdminDashboardPage();
    } else {
      // Fallback → LoginPage
      home = const LoginPage();
    }

    return MaterialApp(
      title: 'Menu Scan',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: home,
    );
  }
}
