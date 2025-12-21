import 'package:flutter/material.dart';
import 'package:menu_scan_web/Admin_Pannel/ui/Add_Item_Page.dart';
import 'package:menu_scan_web/Admin_Pannel/ui/Category_List_Page.dart';
import 'package:menu_scan_web/Custom/App_colors.dart';

class ItemListPage extends StatefulWidget {
  final int categoryIndex;
  const ItemListPage({Key? key, required this.categoryIndex}) : super(key: key);

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  @override
  Widget build(BuildContext context) {
    final category = categories[widget.categoryIndex];
    final items = category["items"] as List;

    final screenWidth = MediaQuery.of(context).size.width;

    // Determine number of cards per row
    int cardsPerRow;
    if (screenWidth >= 1200) {
      cardsPerRow = 4;
    } else if (screenWidth >= 900) {
      cardsPerRow = 3;
    } else if (screenWidth >= 600) {
      cardsPerRow = 2;
    } else {
      cardsPerRow = 1;
    }

    final cardWidth = (screenWidth - (16 * (cardsPerRow + 1))) / cardsPerRow;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text(
          "${category["name"]} Items",
          style: const TextStyle(color: AppColors.whiteColor),
        ),
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.whiteColor, // back button color
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: items.map((item) {
            return GestureDetector(
              onTap: () {
                // Optional: handle item click
              },
              child: Container(
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
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.OrangeColor.withOpacity(0.2),
                      child: const Icon(
                        Icons.fastfood,
                        color: AppColors.OrangeColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item["name"],
                        style: const TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.OrangeColor,
                      size: 18,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.OrangeColor,
        icon: const Icon(Icons.add),
        label: const Text("Add Item"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddItemPage(categoryIndex: widget.categoryIndex),
            ),
          ).then((_) => setState(() {}));
        },
      ),
    );
  }
}
