// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multilingual_dictionary/data.dart';

Future<List<String>> getArticle(String articleName, String language) async {
  language = "Italian";
  String article =
      await rootBundle.loadString('assets/grammar/$language/$articleName.json');

  return List<String>.from(json.decode(article));
}

class GrammarPage extends StatelessWidget {
  final String language;
  final DatabaseHelper databaseHelper;
  const GrammarPage(
      {Key? key, required this.language, required this.databaseHelper})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(language)),
        body: FutureBuilder(
          future: databaseHelper.getGrammar(language),
          builder: ((context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data == null) {
              return const Text("No grammar");
            }

            Map<String, dynamic> data = snapshot.data as Map<String, dynamic>;

            return ListView.builder(
              itemCount: data["links"].length,
              itemBuilder: ((context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      data["links"][index]["title"],
                      style: const TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    trailing: Text(data["links"][index]["info"]),
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.black38, width: .3),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GrammarSection(
                              assetPath: data["links"][index]["file_name"],
                              assetName: data["links"][index]["title"],
                              language: language,
                              tables: Map<String, List<dynamic>>.from(
                                  data["tables"]),
                            ),
                          ));
                    },
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}

class GrammarSection extends StatelessWidget {
  final String assetName;
  final String assetPath;
  final String language;
  final Map<String, List<dynamic>> tables;
  const GrammarSection({
    Key? key,
    required this.assetName,
    required this.assetPath,
    required this.language,
    required this.tables,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(assetName),
        ),
        body: FutureBuilder(
          future: getArticle(assetPath, language),
          builder: ((context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            List<String> data = snapshot.data as List<String>;

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: ((context, index) {
                if (data[index].startsWith("@table:")) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Table(
                      border: TableBorder.all(),
                      children: tables[data[index].replaceFirst("@table:", "")]!
                          .map<TableRow>((row) => TableRow(
                              children: row
                                  .map<Widget>((cell) => Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(cell),
                                      ))
                                  .toList()))
                          .toList(),
                    ),
                  );
                } else if (data[index].startsWith("h: ")) {
                  return ListTile(
                    title: Text(
                      data[index].replaceFirst("h: ", ""),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  );
                } else if (data[index].startsWith("=")) {
                  return ListTile(
                    title: Text(
                      data[index].replaceFirst("=", "    - "),
                    ),
                  );
                }
                return ListTile(
                  title: Text(
                    data[index],
                  ),
                  // shape: const RoundedRectangleBorder(
                  //     side: BorderSide(color: Colors.black38, width: .3),
                  //     ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}
