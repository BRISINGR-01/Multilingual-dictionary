import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future<List<String>> getJson() async {
  String rawJson = await rootBundle.loadString('lib/languagesKaikki.json');

  return List<String>.from(json.decode(rawJson));
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Languages'),
      ),
      body: FutureBuilder(
          future: getJson(),
          builder: (context, data) {
            if (!data.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            var items = data.data as List<String>;

            List<Widget> flags = items
                .map((item) => available.containsKey(item)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 0),
                        child: Image.asset(
                          'assets/flags/${available[item]}.png',
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.only(left: 7.5),
                        child: Icon(Icons.tour_outlined),
                      ))
                .toList();
            // List<dynamic> flags = items
            //     .map((item) => available.containsKey(item)
            //         ? 'assets/flags/${available[item]}.png'
            //         : 'assets/flags/bg.png')
            //     .toList();

            // print(items.map((i) => available[i]));

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index]),
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black38, width: .3),
                  ),
                  // leading: Image.asset('${flags[index]}'),
                  leading: flags[index],
                  trailing: OutlinedButton(
                    child: const Icon(
                      Icons.download,
                      color: Colors.blue,
                      semanticLabel: 'download',
                    ),
                    onPressed: () => print(items[index]),
                  ),
                );
              },
            );
          }),
    );
  }
}

var available = {
  "Spanish": "es",
  "Latin": "lat",
  "Italian": "it",
  "German": "de",
  "Russian": "ru",
  "French": "fr",
  "Portuguese": "pt",
  "Finnish": "fi",
  "Latvian": "lv",
  "Arabic": "ar",
  "Catalan": "ca",
  "Polish": "pl",
  "Dutch": "nl",
  "Swedish": "sv",
  "Romanian": "ro",
  "Hungarian": "hu",
  "Macedonian": "mk",
  "Bulgarian": "bg",
  "Galician": "gl",
  "Irish": "ga",
  "Vietnamese": "vi",
  "Turkish": "tr",
  "Lithuanian": "lt",
  "Icelandic": "is",
  "Tagalog": "tl",
  "Thai": "th",
  "Ido": "io",
  "Sanskrit": "sa",
  "Indonesian": "id",
  "Welsh": "cy",
  "Azerbaijani": "az",
  "Maltese": "mt",
  "Tamil": "ta",
  "Estonian": "et",
  "Central Khmer": "km",
  "Faroese": "fo",
  "Malayalam": "ml",
  "Luxembourgish": "lb",
  "Slovak": "sk",
  "Afrikaans": "af",
  "Basque": "eu",
  "Bengali": "bn",
  "Burmese": "my",
  "Northern Sami": "se",
  "Mongolian": "mn",
  "Assamese": "as",
  "Old Church Slavonic": "cu",
  "Bashkir": "ba",
  "Belarusian": "be",
  "Gujarati": "gu",
  "Malagasy": "mg",
  "Tibetan": "bo",
  "Marathi": "mr",
  "Punjabi": "pa",
  "Nepali": "ne",
  "Kyrgyz": "ky",
  "Zhuang": "za",
  "Uzbek": "uz",
  "Breton": "br",
  "Cornish": "kw",
  "Uyghur": "ug",
  "Tajik": "tg",
  "Marshallese": "mh",
  "Kannada": "kn",
  "Pashto": "ps",
  "Sardinian": "sc",
  "Kikuyu": "ki",
  "Haitian Creole": "ht",
  "Tatar": "tt",
  "Amharic": "am",
  "Chuvash": "cv",
  "Oromo": "om",
  "Corsican": "co",
  "Bambara": "bm",
  "Somali": "so",
  "Turkmen": "tk",
  "Ewe": "ee",
  "Sotho": "st",
  "Limburgish": "li",
  "Fijian": "fj",
};
