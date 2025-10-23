import 'package:flutter/material.dart';
import 'package:menu_scan_web/Custom/App_colors.dart';
import 'package:menu_scan_web/Custom/place_order_button.dart';
import 'package:menu_scan_web/Menu/Screen_Ui/Menu_screen.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<Map<String, dynamic>> _cartItems = [
    {"name": " Noodles ", "count": 2, "price": 100},
    {"name": "Pizza", "count": 1, "price": 250},
    {"name": "Burger", "count": 3, "price": 80},
  ];

  int get totalItems =>
      _cartItems.fold(0, (sum, item) => sum + (item["count"] as int));

  double get totalPrice => _cartItems.fold(
    0,
    (sum, item) => sum + (item["count"] as int) * (item["price"] as int),
  );

  void _incrementItem(int index) {
    setState(() {
      _cartItems[index]["count"] = (_cartItems[index]["count"] as int) + 1;
    });
  }

  void _decrementItem(int index) {
    setState(() {
      int current = _cartItems[index]["count"] as int;
      if (current > 1) {
        _cartItems[index]["count"] = current - 1;
      } else {
        _cartItems.removeAt(index);
      }
    });
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MenuScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_checkout,
              color: AppColors.whiteColor,
            ),
            onPressed: () {
              // Place order action
              print("Place Order clicked!");
              // You can also call your existing PlaceOrderButton logic here
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
                              // Circle indicator
                              Container(
                                width: 16,
                                height: 16,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.whiteColor,
                                    width: 2,
                                  ),
                                  color: index % 2 == 0
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),

                              // Name column
                              Expanded(
                                flex: 4,
                                child: Text(
                                  item["name"] ?? "Item",
                                  style: const TextStyle(
                                    color: AppColors.LightGreyColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),

                              // Count container column
                              Container(
                                width: 120, // fixed width to align all
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
                                      "${item["count"]}",
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

                              // Price column
                              Container(
                                width: 80,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "₹${(item["count"] as int) * (item["price"] as int)}",
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

          // Total section
          Container(
            color: AppColors.secondaryBackground,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              children: [
                Row(
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
                        print("Place Order clicked!");
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
