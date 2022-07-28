import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/services.dart';

Future<Map<String, dynamic>> getJson() async {
  String rawJson = await rootBundle.loadString('lib/languagesData.json');

  return Map<String, dynamic>.from(json.decode(rawJson));
}

class DownloadLanguages extends StatefulWidget {
  final Function editLanguagesList;
  final List<String> downloadedLanguages;
  const DownloadLanguages(
      {super.key,
      required this.downloadedLanguages,
      required this.editLanguagesList});

  @override
  State<DownloadLanguages> createState() => _DownloadLanguagesState();
}

class _DownloadLanguagesState extends State<DownloadLanguages> {
  List<String> downloadedLanguages = [];
  List<String> loadingLanguages = [];

  download(String languageToDownload) async {
    setState(() {
      loadingLanguages = [...loadingLanguages, languageToDownload];
    });

    await Future.delayed(const Duration(seconds: 1));

    List<String> newLanguages = [...downloadedLanguages, languageToDownload];
    widget.editLanguagesList(newLanguages);

    setState(() {
      loadingLanguages =
          loadingLanguages.where((lang) => lang != languageToDownload).toList();
      downloadedLanguages = newLanguages;
    });
  }

  delete(String languageToDelete) async {
    setState(() {
      loadingLanguages = [...loadingLanguages, languageToDelete];
    });

    await Future.delayed(const Duration(seconds: 1));

    List<String> newLanguages =
        downloadedLanguages.where((lang) => lang != languageToDelete).toList();

    widget.editLanguagesList(newLanguages);
    setState(() {
      downloadedLanguages = newLanguages;
      loadingLanguages =
          loadingLanguages.where((lang) => lang != languageToDelete).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (downloadedLanguages.isEmpty && widget.downloadedLanguages.isNotEmpty) {
      setState(() {
        downloadedLanguages = widget.downloadedLanguages;
      });
    }

    return Scaffold(
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
                .map<Widget>((item) => data["availableFlags"].containsKey(item)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1),
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
                return ListTile(
                  title: Text(data["providedByKaikki"][index]),
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black38, width: .3),
                  ),
                  // leading: Image.asset('${flags[index]}'),
                  leading: flags[index],
                  trailing: loadingLanguages
                          .contains(data["providedByKaikki"][index])
                      ? OutlinedButton(
                          child: SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color:
                                      Theme.of(context).colorScheme.tertiary)),
                          onPressed: () => {},
                        )
                      : downloadedLanguages
                              .contains(data["providedByKaikki"][index])
                          ? OutlinedButton(
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                semanticLabel: 'delete',
                              ),
                              onPressed: () =>
                                  delete(data["providedByKaikki"][index]),
                            )
                          : OutlinedButton(
                              child: const Icon(
                                Icons.download,
                                color: Colors.blue,
                                semanticLabel: 'download',
                              ),
                              onPressed: () =>
                                  download(data["providedByKaikki"][index]),
                            ),
                );
              },
            );
          }),
    );
  }
}
