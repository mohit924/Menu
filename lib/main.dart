// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:menu_scan_web/Admin_Pannel/ui/Dashboard.dart';
// import 'package:menu_scan_web/Admin_Pannel/ui/login.dart';
// import 'package:menu_scan_web/Customer/Screen_Ui/Menu_screen.dart';
// // import 'dart:html' as html;
// import 'package:menu_scan_web/firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

//   // Get the id from the URL query parameter
//   // final uri = Uri.parse(html.window.location.href);
//   // final idFromQR = uri.queryParameters['id'] ?? 'unknown';

//   // runApp(MyApp(idFromQR: idFromQR));
//   runApp(MyApp(idFromQR: '2'));
// }

// class MyApp extends StatelessWidget {
//   final String idFromQR;

//   MyApp({required this.idFromQR});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Name Collector',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       // home: NamePage(idFromQR: idFromQR),
//       // home: MenuScreen(),
//       home: LoginPage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:menu_scan_web/Admin_Pannel/ui/Dashboard.dart';
import 'package:menu_scan_web/Admin_Pannel/ui/login.dart';
import 'package:menu_scan_web/Customer/Screen_Ui/Menu_screen.dart';
import 'package:menu_scan_web/firebase_options.dart';
import 'dart:html' as html;
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

  // Parse current URL
  final uri = Uri.parse(html.window.location.href);

  // Query parameters for user QR
  final hotelID = uri.queryParameters['hotelID'];
  final tableID = uri.queryParameters['tableID'];

  // Path segments to detect /admin
  final isAdmin = uri.pathSegments.contains('admin');

  // Check if admin is already logged in
  final prefs = await SharedPreferences.getInstance();
  final savedHotelID = prefs.getString('hotelID');

  runApp(
    MyApp(
      hotelID: hotelID,
      tableID: tableID,
      isAdmin: isAdmin,
      savedHotelID: savedHotelID,
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? hotelID;
  final String? tableID;
  final bool isAdmin;
  final String? savedHotelID;

  const MyApp({
    this.hotelID,
    this.tableID,
    required this.isAdmin,
    this.savedHotelID,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget home;

    if (hotelID != null && tableID != null) {
      home = MenuScreen(hotelID: hotelID!, tableID: tableID!);
    } else if (isAdmin) {
      if (savedHotelID != null && savedHotelID!.isNotEmpty) {
        home = AdminDashboardPage();
      } else {
        home = const LoginPage();
      }
    } else {
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
