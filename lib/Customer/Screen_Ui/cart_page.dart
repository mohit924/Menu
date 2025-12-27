import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:menu_scan_web/Custom/App_colors.dart';
import 'package:menu_scan_web/Custom/place_order_button.dart';
import 'package:menu_scan_web/Customer/Widgets/item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<SelectedItem> _cartItems = [];

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
      final loadedItems = decoded
          .map(
            (itemMap) =>
                SelectedItem.fromMap(Map<String, dynamic>.from(itemMap)),
          )
          .toList();

      setState(() {
        _cartItems = loadedItems;
      });
    }
  }

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _cartItems.fold(
    0,
    (sum, item) =>
        sum + (item.quantity * int.parse(item.price.replaceAll('₹', ''))),
  );

  void _incrementItem(int index) {
    setState(() {
      _cartItems[index].quantity += 1;
    });
    _saveCartToPrefs();
  }

  void _decrementItem(int index) {
    setState(() {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity -= 1;
      } else {
        _cartItems.removeAt(index);
      }
    });
    _saveCartToPrefs();
  }

  Future<void> _saveCartToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsList = _cartItems.map((e) => e.toMap()).toList();
    prefs.setString('cart_items', jsonEncode(itemsList));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        title: const Text(
          "Your Cart",
          style: TextStyle(color: AppColors.whiteColor),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home, color: AppColors.whiteColor),
          onPressed: () {
            Navigator.pop(context);
            // );
          },
        ),
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
                                  item.name,
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
                                      onTap: () => _decrementItem(index),
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
                                      onTap: () => _incrementItem(index),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total: ₹${totalPrice.toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                PlaceOrderButton(
                  onPressed: () {
                    // TODO: handle order placement
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
