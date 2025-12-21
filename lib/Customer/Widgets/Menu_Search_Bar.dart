import 'package:flutter/material.dart';
import 'package:menu_scan_web/Custom/App_colors.dart';

class MenuSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const MenuSearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<MenuSearchBar> createState() => _MenuSearchBarState();
}

class _MenuSearchBarState extends State<MenuSearchBar> {
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {
        _showClear = widget.controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryBackground,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        style: const TextStyle(color: AppColors.LightGreyColor),
        decoration: InputDecoration(
          hintText: "Search menu...",
          hintStyle: const TextStyle(color: AppColors.LightGreyColor),
          prefixIcon: const Icon(Icons.search, color: AppColors.LightGreyColor),

          suffixIcon: _showClear
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.LightGreyColor,
                  ),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged('');
                  },
                )
              : null,

          filled: true,
          fillColor: AppColors.secondaryBackground,

          // 🔘 Normal (inactive) border
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.transparent, // no border
              width: 1,
            ),
          ),

          // 🟠 Active (focused) border
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.OrangeColor,
              width: 2,
            ),
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
