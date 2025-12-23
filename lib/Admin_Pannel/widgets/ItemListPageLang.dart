import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class ItemListPageLang extends StatefulWidget {
  @override
  _ItemListPageLangState createState() => _ItemListPageLangState();
}

class _ItemListPageLangState extends State<ItemListPageLang> {
  List<String> items = ["Burger", "Pizza", "Pasta", "Sandwich", "Salad"];
  List<String> languages = ["English", "Hindi", "French"];
  String selectedLanguage = "English";

  // Map<languageCode, Map<item, translation>>
  Map<String, Map<String, String>> translatedItems = {};

  final translator = GoogleTranslator();

  void translateItems(String targetLang) async {
    if (targetLang == "English") {
      setState(() {}); // just refresh to show English
      return;
    }

    String langCode = targetLangCode(targetLang);

    // Initialize inner map if it doesn't exist
    translatedItems.putIfAbsent(langCode, () => {});

    for (var item in items) {
      // Translate only if not already translated
      if (!translatedItems[langCode]!.containsKey(item)) {
        var translation = await translator.translate(item, to: langCode);
        setState(() {
          translatedItems[langCode]![item] = translation.text;
        });
      }
    }
  }

  String targetLangCode(String lang) {
    switch (lang) {
      case "Hindi":
        return "hi";
      case "French":
        return "fr";
      default:
        return "en";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Items')),
      body: Column(
        children: [
          // Language selector
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedLanguage,
              onChanged: (String? newLang) {
                setState(() {
                  selectedLanguage = newLang!;
                  translateItems(selectedLanguage);
                });
              },
              items: languages
                  .map(
                    (lang) => DropdownMenuItem(value: lang, child: Text(lang)),
                  )
                  .toList(),
            ),
          ),
          // Item list
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                String item = items[index];
                String displayText;
                if (selectedLanguage == "English") {
                  displayText = item;
                } else {
                  String langCode = targetLangCode(selectedLanguage);
                  displayText =
                      translatedItems[langCode]?[item] ?? "Translating...";
                }
                return ListTile(title: Text(displayText));
              },
            ),
          ),
        ],
      ),
    );
  }
}
