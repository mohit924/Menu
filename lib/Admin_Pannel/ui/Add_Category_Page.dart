import 'package:flutter/material.dart';
import 'package:menu_scan_web/Admin_Pannel/ui/Category_List_Page.dart';
import 'package:menu_scan_web/Custom/App_colors.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({Key? key}) : super(key: key);

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final TextEditingController _nameController = TextEditingController();
  IconData _icon = Icons.fastfood;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset("assets/post_login_bg.png", fit: BoxFit.cover),
          ),

          // Centered Card Container
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: screenWidth > 600 ? 500 : screenWidth * 0.9,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Add Category",
                      style: TextStyle(
                        color: AppColors.whiteColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Category Name TextField
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Category Name",
                        labelStyle: const TextStyle(
                          color: AppColors.LightGreyColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.LightGreyColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.OrangeColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Add Category Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.OrangeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (_nameController.text.isNotEmpty) {
                            categories.add({
                              "name": _nameController.text,
                              "icon": _icon,
                              "items": [],
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          "Add Category",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // View Categories Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.OrangeColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          // OR if you want to explicitly push:
                          // Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryListPage()));
                        },
                        child: const Text(
                          "View Categories",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.OrangeColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
