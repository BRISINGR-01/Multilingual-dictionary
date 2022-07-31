// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:multilingual_dictionary/data.dart';

Future<Map<String, dynamic>> getJson() async {
  String rawJson = await rootBundle.loadString('lib/languagesData.json');

  return Map<String, dynamic>.from(json.decode(rawJson));
}

class DownloadLanguages extends StatefulWidget {
  final Function editLanguagesList;
  final List<String> downloadedLanguages;
  final DatabaseHelper databaseHelper;
  const DownloadLanguages(
      {super.key,
      required this.downloadedLanguages,
      required this.editLanguagesList,
      required this.databaseHelper});

  @override
  State<DownloadLanguages> createState() => _DownloadLanguagesState();
}

class _DownloadLanguagesState extends State<DownloadLanguages> {
  Map<String, Map<String, dynamic>> languagesData = {};

  download(String languageToDownload) async {
    setState(() {
      languagesData[languageToDownload]!["isLoading"] = true;
      languagesData[languageToDownload]!["size"] = 0;
    });

    void setProgressAndSize(num progress, int currentSize) {
      currentSize;
      setState(() {
        if (progress == 1) {
          // the download has finished and other processes are occuring
          // therefore a circular animation should appear
          languagesData[languageToDownload]!["progress"] = null;
          languagesData[languageToDownload]!["size"] = currentSize;
        } else {
          languagesData[languageToDownload]!["progress"] = progress;
          languagesData[languageToDownload]!["size"] = currentSize;
        }
      });
    }

    bool isSuccessful = await widget.databaseHelper
        .addLanguage(languageToDownload, setProgressAndSize);

    if (!isSuccessful) {
      return setState(() {
        languagesData[languageToDownload]!["isLoading"] = false;
        languagesData[languageToDownload]!["size"] = null;
      });
    }

    widget.editLanguagesList(addLang: languageToDownload);

    setState(() {
      languagesData[languageToDownload]!["isLoading"] = false;
      languagesData[languageToDownload]!["isDownloaded"] = true;
    });
  }

  delete(String languageToDelete) async {
    setState(() {
      languagesData[languageToDelete]!["isLoading"] = true;
      languagesData[languageToDelete]!["progress"] = null;
    });

    await widget.databaseHelper.deleteLanguage(languageToDelete);

    widget.editLanguagesList(removeLang: languageToDelete);

    widget.databaseHelper.setUserData(languageToDelete, "0");

    setState(() {
      languagesData[languageToDelete]!["isDownloaded"] = false;
      languagesData[languageToDelete]!["isLoading"] = false;
      languagesData[languageToDelete]!["size"] = null;
    });
  }

  @override
  void initState() {
    widget.databaseHelper.getUserData().then((data) => setState(() {
          data["languages"].forEach((lang) {
            int size = data[lang] == null ? 0 : int.parse(data[lang]);

            languagesData[lang] = {};
            languagesData[lang]!["size"] = size == 0 ? null : size;
            languagesData[lang]!["isDownloaded"] = true;
            // the provided size can be zero which means the databse was deleted
            // or null which means it was never downloaded
          });
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Languages'),
        ),
        body: FutureBuilder(
            future: getJson(),
            builder: (context, jsonData) {
              if (!jsonData.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              Map<String, dynamic> data = jsonData.data as Map<String, dynamic>;

              List<Widget> flags = data["providedByKaikki"]
                  .map<Widget>(
                      (item) => data["availableFlags"].containsKey(item)
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.black, width: 1),
                                ),
                                child: Image.asset(
                                  'assets/flags/${data["availableFlags"][item]}.png',
                                ),
                              ),
                            )
                          : const Padding(
                              padding: EdgeInsets.only(left: 7.5),
                              child: Icon(Icons.tour_outlined),
                            ))
                  .toList();

              return ListView.builder(
                itemCount: data["providedByKaikki"].length,
                itemBuilder: (context, index) {
                  String language = data["providedByKaikki"][index];

                  if (languagesData[language] == null) {
                    languagesData[language] = {};
                  }

                  return ListTile(
                    title: Text(language),
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.black38, width: .3),
                    ),
                    leading: flags[index],
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(languagesData[language]!["size"] != null
                            ? '${languagesData[language]!["size"]} Mb '
                            : ""),
                        languagesData[language]?["isLoading"] == true
                            ? OutlinedButton(
                                child: SizedBox(
                                    width: 15,
                                    height: 15,
                                    child:
                                        languagesData[language]!["progress"] !=
                                                null
                                            ? LinearProgressIndicator(
                                                value: languagesData[language]![
                                                    "progress"],
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .tertiary)
                                            : CircularProgressIndicator(
                                                strokeWidth: 3,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .tertiary)),
                                onPressed: () => {},
                              )
                            : languagesData[language]!["isDownloaded"] == true
                                ? OutlinedButton(
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      semanticLabel: 'delete',
                                    ),
                                    onPressed: () => delete(language),
                                  )
                                : OutlinedButton(
                                    child: Icon(
                                      Icons.download,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      semanticLabel: 'download',
                                    ),
                                    onPressed: () => download(language),
                                  ),
                      ],
                    ),
                  );
                },
              );
            }),
      ),
    );
  }
}
