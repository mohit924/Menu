import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:menu_scan_web/Admin_Pannel/ui/login.dart';
import 'package:menu_scan_web/Custom/app_loader.dart';
import 'package:menu_scan_web/Custom/app_snackbar.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:menu_scan_web/Admin_Pannel/widgets/common_header.dart';
import 'package:menu_scan_web/Custom/App_colors.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;
import 'package:shared_preferences/shared_preferences.dart';

class GenerateQr extends StatefulWidget {
  const GenerateQr({super.key});

  @override
  _GenerateQrState createState() => _GenerateQrState();
}

class _GenerateQrState extends State<GenerateQr> {
  String? hotelID;
  final CollectionReference qrCollection = FirebaseFirestore.instance
      .collection('qrcodes');
  final Map<String, GlobalKey> _qrKeys = {};
  bool _isLoading = false; // loader flag

  @override
  void initState() {
    super.initState();
    _loadHotelID();
  }

  Future<void> _loadHotelID() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHotelID = prefs.getString('hotelID');

    if (savedHotelID == null || savedHotelID.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    setState(() {
      hotelID = savedHotelID;
    });
  }

  Future<void> _generateQR() async {
    if (hotelID == null) return;

    setState(() => _isLoading = true); // show loader

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final counterDoc = FirebaseFirestore.instance
            .collection('QRCounters')
            .doc(hotelID);

        final counterSnapshot = await transaction.get(counterDoc);
        int nextId = 1;

        if (counterSnapshot.exists) {
          final lastId = counterSnapshot['lastID'] ?? 0;
          nextId = lastId + 1;
          transaction.update(counterDoc, {'lastID': nextId});
        } else {
          transaction.set(counterDoc, {'lastID': nextId});
        }

        final tableId = nextId;
        final url = "https://mohit924.github.io/Menu_Scan_Web/$hotelID$tableId";

        final newDoc = qrCollection.doc();
        transaction.set(newDoc, {
          'hotelID': hotelID,
          'id': nextId,
          'tableID': tableId,
          'url': url,
          'createdAt': FieldValue.serverTimestamp(),
        });

        debugPrint("Generated QR URL: $url");
      });
    } catch (e) {
      debugPrint("Error generating QR: $e");
      AppSnackBar.show(
        context,
        message: "Error generating QR: $e",
        type: SnackType.error,
      );
    } finally {
      setState(() => _isLoading = false); // hide loader
    }
  }

  void _shareQR(String url) {
    Share.share(url);
  }

  Future<void> _downloadQrImage(String id, int tableId) async {
    try {
      final key = _qrKeys[id];
      if (key == null) return;

      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      final fileName = 'Table_$tableId.png';

      if (kIsWeb) {
        final blob = html.Blob([pngBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(pngBytes);
        AppSnackBar.show(
          context,
          message: 'QR code downloaded: ${file.path}',
          type: SnackType.success,
        );
      }
    } catch (e) {
      debugPrint("Error downloading QR: $e");
      AppSnackBar.show(
        context,
        message: 'Error downloading QR: $e',
        type: SnackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int cardsPerRow = screenWidth >= 1200
        ? 4
        : screenWidth >= 900
        ? 3
        : screenWidth >= 600
        ? 2
        : 1;

    final cardWidth = (screenWidth - (16 * (cardsPerRow + 1))) / cardsPerRow;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 25),
              const CommonHeader(
                currentPage: "Generate Qr",
                showSearchBar: false,
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: qrCollection
                      .where('hotelID', isEqualTo: hotelID)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: AppLoaderWidget(message: "Loading QR..."),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading QR codes: ${snapshot.error}',
                          style: const TextStyle(color: AppColors.whiteColor),
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No QR codes generated yet.',
                          style: TextStyle(color: AppColors.whiteColor),
                        ),
                      );
                    }

                    docs.sort((a, b) {
                      final tableA = a['tableID'] ?? 0;
                      final tableB = b['tableID'] ?? 0;
                      return tableA.compareTo(tableB);
                    });

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: docs.map((doc) {
                            final url = doc['url'] ?? '';
                            final tableId = doc['tableID'] ?? 0;
                            final qrKey = GlobalKey();
                            _qrKeys[doc.id] = qrKey;

                            return Container(
                              width: cardWidth,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryBackground,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RepaintBoundary(
                                    key: qrKey,
                                    child: PrettyQr(
                                      data: url,
                                      size: 80,
                                      elementColor: AppColors.whiteColor,
                                      roundEdges: true,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Table ID: $tableId',
                                          style: const TextStyle(
                                            color: AppColors.whiteColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.share,
                                                color: AppColors.OrangeColor,
                                              ),
                                              onPressed: () => _shareQR(url),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.download,
                                                color: AppColors.OrangeColor,
                                              ),
                                              onPressed: () => _downloadQrImage(
                                                doc.id,
                                                tableId,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (_isLoading)
            const Positioned.fill(
              child: AppLoaderWidget(message: "Generating QR..."),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generateQR,
        backgroundColor: AppColors.OrangeColor,
        icon: const Icon(Icons.qr_code, color: AppColors.whiteColor),
        label: const Text(
          'Generate QR',
          style: TextStyle(color: AppColors.whiteColor),
        ),
      ),
    );
  }
}
