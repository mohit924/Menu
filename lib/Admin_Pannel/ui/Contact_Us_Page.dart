import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_scan_web/Admin_Pannel/ui/Dashboard.dart';
import 'package:menu_scan_web/Admin_Pannel/widgets/common_header.dart';
import 'package:menu_scan_web/Custom/App_colors.dart';
import 'package:menu_scan_web/Custom/app_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? hotelID;

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
        message: "Session expired. Please login again",
        type: SnackType.error,
      );

      Navigator.pop(context);
      return;
    }

    setState(() {
      hotelID = savedHotelID;
    });
  }

  void submitMessage() async {
    if (hotelID == null) return;

    final name = _nameController.text.trim();
    final contact = _contactController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty || contact.isEmpty || message.isEmpty) {
      AppSnackBar.show(
        context,
        message: "Please fill all fields",
        type: SnackType.error,
      );

      return;
    }

    try {
      await _firestore.collection('ContactUs').add({
        'name': name,
        'contact': contact,
        'message': message,
        'hotelID': hotelID!, // ✅ dynamic
        'createdAt': Timestamp.now(),
      });
      AppSnackBar.show(
        context,
        message: "Message sent successfully!",
        type: SnackType.success,
      );

      _nameController.clear();
      _contactController.clear();
      _messageController.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
      );
    } catch (e) {
      AppSnackBar.show(
        context,
        message: "Error sending message: $e",
        type: SnackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Column(
        children: [
          const SizedBox(height: 25),
          const CommonHeader(showSearchBar: false, currentPage: "Contact Us"),
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
                        "Contact Us",
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
                          labelText: "Name",
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
                      const SizedBox(height: 16),
                      TextField(
                        controller: _contactController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: AppColors.whiteColor),
                        decoration: InputDecoration(
                          labelText: "Contact Number",
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
                      const SizedBox(height: 16),
                      TextField(
                        controller: _messageController,
                        maxLines: 4,
                        style: const TextStyle(color: AppColors.whiteColor),
                        decoration: InputDecoration(
                          labelText: "Message",
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
                          onPressed: submitMessage,
                          child: const Text(
                            "Submit",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.whiteColor,
                              fontWeight: FontWeight.bold,
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
    );
  }
}
