// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<Map<String, dynamic>> getJson(String language) async {
  String links =
      await rootBundle.loadString('assets/grammar/$language/home.json');
  String tables =
      await rootBundle.loadString('assets/grammar/$language/tables.json');
  String examples =
      await rootBundle.loadString('assets/grammar/$language/examples.json');

  return {
    "links": json.decode(links),
    "tables": json.decode(tables),
    "examples": json.decode(examples)
  };
}

Future<List<String>> getArticle(String articleName, String language) async {
  String article =
      await rootBundle.loadString('assets/grammar/$language/$articleName.json');

  print(article);

  return List<String>.from(json.decode(article));
}

class GrammarPage extends StatelessWidget {
  final String language;
  const GrammarPage({Key? key, required this.language}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(language)),
        body: FutureBuilder(
          future: getJson(language),
          builder: ((context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            Map<String, dynamic> data = snapshot.data as Map<String, dynamic>;
            print(data);

            return ListView.builder(
              itemCount: data["links"].length,
              itemBuilder: ((context, index) {
                return ListTile(
                  title: Text(
                    data["links"][index]["title"],
                    style: Theme.of(context).textTheme.displaySmall,
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
                            assetPath: data["links"][index]["asset"],
                            assetName: data["links"][index]["title"],
                            language: language,
                            tables:
                                Map<String, List<dynamic>>.from(data["tables"]),
                            examples: Map<String, List<dynamic>>.from(
                                data["examples"]),
                          ),
                        ));
                  },
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
  final Map<String, List<dynamic>> examples;
  const GrammarSection({
    Key? key,
    required this.assetName,
    required this.assetPath,
    required this.language,
    required this.tables,
    required this.examples,
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
                } else if (data[index].startsWith("@ex:")) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Table(
                      border: TableBorder.all(),
                      children: examples[data[index].replaceFirst("@ex:", "")]!
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
                    // shape: const RoundedRectangleBorder(
                    //     side: BorderSide(color: Colors.black38, width: .3),
                    //     ),
                  );
                } else if (data[index].startsWith("=")) {
                  return ListTile(
                    title: Text(
                      data[index].replaceFirst("=", "    - "),
                    ),
                    // shape: const RoundedRectangleBorder(
                    //     side: BorderSide(color: Colors.black38, width: .3),
                    //     ),
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
