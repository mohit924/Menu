import 'package:flutter/material.dart';
import 'package:menu_scan_web/Admin_Pannel/ui/Add_Category_Page.dart';
import 'package:menu_scan_web/Admin_Pannel/ui/Item_List_Page.dart';
import 'package:menu_scan_web/Custom/App_colors.dart';

// Dummy data
List<Map<String, dynamic>> categories = [
  {
    "name": "Starters",
    "icon": Icons.fastfood,
    "items": [
      {"name": "Spring Rolls", "price": "₹100", "show": true},
      {"name": "Fried Momos", "price": "₹120", "show": true},
    ],
  },
  {"name": "Main Course", "icon": Icons.restaurant, "items": []},
  {"name": "Desserts", "icon": Icons.cake, "items": []},
  {"name": "Beverages", "icon": Icons.local_cafe, "items": []},
];

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({Key? key}) : super(key: key);

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine card width based on screen width
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
        title: const Text(
          "Categories",
          style: TextStyle(color: AppColors.whiteColor),
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
          children: categories.map((category) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItemListPage(
                      categoryIndex: categories.indexOf(category),
                    ),
                  ),
                );
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
                      child: Icon(
                        category["icon"],
                        color: AppColors.OrangeColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        category["name"],
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
        label: const Text("Add Category"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCategoryPage()),
          ).then((_) => setState(() {}));
        },
      ),
    );
  }
}
