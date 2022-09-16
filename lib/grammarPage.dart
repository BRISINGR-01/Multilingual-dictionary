// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:multilingual_dictionary/data.dart';

Future<Map<String, Object?>> getData(
    DatabaseHelper databaseHelper, String language) async {
  return {
    "grammar": await databaseHelper.getGrammar(language),
    "languageData": await databaseHelper.getLanguageData()
  };
}

class GrammarPage extends StatefulWidget {
  final String language;
  final DatabaseHelper databaseHelper;
  const GrammarPage(
      {Key? key, required this.language, required this.databaseHelper})
      : super(key: key);

  @override
  State<GrammarPage> createState() => _GrammarPageState();
}

class _GrammarPageState extends State<GrammarPage> {
  String textLanguage = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: getData(widget.databaseHelper, widget.language),
        builder: ((context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null) {
            return const Text("No grammar");
          }

          Map<String, dynamic> data = snapshot.data as Map<String, dynamic>;
          List<String> availableLanguages = data["grammar"].keys.toList();

          if (textLanguage == "") {
            textLanguage = availableLanguages.contains(widget.language)
                ? widget.language
                : "English";
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.language),
              actions: availableLanguages
                  .map<Widget>((item) => Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: IconButton(
                        tooltip: item,
                        icon: data["languageData"]["availableFlags"]
                                .containsKey(item)
                            ? Image.asset(
                                'assets/flags/${data["languageData"]["availableFlags"][item]}.png')
                            : Text(item),
                        onPressed: () => setState(() {
                          textLanguage = item;
                        }),
                      )))
                  .toList(),
            ),
            body: ListView.builder(
              itemCount: data["grammar"][textLanguage]["articles"]?.length,
              itemBuilder: ((context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      data["grammar"][textLanguage]["articles"][index]["title"],
                      style: const TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    trailing: Text(data["grammar"][textLanguage]["articles"]
                            [index]["info"] ??
                        ""),
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.black38, width: .3),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GrammarSection(
                              title: data["grammar"][textLanguage]["articles"]
                                  [index]["title"],
                              text: List<String>.from(data["grammar"]
                                  [textLanguage]["articles"][index]["body"]),
                              language: widget.language,
                              databaseHelper: widget.databaseHelper,
                              tables: Map<String, List<dynamic>>.from(
                                  data["grammar"][textLanguage]["tables"]),
                            ),
                          ));
                    },
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}

class GrammarSection extends StatefulWidget {
  final String title;
  final String language;
  final List<String> text;
  final DatabaseHelper databaseHelper;
  final Map<String, List<dynamic>> tables;
  const GrammarSection({
    Key? key,
    required this.title,
    required this.language,
    required this.tables,
    required this.databaseHelper,
    required this.text,
  }) : super(key: key);

  @override
  State<GrammarSection> createState() => _GrammarSectionState();
}

class _GrammarSectionState extends State<GrammarSection> {
  List<TableRow> getTableRow(List rows, bool noHeader, context) {
    List<TableRow> tableRows = [];
    for (var i = 0; i < rows.length; i++) {
      bool isHeader = i == 0 && !noHeader;
      tableRows.add(TableRow(
          decoration: BoxDecoration(
              color: isHeader ? Theme.of(context).colorScheme.tertiary : null,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20))),
          children: rows[i]
              .map<Widget>((cell) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Text(
                      cell,
                      style: isHeader
                          ? const TextStyle(color: Colors.white)
                          : null,
                    ),
                  ))
              .toList()));
    }
    return tableRows.toList();
  }

  @override
  Widget build(BuildContext context) {
    String textLanguage = "";

    return SafeArea(
        child: FutureBuilder(
      future: getData(widget.databaseHelper, widget.language),
      builder: ((context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == null) {
          return const Text("No grammar");
        }

        Map<String, dynamic> data = snapshot.data as Map<String, dynamic>;
        List<String> availableLanguages = data["grammar"].keys.toList();

        if (textLanguage == "") {
          textLanguage = availableLanguages.contains(widget.language)
              ? widget.language
              : "English";
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: availableLanguages
                .map<Widget>((item) => CircleAvatar(
                      backgroundColor: item == textLanguage
                          ? Theme.of(context).colorScheme.primary
                          : const Color.fromARGB(0, 0, 0, 0),
                      child: IconButton(
                        tooltip: item,
                        icon: (data["languageData"]["availableFlags"]
                                .containsKey(item)
                            ? Container(
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1),
                                ),
                                child: Image.asset(
                                    'assets/flags/${data["languageData"]["availableFlags"][item]}.png'),
                              )
                            : Text(item)),
                        onPressed: () => setState(() {
                          textLanguage = item;
                        }),
                      ),
                    ))
                .toList(),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.only(bottom: 64),
            itemCount: widget.text.length,
            itemBuilder: ((context, index) {
              if (widget.text[index].startsWith("@table:")) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? 8
                          : 32,
                      vertical: 16),
                  child: Table(
                      border: TableBorder.all(
                          borderRadius: BorderRadius.circular(20)),
                      children: getTableRow(
                          widget.tables[widget.text[index]
                              .replaceFirst("@table:", "")] as List,
                          widget.tables["no-header"]!.contains(
                              widget.text[index].replaceFirst("@table:", "")),
                          context)),
                );
              } else if (widget.text[index].startsWith("h: ")) {
                return ListTile(
                  title: Text(
                    widget.text[index].replaceFirst("h: ", ""),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 25,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500),
                  ),
                );
              } else if (widget.text[index].startsWith("-")) {
                return ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      widget.text[index]
                          .replaceFirst("-", "\u2022 ")
                          .split(";")
                          .join("\n\u2022 "),
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                );
              }

              return ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    widget.text[index],
                  ),
                ),
              );
            }),
          ),
        );
      }),
    ));
  }
}
