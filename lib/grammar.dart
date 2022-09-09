import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multilingual_dictionary/data.dart';
import 'package:multilingual_dictionary/grammarPage.dart';

Future<Map<String, dynamic>> getJson() async {
  String rawJson = await rootBundle.loadString('assets/languagesData.json');

  return Map<String, dynamic>.from(json.decode(rawJson));
}

class Grammar extends StatelessWidget {
  final DatabaseHelper databaseHelper;

  const Grammar({Key? key, required this.databaseHelper}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return databaseHelper.languages.length > 1
        ? LanguageChooser(databaseHelper: databaseHelper)
        : databaseHelper.languages.length == 1
            ? GrammarPage(language: databaseHelper.languages.single)
            : const NoGrammar();
  }
}

class NoGrammar extends StatelessWidget {
  const NoGrammar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(80.0),
                child: Text(
                  textAlign: TextAlign.center,
                  "Downlaod a language",
                  style: TextStyle(
                    fontSize: 25.0,
                  ),
                ),
              ),
            )));
  }
}

class LanguageChooser extends StatelessWidget {
  final DatabaseHelper databaseHelper;

  const LanguageChooser({Key? key, required this.databaseHelper})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text("Grammar"),
        ),
        body: FutureBuilder(
            future: getJson(),
            builder: (context, jsonData) {
              if (!jsonData.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              Map<String, dynamic> data = jsonData.data as Map<String, dynamic>;

              Map flags = Map.fromEntries(
                List<MapEntry<String, Padding>>.from(data["providedByKaikki"]
                    .map((item) => MapEntry<String, Padding>(
                        item as String,
                        data["availableFlags"].containsKey(item)
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 1),
                                  ),
                                  child: Image.asset(
                                    'assets/flags/${data["availableFlags"][item]}.png',
                                  ),
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.only(left: 7.5),
                                child: Icon(Icons.tour_outlined),
                              )))),
              );

              return ListView.builder(
                itemCount: databaseHelper.languages.length,
                itemBuilder: (context, index) {
                  String language = databaseHelper.languages[index];
                  return ListTile(
                      title: Text(language),
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black38, width: .3),
                      ),
                      leading: flags[language],
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GrammarPage(
                              language: language,
                            ),
                          )));
                },
              );
            }),
      ),
    );
  }
}
