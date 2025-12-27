import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_scan_web/Customer/Widgets/Language_Bttom_Sheet%20.dart';
import 'package:shimmer/shimmer.dart'; // <<<< import shimmer
import 'package:menu_scan_web/Custom/App_colors.dart';
import 'package:menu_scan_web/Custom/BottomCartContainer.dart';
import 'package:menu_scan_web/Custom/Custom_Button.dart';
import 'package:menu_scan_web/Customer/Screen_Ui/cart_page.dart';
import 'package:menu_scan_web/Customer/Widgets/Menu_Bottom_Sheet.dart';
import 'package:menu_scan_web/Customer/Widgets/Menu_Search_Bar.dart';
import 'package:menu_scan_web/Customer/Widgets/show_Category_Sheet.dart';
import 'package:translator/translator.dart';

class MenuScreen extends StatefulWidget {
  final String hotelID;
  final String tableID;

  const MenuScreen({Key? key, required this.hotelID, required this.tableID})
    : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Map<String, String?> _imageUrlCache = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> categories = [];
  Map<int, Map<String, dynamic>> buttonStates = {};
  Map<String, bool> expandedCategories = {};
  Map<String, GlobalKey> categoryKeys = {};
  String _searchQuery = '';
  String? _hotelName;
  bool _hotelLoading = true;
  final translator = GoogleTranslator();

  String selectedLangCode = "en";
  String selectedLangName = "English";

  // Cache: langCode -> originalText -> translatedText
  Map<String, Map<String, String>> translatedCache = {};

  @override
  void initState() {
    super.initState();
    fetchCategoriesAndItems();
    _fetchHotelName();
  }

  Future<String> translateText(String text) async {
    if (selectedLangCode == "en" || text.isEmpty) {
      return text;
    }

    translatedCache.putIfAbsent(selectedLangCode, () => {});

    if (translatedCache[selectedLangCode]!.containsKey(text)) {
      return translatedCache[selectedLangCode]![text]!;
    }

    final result = await translator.translate(text, to: selectedLangCode);
    translatedCache[selectedLangCode]![text] = result.text;

    return result.text;
  }

  Future<void> _fetchHotelName() async {
    try {
      final snapshot = await _firestore
          .collection('AdminSignUp')
          .where('hotelID', isEqualTo: widget.hotelID)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _hotelName = snapshot.docs.first['hotelName'];
          _hotelLoading = false;
        });
      } else {
        setState(() {
          _hotelName = 'Hotel';
          _hotelLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Hotel fetch error: $e");
      setState(() {
        _hotelName = 'Hotel';
        _hotelLoading = false;
      });
    }
  }

  Future<void> _preloadImage(String path) async {
    if (path.isEmpty) {
      _imageUrlCache[path] = '__error__';
      return;
    }

    if (_imageUrlCache.containsKey(path)) return;

    // mark as loading
    _imageUrlCache[path] = null;

    try {
      final storage = FirebaseStorage.instanceFor(
        bucket: 'gs://menu-scan-web.firebasestorage.app',
      );
      final url = await storage.ref(path).getDownloadURL();

      _imageUrlCache[path] = url; // success
    } catch (e) {
      debugPrint("Image load failed: $e");
      _imageUrlCache[path] = '__error__'; // failure
    }

    if (mounted) setState(() {});
  }

  Future<void> fetchCategoriesAndItems() async {
    try {
      final categorySnapshot = await _firestore
          .collection('AddCategory')
          .where('hotelID', isEqualTo: widget.hotelID)
          .get();

      List<Map<String, dynamic>> tempCategories = [];

      for (var catDoc in categorySnapshot.docs) {
        final catData = catDoc.data();
        final catID = catData['categoryID'];

        // Translate category name
        final originalCategoryName = catData['categoryName'] ?? '';
        final translatedCategoryName = await translateText(
          originalCategoryName,
        );

        final itemSnapshot = await _firestore
            .collection('AddItem')
            .where('hotelID', isEqualTo: widget.hotelID)
            .where('categoryID', isEqualTo: catID)
            .get();

        List<Map<String, dynamic>> items = [];

        for (var itemDoc in itemSnapshot.docs) {
          final itemData = itemDoc.data();
          final id = itemData['itemID'] as int;

          buttonStates[id] = {"isCompleted": false, "count": 0};

          final imagePath = itemData['imageUrl'] ?? '';
          _preloadImage(imagePath);

          final originalName = itemData['itemName'] ?? '';
          final originalDesc = itemData['description'] ?? '';

          final translatedName = await translateText(originalName);
          final translatedDesc = await translateText(originalDesc);

          items.add({
            "id": id,
            "name": translatedName,
            "originalName": originalName,
            "price": "₹${itemData['price'] ?? ''}",
            "description": translatedDesc,
            "image": imagePath,
            "category": translatedCategoryName, // ✅ translated category
          });
        }

        if (items.isNotEmpty) {
          tempCategories.add({
            "name": translatedCategoryName, // ✅ translated category
            "expanded": true,
            "items": items,
          });
        }
      }

      if (mounted) {
        setState(() {
          categories = tempCategories;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
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

  void _filterMenu(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _showMenuBottomSheet(Map<String, dynamic> item) {
    final imageUrl = _imageUrlCache[item["image"]];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MenuBottomSheet(
        item: item,
        imageUrl: imageUrl,
        onAdd: (count) {
          final id = item["id"];
          setState(() {
            buttonStates[id]!["isCompleted"] = true;
            buttonStates[id]!["count"] = count;
          });
        },
      ),
    );
  }

  void _updateButtonState(int id, bool isCompleted, int count) {
    setState(() {
      buttonStates[id]!["isCompleted"] = isCompleted;
      buttonStates[id]!["count"] = count;
    });
  }

  void _scrollToCategory(String category) {
    setState(() {
      expandedCategories.updateAll((key, value) => key == category);
    });

    Future.delayed(const Duration(milliseconds: 310), () {
      final key = categoryKeys[category];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      } else {
        Future.delayed(const Duration(milliseconds: 20), () {
          _scrollToCategory(category);
        });
      }
    });
  }

  Widget _buildImage(String imagePath) {
    final imageValue = _imageUrlCache[imagePath];

    if (imageValue == null) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade700,
        highlightColor: Colors.grey.shade500,
        period: const Duration(milliseconds: 1000),
        child: Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade700,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
        ),
      );
    }

    if (imageValue == '__error__') {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: const Icon(Icons.fastfood, size: 40, color: Colors.grey),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Image.network(
        imageValue,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalCount = buttonStates.values.fold(
      0,
      (sum, state) => sum + (state["count"] as int),
    );

    final groupedItems = <String, List<Map<String, dynamic>>>{};
    for (var cat in filteredCategories) {
      final catName = cat["name"];
      groupedItems[catName] = List<Map<String, dynamic>>.from(cat["items"]);

      expandedCategories.putIfAbsent(catName, () => true);
      categoryKeys.putIfAbsent(catName, () => GlobalKey());
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryBackground,
        elevation: 2,
        title: _hotelLoading
            ? Shimmer.fromColors(
                baseColor: Colors.grey.shade600,
                highlightColor: Colors.grey.shade300,
                child: Container(height: 16, width: 120, color: Colors.grey),
              )
            : Text(
                _hotelName ?? 'Menu',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: AppColors.OrangeColor),
            onPressed: () {
              LanguageBottomSheet.show(
                context: context,
                onSelected: (code, name) async {
                  debugPrint("Selected language: $name ($code)");

                  setState(() {
                    selectedLangCode = code;
                    selectedLangName = name;
                  });

                  // Re-fetch or re-translate items
                  await fetchCategoriesAndItems();

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("$name selected")));
                },
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.sort, color: AppColors.OrangeColor),
            onPressed: () {
              CategoryBottomSheet.show(
                context,
                groupedItems.keys.toList(),
                _scrollToCategory,
              );
            },
          ),
        ],
      ),

      body: Stack(
        children: [
          Column(
            children: [
              MenuSearchBar(
                controller: _searchController,
                onChanged: _filterMenu,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: groupedItems.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          controller: _scrollController,
                          padding: EdgeInsets.only(
                            bottom: totalCount > 0 ? 100 : 0,
                          ),
                          children: groupedItems.entries.map((entry) {
                            final categoryName = entry.key;
                            final items = entry.value;
                            final isExpanded =
                                expandedCategories[categoryName] ?? true;

                            return Container(
                              key: categoryKeys[categoryName],
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryBackground,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        expandedCategories[categoryName] =
                                            !isExpanded;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      height: isExpanded ? 50 : 20,
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              categoryName,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.LightGreyColor,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Icon(
                                            isExpanded
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            color: AppColors.OrangeColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  AnimatedCrossFade(
                                    firstChild: const SizedBox.shrink(),
                                    secondChild: LayoutBuilder(
                                      builder: (context, constraints) {
                                        double itemWidth =
                                            (constraints.maxWidth - 10) / 2;

                                        return Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: items.map((item) {
                                            final id = item["id"];
                                            final state = buttonStates[id]!;

                                            final imageUrl =
                                                _imageUrlCache[item["image"]];

                                            return SizedBox(
                                              width: itemWidth,
                                              child: GestureDetector(
                                                onTap: () =>
                                                    _showMenuBottomSheet(item),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: AppColors
                                                        .primaryBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.05),
                                                        blurRadius: 4,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      // Image with shimmer
                                                      Container(
                                                        height: 120,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              const BorderRadius.vertical(
                                                                top:
                                                                    Radius.circular(
                                                                      16,
                                                                    ),
                                                              ),
                                                        ),
                                                        child: _buildImage(
                                                          item["image"],
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      // Name
                                                      Container(
                                                        height: 60,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                            ),
                                                        child: Text(
                                                          item["name"],
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AppColors
                                                                .LightGreyColor,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      // Row with price and button
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                            ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              item["price"],
                                                              style: const TextStyle(
                                                                color: AppColors
                                                                    .OrangeColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            ToggleAddButton(
                                                              isCompleted:
                                                                  state["isCompleted"],
                                                              count:
                                                                  state["count"],
                                                              onChanged:
                                                                  (
                                                                    newCompleted,
                                                                    newCount,
                                                                  ) {
                                                                    _updateButtonState(
                                                                      id,
                                                                      newCompleted,
                                                                      newCount,
                                                                    );
                                                                  },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                                    crossFadeState: isExpanded
                                        ? CrossFadeState.showSecond
                                        : CrossFadeState.showFirst,
                                    duration: const Duration(milliseconds: 300),
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
          if (totalCount > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomCartContainer(
                totalCount: totalCount,
                onViewCart: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartPage()),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
