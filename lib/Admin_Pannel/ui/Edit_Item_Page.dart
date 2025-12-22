import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_scan_web/Admin_Pannel/ui/Category_List_Page.dart';
import 'package:menu_scan_web/Admin_Pannel/widgets/common_header.dart';
import 'package:menu_scan_web/Custom/App_colors.dart';

class EditItemPage extends StatefulWidget {
  final int categoryIndex;
  final int itemIndex;

  const EditItemPage({
    Key? key,
    required this.categoryIndex,
    required this.itemIndex,
  }) : super(key: key);

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  // Veg / Non-Veg state
  bool _isVeg = false;
  bool _isNonVeg = false;

  @override
  void initState() {
    super.initState();
    final item = categories[widget.categoryIndex]["items"][widget.itemIndex];
    _nameController = TextEditingController(text: item["name"]);
    _priceController = TextEditingController(text: item["price"]);
    _descriptionController = TextEditingController(text: item["description"]);
    _imageBytes = item["image"];
    if (item.containsKey("type")) {
      _isVeg = item["type"] == "Veg";
      _isNonVeg = item["type"] == "Non-Veg";
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
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
              const CommonHeader(showSearchBar: false),
              const SizedBox(height: 25),
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
                          const Text(
                            "Edit Item",
                            style: TextStyle(
                              color: AppColors.whiteColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),

                          _inputField(
                            controller: _nameController,
                            label: "Item Name",
                          ),
                          const SizedBox(height: 16),
                          _inputField(
                            controller: _priceController,
                            label: "Price",
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          _inputField(
                            controller: _descriptionController,
                            label: "Description",
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),

                          // Image Picker
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.LightGreyColor,
                                ),
                                color: Colors.black12,
                              ),
                              child: _imageBytes == null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.add_a_photo,
                                          size: 40,
                                          color: AppColors.LightGreyColor,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Upload Item Image",
                                          style: TextStyle(
                                            color: AppColors.LightGreyColor,
                                          ),
                                        ),
                                      ],
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.memory(
                                        _imageBytes!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Veg / Non-Veg checkboxes inline
                          Row(
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _isVeg,
                                    onChanged: (val) {
                                      setState(() {
                                        _isVeg = val ?? false;
                                        if (_isVeg) _isNonVeg = false;
                                      });
                                    },
                                    activeColor: AppColors.OrangeColor,
                                    checkColor: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    "Veg",
                                    style: TextStyle(
                                      color: AppColors.whiteColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _isNonVeg,
                                    onChanged: (val) {
                                      setState(() {
                                        _isNonVeg = val ?? false;
                                        if (_isNonVeg) _isVeg = false;
                                      });
                                    },
                                    activeColor: AppColors.OrangeColor,
                                    checkColor: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    "Non-Veg",
                                    style: TextStyle(
                                      color: AppColors.whiteColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Update Button
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
                                if (_nameController.text.isNotEmpty &&
                                    _priceController.text.isNotEmpty &&
                                    _descriptionController.text.isNotEmpty &&
                                    _imageBytes != null) {
                                  setState(() {
                                    categories[widget
                                        .categoryIndex]["items"][widget
                                        .itemIndex] = {
                                      "name": _nameController.text,
                                      "price": _priceController.text,
                                      "description":
                                          _descriptionController.text,
                                      "image": _imageBytes,
                                      "type": _isVeg
                                          ? "Veg"
                                          : (_isNonVeg ? "Non-Veg" : "Unknown"),
                                    };
                                  });
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text(
                                "Update Item",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.whiteColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Cancel Button
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
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Cancel",
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
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.whiteColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.LightGreyColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.OrangeColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.LightGreyColor),
        ),
      ),
    );
  }
}
