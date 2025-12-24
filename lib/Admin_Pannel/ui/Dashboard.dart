import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_scan_web/Admin_Pannel/widgets/common_header.dart';
import 'package:menu_scan_web/Custom/App_colors.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> categories = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchCategoriesAndItems();
  }

  Future<void> fetchCategoriesAndItems() async {
    try {
      // Fetch categories for hotel OPSY
      final categorySnapshot = await _firestore
          .collection('AddCategory')
          .where('hotelID', isEqualTo: 'OPSY')
          .get();

      List<Map<String, dynamic>> tempCategories = [];

      for (var catDoc in categorySnapshot.docs) {
        final catData = catDoc.data();
        final catID = catData['categoryID'];

        // Fetch items for this category
        final itemSnapshot = await _firestore
            .collection('AddItem')
            .where('hotelID', isEqualTo: 'OPSY')
            .where('categoryID', isEqualTo: catID)
            .get();

        List<Map<String, dynamic>> items = itemSnapshot.docs.map((itemDoc) {
          final itemData = itemDoc.data();
          return {
            "docId": itemDoc.id,
            "itemID": itemData['itemID'], // ✅ Add this
            "name": itemData['itemName'] ?? '',
            "price": "₹${itemData['price'] ?? ''}",
            "available": (itemData['available'] ?? 'Yes') == 'Yes',
            "imageUrl": itemData['imageUrl'], // ✅ Optional: for future use
          };
        }).toList();

        tempCategories.add({
          "name": catData['categoryName'] ?? '',
          "icon": Icons.fastfood,
          "expanded": true,
          "items": items,
        });
      }

      setState(() {
        categories = tempCategories;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  List<Map<String, dynamic>> get filteredCategories {
    if (_searchQuery.isEmpty) return categories;

    return categories
        .map((category) {
          final filteredItems = (category["items"] as List)
              .where(
                (item) => item["name"].toString().toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();
          return {...category, "items": filteredItems};
        })
        .where((cat) => (cat["items"] as List).isNotEmpty)
        .toList();
  }

  Future<void> toggleAvailability(String docId, bool newValue) async {
    try {
      await _firestore.collection('AddItem').doc(docId).update({
        'available': newValue ? 'Yes' : 'No',
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Column(
        children: [
          const SizedBox(height: 25),
          CommonHeader(
            showSearchBar: true,
            onSearchChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: filteredCategories.map((category) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              category["expanded"] =
                                  !(category["expanded"] as bool);
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    category["icon"],
                                    color: AppColors.OrangeColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    category["name"],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.LightGreyColor,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                category["expanded"]
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: AppColors.OrangeColor,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (category["expanded"] as bool)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final cardCount = isMobile
                                  ? 1
                                  : (constraints.maxWidth ~/ 320);
                              final spacing = 16.0;
                              final cardWidth = isMobile
                                  ? constraints.maxWidth
                                  : (constraints.maxWidth -
                                            (cardCount - 1) * spacing) /
                                        cardCount;

                              return Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                children: (category["items"] as List)
                                    .map<Widget>(
                                      (item) => SizedBox(
                                        width: cardWidth,
                                        child: ItemCard(
                                          item: item,
                                          isMobile: true,
                                          onToggle: (val) {
                                            setState(() {
                                              item["available"] = val;
                                            });
                                            toggleAvailability(
                                              item["docId"],
                                              val,
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isMobile;
  final Function(bool) onToggle;

  const ItemCard({
    Key? key,
    required this.item,
    required this.isMobile,
    required this.onToggle,
  }) : super(key: key);

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  Uint8List? imageBytes;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final itemId = widget.item["itemID"];

    if (itemId == null) {
      setState(() => isLoading = false);
      return;
    }

    final deployUrl =
        "https://script.google.com/macros/s/AKfycbwh--iJXZ8YR8-JmckTlIHqhMQ5vyZNsT8S9w-BoONhOgW3VDwiQM_lR6I-e7ZRza6W/exec?itemId=$itemId";

    try {
      final response = await http.get(Uri.parse(deployUrl));

      if (response.statusCode == 200 &&
          response.body != "NOT_FOUND" &&
          !response.body.startsWith("Error")) {
        final decoded = base64Decode(response.body);
        setState(() {
          imageBytes = decoded;
          isLoading = false;
        });
      } else {
        setState(() {
          imageBytes = null;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        imageBytes = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// IMAGE / SHIMMER
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 100,
              height: 100,
              child: isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey.shade800,
                      highlightColor: Colors.grey.shade600,
                      child: Container(color: Colors.grey),
                    )
                  : imageBytes != null
                  ? Image.memory(imageBytes!, fit: BoxFit.cover)
                  : Image.asset("assets/noodles.png", fit: BoxFit.cover),
            ),
          ),

          const SizedBox(width: 12),

          /// DETAILS
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item["name"],
                        style: const TextStyle(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${widget.item["itemID"] ?? "null"}',
                        style: const TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.item["price"] ?? "0",
                        style: const TextStyle(
                          color: AppColors.OrangeColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: widget.item["available"],
                  activeColor: AppColors.OrangeColor,
                  onChanged: widget.onToggle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
