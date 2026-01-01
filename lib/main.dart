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

  // Parse URL segments
  final uri = Uri.parse(html.window.location.href);
  final segments = uri.pathSegments;

  String? hotelID;
  String? tableID;

  // Only parse if URL has at least 1 segment
  if (segments.isNotEmpty) {
    final combined = segments.last;

    // Safe substring: prevent RangeError
    hotelID = combined.length >= 4 ? combined.substring(0, 4) : null;
    tableID = combined.length > 4 ? combined.substring(4) : null;
  }

  // Load saved hotelID from SharedPreferences
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
      // URL contains hotelID + tableID → go to MenuScreen
      home = MenuScreen(hotelID: hotelID!, tableID: tableID!);
    } else if (isRootUrl) {
      // Root URL → always show LoginPage
      home = const LoginPage();
    } else if (savedHotelID != null && savedHotelID!.isNotEmpty) {
      // Returning user → AdminDashboard
      home = AdminDashboardPage();
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
