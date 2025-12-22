import 'package:flutter/material.dart';
import 'package:menu_scan_web/Admin_Pannel/widgets/common_header.dart';
import 'package:menu_scan_web/Custom/App_colors.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Column(
        children: [
          const SizedBox(height: 25),

          // Common Header
          const CommonHeader(showSearchBar: false),

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

                      // Name TextField
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
                      const SizedBox(height: 16),

                      // Contact Number TextField
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
                      const SizedBox(height: 16),

                      // Message TextField
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

                      // Submit Button
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
                            // Here you can handle form submission
                            final name = _nameController.text;
                            final contact = _contactController.text;
                            final message = _messageController.text;

                            if (name.isNotEmpty &&
                                contact.isNotEmpty &&
                                message.isNotEmpty) {
                              // For now just show a dialog
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Message Sent"),
                                  content: Text(
                                    "Name: $name\nContact: $contact\nMessage: $message",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                              );

                              // Clear fields
                              _nameController.clear();
                              _contactController.clear();
                              _messageController.clear();
                            }
                          },
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
