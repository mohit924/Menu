import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:menu_scan_web/Custom/App_colors.dart';
import 'package:menu_scan_web/Customer/Widgets/Language_Bttom_Sheet%20.dart';
import 'package:menu_scan_web/Customer/Widgets/item_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<int, SelectedItem> _cartItemsMap = {}; // key = itemID
  final translator = GoogleTranslator();
  Map<String, String> _translatedNames = {}; // cache for translations

  @override
  void initState() {
    super.initState();
    _loadCartFromPrefs();
  }

  Future<void> _loadCartFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartData = prefs.getString('cart_items');
    if (cartData != null) {
      final List<dynamic> decoded = jsonDecode(cartData);
      final Map<int, SelectedItem> loadedItems = {};
      for (var itemMap in decoded) {
        final item = SelectedItem.fromMap(Map<String, dynamic>.from(itemMap));
        loadedItems[item.id] = item;
      }
      setState(() {
        _cartItemsMap = loadedItems;
      });
      _translateAllItems();
    }
  }

  Future<void> _translateAllItems() async {
    final langProvider = context.read<LanguageProvider>();
    final langCode = langProvider.code;

    if (langCode == "en") {
      _translatedNames.clear();
      setState(() {});
      return;
    }

    for (var item in _cartItemsMap.values) {
      final result = await translator.translate(item.name, to: langCode);
      _translatedNames[item.name] = result.text;
    }
    setState(() {});
  }

  int get totalItems =>
      _cartItemsMap.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _cartItemsMap.values.fold(
    0,
    (sum, item) =>
        sum + (item.quantity * int.parse(item.price.replaceAll('₹', ''))),
  );

  void _updateItemQuantity(int id, int change) async {
    setState(() {
      if (_cartItemsMap.containsKey(id)) {
        _cartItemsMap[id]!.quantity += change;
        if (_cartItemsMap[id]!.quantity <= 0) {
          _cartItemsMap.remove(id);
        }
      }
    });
    await _saveCartToPrefs();
  }

  Future<void> _saveCartToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsList = _cartItemsMap.values.map((e) => e.toMap()).toList();
    await prefs.setString('cart_items', jsonEncode(itemsList));
  }

  void _onLanguageChanged() {
    _translateAllItems();
  }

  @override
  Widget build(BuildContext context) {
    final _cartItems = _cartItemsMap.values.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.home, color: AppColors.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'My',
              style: TextStyle(
                color: AppColors.OrangeColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4),
            Text(
              'Shortlist',
              style: TextStyle(
                color: AppColors.OrangeColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: AppColors.whiteColor),
            onPressed: () {
              LanguageBottomSheet.show(
                context: context,
                onSelected: (code, name) {
                  final langProvider = context.read<LanguageProvider>();
                  langProvider.setLanguage(code, name);
                  _onLanguageChanged();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("$name selected")));
                },
              );
            },
          ),
        ],
      ),
      backgroundColor: AppColors.primaryBackground,
      body: Column(
        children: [
          Expanded(
            child: _cartItems.isEmpty
                ? const Center(
                    child: Text(
                      "Your cart is empty",
                      style: TextStyle(
                        color: AppColors.LightGreyColor,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      final displayName =
                          _translatedNames[item.name] ?? item.name;

                      return Card(
                        color: AppColors.secondaryBackground,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(
                                  displayName,
                                  style: const TextStyle(
                                    color: AppColors.LightGreyColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Container(
                                width: 120,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.OrangeColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          _updateItemQuantity(item.id, -1),
                                      child: const Icon(
                                        Icons.remove,
                                        color: AppColors.whiteColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${item.quantity}",
                                      style: const TextStyle(
                                        color: AppColors.whiteColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () =>
                                          _updateItemQuantity(item.id, 1),
                                      child: const Icon(
                                        Icons.add,
                                        color: AppColors.whiteColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 80,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "₹${item.quantity * int.parse(item.price.replaceAll('₹', ''))}",
                                  style: const TextStyle(
                                    color: AppColors.OrangeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            color: AppColors.secondaryBackground,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Total: ₹${totalPrice.toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
