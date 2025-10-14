import 'package:flutter/material.dart';
import 'package:menu_scan_web/Custom/App_colors.dart';
import 'package:menu_scan_web/Custom/Custom_Button.dart';

class MenuBottomSheet extends StatelessWidget {
  final Map<String, dynamic> item;

  const MenuBottomSheet({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Container(
      height: height * 0.6,
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: height * 0.3,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.asset(item["image"], fit: BoxFit.contain),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item["name"],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.LightGreyColor,
                        ),
                      ),
                      ToggleAddButton(
                        width: 150,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${item["name"]} added!")),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  Text(
                    item["price"],
                    style: const TextStyle(
                      color: AppColors.OrangeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    "Inspirational designs, illustrations, and graphic elements from the world’s best designers.Want more inspiration",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.LightGreyColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        item["description"],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
