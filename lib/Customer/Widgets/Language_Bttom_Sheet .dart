import 'package:flutter/material.dart';

class LanguageBottomSheet {
  static void show({
    required BuildContext context,
    required Function(String code, String name) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            const Text(
              "Select Language",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            _languageTile(
              context,
              title: "English",
              code: "en",
              onSelected: onSelected,
            ),
            _languageTile(
              context,
              title: "Hindi",
              code: "hi",
              onSelected: onSelected,
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
    return ListTile(
      leading: const Icon(Icons.translate),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onSelected(code, title);
      },
    );
  }
}
