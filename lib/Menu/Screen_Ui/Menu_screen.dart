import 'package:flutter/material.dart';
import 'package:menu_scan_web/Custom/App_colors.dart';
import 'package:menu_scan_web/Custom/BottomCartContainer.dart';
import 'package:menu_scan_web/Custom/Custom_Button.dart';
import 'package:menu_scan_web/Menu/Screen_Ui/cart_page.dart';
import 'package:menu_scan_web/Menu/Widgets/Menu_Bottom_Sheet.dart';
import 'package:menu_scan_web/Menu/Widgets/Menu_Search_Bar.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> menuItems = [];
  List<Map<String, dynamic>> filteredItems = [];

  Map<int, Map<String, dynamic>> buttonStates = {};

  @override
  void initState() {
    super.initState();

    // Dummy menu data
    menuItems = List.generate(10, (index) {
      return {
        "id": index,
        "name": "Menu ${index + 1}",
        "price": "₹${(index + 1) * 50}",
        "image": "assets/noodles.png",
        "description":
            "This is the description for Menu ${index + 1}. Delicious and fresh!",
      };
    });

    filteredItems = List.from(menuItems);

    // Initialize button states
    for (var item in menuItems) {
      buttonStates[item["id"]] = {"isCompleted": false, "count": 0};
    }
  }

  void _filterMenu(String query) {
    setState(() {
      filteredItems = menuItems
          .where(
            (item) => item["name"].toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  void _showMenuBottomSheet(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MenuBottomSheet(item: item),
    );
  }

  void _updateButtonState(int id, bool isCompleted, int count) {
    setState(() {
      buttonStates[id]!["isCompleted"] = isCompleted;
      buttonStates[id]!["count"] = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Total count of items added
    int totalCount = buttonStates.values.fold(
      0,
      (int sum, state) => sum + (state["count"] as int? ?? 0),
    );

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text(
          "Menu",
          style: TextStyle(color: AppColors.whiteColor),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryBackground,
        elevation: 2,
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
                  child: GridView.builder(
                    itemCount: filteredItems.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final id = item["id"];
                      final state = buttonStates[id]!;

                      return GestureDetector(
                        onTap: () => _showMenuBottomSheet(context, item),
                        child: Card(
                          color: AppColors.secondaryBackground,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      item["image"],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item["name"],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.LightGreyColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item["price"],
                                      style: const TextStyle(
                                        color: AppColors.OrangeColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ToggleAddButton(
                                      isCompleted: state["isCompleted"],
                                      count: state["count"],
                                      onChanged: (newCompleted, newCount) {
                                        _updateButtonState(
                                          id,
                                          newCompleted,
                                          newCount,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
