import 'package:flutter/material.dart';
import 'package:menu_scan_web/Admin_Pannel/ui/Add_Item_Page.dart';
import 'package:menu_scan_web/Admin_Pannel/ui/Edit_Item_Page.dart';
import 'package:menu_scan_web/Admin_Pannel/ui/Category_List_Page.dart';
import 'package:menu_scan_web/Admin_Pannel/widgets/common_header.dart';
import 'package:menu_scan_web/Custom/App_colors.dart';

class ItemListPage extends StatefulWidget {
  final int categoryIndex;
  const ItemListPage({Key? key, required this.categoryIndex}) : super(key: key);

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  String _searchQuery = '';
  late List<Map<String, dynamic>> filteredItems;

  @override
  void initState() {
    super.initState();
    filteredItems = (categories[widget.categoryIndex]["items"] as List)
        .cast<Map<String, dynamic>>();
  }

  void _filterItems(String query) {
    final allItems = (categories[widget.categoryIndex]["items"] as List)
        .cast<Map<String, dynamic>>();
    setState(() {
      _searchQuery = query;
      filteredItems = allItems
          .where(
            (item) => item["name"].toString().toLowerCase().contains(
              query.toLowerCase(),
            ),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
      body: Column(
        children: [
          const SizedBox(height: 25),
          CommonHeader(showSearchBar: true, onSearchChanged: _filterItems),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topLeft,
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: filteredItems.map((item) {
                    final itemIndex =
                        (categories[widget.categoryIndex]["items"] as List)
                            .cast<Map<String, dynamic>>()
                            .indexOf(item);
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
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.OrangeColor.withOpacity(
                              0.2,
                            ),
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
                          PopupMenuButton(
                            icon: const Icon(
                              Icons.more_horiz,
                              color: AppColors.OrangeColor,
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.edit,
                                      color: AppColors.OrangeColor,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: const [
                                    Icon(Icons.delete, color: Colors.redAccent),
                                    SizedBox(width: 8),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditItemPage(
                                      categoryIndex: widget.categoryIndex,
                                      itemIndex: itemIndex,
                                    ),
                                  ),
                                ).then((_) => setState(() {}));
                              } else if (value == 'delete') {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    backgroundColor: Colors.white,
                                    title: Row(
                                      children: const [
                                        Icon(
                                          Icons.delete_forever,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Delete Category',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: const Text(
                                      'Are you sure you want to delete this item?',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    actionsPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[300],
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.OrangeColor,
        icon: const Icon(Icons.add, color: AppColors.whiteColor),
        label: const Text(
          "Add Item",
          style: TextStyle(color: AppColors.whiteColor),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddItemPage(categoryIndex: widget.categoryIndex),
            ),
          ).then(
            (_) => setState(() {
              filteredItems =
                  (categories[widget.categoryIndex]["items"] as List)
                      .cast<Map<String, dynamic>>();
            }),
          );
        },
      ),
    );
  }
}
