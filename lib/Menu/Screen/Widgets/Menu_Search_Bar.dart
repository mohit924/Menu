import 'package:flutter/material.dart';
import 'package:menu_scan_web/Custom/App_colors.dart';

class MenuSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const MenuSearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryBackground,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: "Search menu...",
          hintStyle: TextStyle(color: AppColors.LightGreyColor),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: AppColors.secondaryBackground,
        ),
      ),
    );
  }
}
