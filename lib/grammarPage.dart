// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:multilingual_dictionary/shared/data.dart';
import 'package:multilingual_dictionary/shared/Loader.dart';

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
            return const Loader();
          }

          if (snapshot.data == null) {
            return const Text("No grammar");
          }

          Map<String, dynamic> data = snapshot.data as Map<String, dynamic>;
          List<String> availableLanguages = data["grammar"].keys.toList();

          if (textLanguage == "") {
            textLanguage = availableLanguages.contains(widget.language)
                ? widget.language
                : availableLanguages.contains("Emglish")
                    ? "English"
                    : availableLanguages.first;
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(widget.language),
              // actions: availableLanguages
              //     .map<Widget>((language) => Padding(
              //         padding: const EdgeInsets.symmetric(horizontal: 5),
              //         child: CircleAvatar(
              //           backgroundColor: availableLanguages.length == 1
              //               ? null
              //               : textLanguage == language
              //                   ? Colors.white.withOpacity(.35)
              //                   : const Color(0x00000000),
              //           child: IconButton(
              //             tooltip: language,
              //             icon: data["languageData"]["availableFlags"]
              //                     .containsKey(language)
              //                 ? Image.asset(
              //                     'assets/flags/${data["languageData"]["availableFlags"][language]}.png')
              //                 : Text(language),
              //             onPressed: () => setState(() {
              //               textLanguage = language;
              //             }),
              //           ),
              //         )))
              //     .toList(),
              actions: [
                DropdownButton(
                    value: textLanguage,
                    underline: Container(),
                    items: availableLanguages
                        .map((language) => DropdownMenuItem(
                            value: language,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  !data["languageData"]["availableFlags"]
                                          .containsKey(language)
                                      ? Image.asset(
                                          'assets/flags/${data["languageData"]["availableFlags"][language]}.png',
                                          fit: BoxFit.contain,
                                          height: 20,
                                        )
                                      : Text(language)
                                ],
                              ),
                            )))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        textLanguage = val as String;
                      });
                    })
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ListView.builder(
                itemCount: data["grammar"][textLanguage]["articles"]?.length,
                itemBuilder: ((context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  width: 2))),
                      child: ListTile(
                        title: Text(
                          data["grammar"][textLanguage]["articles"][index]
                              ["title"],
                          style: const TextStyle(
                            fontSize: 30,
                          ),
                        ),
                        trailing: Text(data["grammar"][textLanguage]["articles"]
                                [index]["info"] ??
                            ""),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GrammarSection(
                                  title: data["grammar"][textLanguage]
                                      ["articles"][index]["title"],
                                  text: List<String>.from(data["grammar"]
                                          [textLanguage]["articles"][index]
                                      ["body"]),
                                  language: widget.language,
                                  databaseHelper: widget.databaseHelper,
                                  tables: Map<String, List<dynamic>>.from(
                                      data["grammar"][textLanguage]["tables"]),
                                ),
                              ));
                        },
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class GrammarSection extends StatelessWidget {
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
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(bottom: 64),
        itemCount: text.length,
        separatorBuilder: ((context, index) => text[index].startsWith("h: ")
            ? const Divider(indent: 24)
            : Container()),
        itemBuilder: ((context, index) {
          if (text[index].startsWith("@table:")) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Table(
                  border:
                      TableBorder.all(borderRadius: BorderRadius.circular(20)),
                  children: getTableRow(
                      tables[text[index].replaceFirst("@table:", "")] as List,
                      tables["no-header"]?.contains(
                              text[index].replaceFirst("@table:", "")) ??
                          false,
                      context)),
            );
          } else if (text[index].startsWith("h: ")) {
            return ListTile(
              title: Padding(
                padding: const EdgeInsets.fromLTRB(8, 24, 0, 0),
                child: Text(
                  text[index].replaceFirst("h: ", ""),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 25,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500),
                ),
              ),
            );
          } else if (text[index].startsWith("\$")) {
            return ListTile(
              title: Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(
                  text[index]
                      .replaceFirst("\$", "\u2022 ")
                      .split("|")
                      .join("\n\u2022 "),
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            );
          }

          return ListTile(
            title: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                text[index],
              ),
            ),
          );
        }),
      ),
    ));
  }
}
