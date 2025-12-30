import 'package:flutter/material.dart';
import 'package:menu_scan_web/Custom/App_colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageBottomSheet {
  static void show({
    required BuildContext context,
    required Function(String code, String name) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Select Language",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.OrangeColor,
                ),
              ),
            ),
            _languageTile(
              context,
              title: "English",
              code: "en",
              onSelected: onSelected,
            ),
            const Divider(
              color: AppColors.LightGreyColor,
              indent: 20,
              endIndent: 20,
            ),
            _languageTile(
              context,
              title: "Hindi",
              code: "hi",
              onSelected: onSelected,
            ),
            const Divider(
              color: AppColors.LightGreyColor,
              indent: 20,
              endIndent: 20,
            ),
            _languageTile(
              context,
              title: "Marathi",
              code: "mr",
              onSelected: onSelected,
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  static Widget _languageTile(
    BuildContext context, {
    required String title,
    required String code,
    required Function(String code, String name) onSelected,
  }) {
    final langProvider = context.watch<LanguageProvider>();
    final isSelected =
        langProvider.code == code; // check if this language is selected

    return ListTile(
      leading: const Icon(Icons.translate, color: AppColors.LightGreyColor),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.OrangeColor : AppColors.whiteColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onSelected(code, title);
      },
    );
  }
}

class LanguageProvider extends ChangeNotifier {
  String _code = "en";
  String _name = "English";

  String get code => _code;
  String get name => _name;

  LanguageProvider() {
    _loadSavedLanguage();
  }

  void setLanguage(String code, String name) async {
    _code = code;
    _name = name;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('lang_code', code);
    prefs.setString('lang_name', name);
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('lang_code');
    final name = prefs.getString('lang_name');
    if (code != null && name != null) {
      _code = code;
      _name = name;
      notifyListeners();
    }
  }
}
