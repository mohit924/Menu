import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_scan_web/Custom/app_loader.dart';
import 'package:menu_scan_web/Custom/app_snackbar.dart';
import 'package:menu_scan_web/Customer/Widgets/Language_Bttom_Sheet%20.dart';
import 'package:menu_scan_web/Customer/Widgets/item_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isMenuLoading = true;
  bool _isInitialLoad = true;
  bool _isLanguageChanging = false;
  String? _lastLangCode;

  final translator = GoogleTranslator();
  Map<int, SelectedItem> selectedItems = {}; // key = itemID

  String selectedLangCode = "en";
  String selectedLangName = "English";

  // Cache: langCode -> originalText -> translatedText
  Map<String, Map<String, String>> translatedCache = {};

  @override
  void initState() {
    super.initState();
    _isInitialLoad = true;
    _isMenuLoading = true;

    fetchCategoriesAndItems();
    _fetchHotelName();
    _loadCartFromPrefs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentLangCode = context.watch<LanguageProvider>().code;

    // First time → just store the language
    if (_lastLangCode == null) {
      _lastLangCode = currentLangCode;
      return;
    }

    // Only reload if language actually changed
    if (currentLangCode != _lastLangCode) {
      _lastLangCode = currentLangCode;

      setState(() {
        _isLanguageChanging = true;
        _isMenuLoading = true;
      });

      // ✅ Clear previous translations
      translatedCache.clear();

      // ✅ Reload menu with new language
      fetchCategoriesAndItems();
    }
  }

  Future<void> _loadCartFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final int? savedTimestamp = prefs.getInt('cart_timestamp');

    if (savedTimestamp != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final difference = now - savedTimestamp;
      const twentyFourHours = 24 * 60 * 60 * 1000;

      if (difference > twentyFourHours) {
        // Cart expired → clear it
        prefs.remove('cart_items');
        prefs.remove('cart_timestamp');
        selectedItems.clear();
        buttonStates.forEach((key, value) {
          value["count"] = 0;
          value["isCompleted"] = false;
        });
        return;
      }
    }

    final String? cartData = prefs.getString('cart_items');
    if (cartData != null) {
      final List<dynamic> decoded = jsonDecode(cartData);
      final Map<int, SelectedItem> loadedItems = {};

      for (var itemMap in decoded) {
        final item = SelectedItem.fromMap(Map<String, dynamic>.from(itemMap));
        loadedItems[item.id] = item;
      }

      setState(() {
        selectedItems = loadedItems;

        // Update buttonStates to match new cart
        for (var entry in buttonStates.entries) {
          final id = entry.key;
          entry.value["count"] = selectedItems[id]?.quantity ?? 0;
          entry.value["isCompleted"] = (selectedItems[id]?.quantity ?? 0) > 0;
        }
      });
    }
  }

  void _updateItemCount(int id, int count, Map<String, dynamic> item) async {
    setState(() {
      buttonStates[id]!["isCompleted"] = count > 0;
      buttonStates[id]!["count"] = count;
    });

    if (count > 0) {
      selectedItems[id] = SelectedItem(
        id: id,
        name: item["originalName"],
        price: item["price"],
        quantity: count,
      );
    } else {
      selectedItems.remove(id);
    }

    final prefs = await SharedPreferences.getInstance();
    final itemsList = selectedItems.values.map((e) => e.toMap()).toList();
    prefs.setString('cart_items', jsonEncode(itemsList));

    // Save current timestamp
    prefs.setInt('cart_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  Future<String> translateText(String text) async {
    final langProvider = context.read<LanguageProvider>();
    final selectedLangCode = langProvider.code;

    if (selectedLangCode == "en" || text.isEmpty) return text;

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
          final bool isAvailable = itemData['available'] == true;

          if (!isAvailable) continue;

          final id = itemData['itemID'] as int;

          final imagePath = itemData['imageUrl'] ?? '';
          _preloadImage(imagePath);

          final originalName = itemData['itemName'] ?? '';
          final originalDesc = itemData['description'] ?? '';

          final translatedName = await translateText(originalName);
          final translatedDesc = await translateText(originalDesc);

          // Merge saved cart quantity
          int savedCount = 0;
          if (selectedItems.containsKey(id)) {
            savedCount = selectedItems[id]!.quantity;
          }

          buttonStates[id] = {
            "isCompleted": savedCount > 0,
            "count": savedCount,
          };

          items.add({
            "id": id,
            "name": translatedName,
            "originalName": originalName,
            "price": "₹${itemData['price'] ?? ''}",
            "description": translatedDesc,
            "image": imagePath,
            "category": translatedCategoryName,
          });
        }

        if (items.isNotEmpty) {
          tempCategories.add({
            "name": translatedCategoryName,
            "expanded": true,
            "items": items,
          });
        }
      }

      if (mounted) {
        setState(() {
          categories = tempCategories;
          _isMenuLoading = false;
          _isInitialLoad = false;
          _isLanguageChanging = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMenuLoading = false;
          _isLanguageChanging = false;
          _isInitialLoad = false;
        });

        AppSnackBar.show(context, message: "Error: $e", type: SnackType.error);
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
    final state = buttonStates[item["id"]];
    final initialCount = (buttonStates[item["id"]]?["count"] ?? 1)
        .clamp(1, double.infinity)
        .toInt();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MenuBottomSheet(
        item: item,
        imageUrl: imageUrl,
        initialCount: initialCount,
        onAdd: (count) {
          _updateItemCount(item["id"], count, item);
        },
      ),
    );
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
        backgroundColor: AppColors.primaryBackground,
        elevation: 2,
        titleSpacing: 0, // start title from left
        title: Container(
          padding: const EdgeInsets.only(left: 16), // optional padding
          child: Text(
            _hotelName ?? 'Menu',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.OrangeColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate, color: AppColors.whiteColor),
            onPressed: () {
              LanguageBottomSheet.show(
                context: context,
                onSelected: (code, name) {
                  context.read<LanguageProvider>().setLanguage(code, name);

                  AppSnackBar.show(
                    context,
                    message: "$name selected",
                    type: SnackType.success,
                  );
                },
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.sort, color: AppColors.whiteColor),
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
                  child: _isMenuLoading
                      ? AppLoaderWidget(
                          message: _isLanguageChanging
                              ? "Updating language..."
                              : "Loading menu...",
                        )
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
                                      height: isExpanded ? 50 : 25,
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
                                                                    _updateItemCount(
                                                                      id,
                                                                      newCount,
                                                                      item,
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
                onViewCart: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartPage()),
                  );

                  // 🔥 Reload cart & sync buttons
                  _loadCartFromPrefs();
                },
              ),
            ),
        ],
      ),
    );
  }
}
