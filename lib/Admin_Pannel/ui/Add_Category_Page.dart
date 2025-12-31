import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_scan_web/Admin_Pannel/widgets/common_header.dart';
import 'package:menu_scan_web/Custom/App_colors.dart';
import 'package:menu_scan_web/Custom/app_loader.dart';
import 'package:menu_scan_web/Custom/app_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({Key? key}) : super(key: key);

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final TextEditingController _nameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? hotelID;
  bool _isLoading = false; // ✅ Add loading state

  @override
  void initState() {
    super.initState();
    _loadHotelID();
  }

  Future<void> _loadHotelID() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHotelID = prefs.getString('hotelID');

    if (savedHotelID == null || savedHotelID.isEmpty) {
      AppSnackBar.show(
        context,
        message: "Session expired. Please login again.",
        type: SnackType.error,
      );
      Navigator.pop(context);
      return;
    }

    setState(() {
      hotelID = savedHotelID;
    });
  }

  void addCategory() async {
    final categoryName = _nameController.text.trim();

    if (categoryName.isEmpty) {
      AppSnackBar.show(
        context,
        message: "Please enter category name",
        type: SnackType.error,
      );
      return;
    }

    if (hotelID == null) {
      AppSnackBar.show(
        context,
        message: "Hotel not found. Please login again.",
        type: SnackType.error,
      );
      return;
    }

    setState(() => _isLoading = true); // ✅ start loader

    try {
      await _firestore.runTransaction((transaction) async {
        final counterDoc = _firestore
            .collection('CategoryCounters')
            .doc("GLOBAL_CATEGORY_COUNTER");

        final counterSnapshot = await transaction.get(counterDoc);
        int newCategoryID = 1;

        if (counterSnapshot.exists) {
          final currentID = counterSnapshot['lastID'] ?? 0;
          newCategoryID = currentID + 1;
          transaction.update(counterDoc, {'lastID': newCategoryID});
        } else {
          transaction.set(counterDoc, {'lastID': newCategoryID});
        }

        final categoryDoc = _firestore.collection('AddCategory').doc();
        transaction.set(categoryDoc, {
          'categoryName': categoryName,
          'hotelID': hotelID,
          'categoryID': newCategoryID,
          'createdAt': Timestamp.now(),
        });
      });

      AppSnackBar.show(
        context,
        message: "Category added successfully!",
        type: SnackType.success,
      );

      Navigator.pop(context);
    } catch (e) {
      AppSnackBar.show(context, message: "Error: $e", type: SnackType.error);
    } finally {
      setState(() => _isLoading = false); // ✅ stop loader
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 25),
              const CommonHeader(showSearchBar: false, currentPage: "Category"),
              Expanded(
                child: Center(
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
                          TextField(
                            controller: _nameController,
                            style: const TextStyle(color: AppColors.whiteColor),
                            decoration: InputDecoration(
                              labelText: "Category Name",
                              labelStyle: const TextStyle(
                                color: AppColors.LightGreyColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
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
                              onPressed: _isLoading ? null : addCategory,
                              child: const Text(
                                "Add Category",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.whiteColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.OrangeColor,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
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
              ),
            ],
          ),

          if (_isLoading) AppLoaderWidget(message: "Adding Category..."),
        ],
      ),
    );
  }
}
