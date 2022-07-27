import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/services.dart';

class DownloadLanguages extends StatefulWidget {
  const DownloadLanguages({super.key});

  @override
  State<DownloadLanguages> createState() => _DownloadLanguagesState();
}

Future<Map<String, dynamic>> getJson() async {
  String rawJson = await rootBundle.loadString('lib/languagesData.json');

  return Map<String, dynamic>.from(json.decode(rawJson));
}

class _DownloadLanguagesState extends State<DownloadLanguages> {
  @override
  Widget build(BuildContext context) {
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

            print(data["providedByKaikki"]
                // .where((d) => !data["availableFlags"].containsKey(d))
                .toList()
                .length);

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
                  trailing: OutlinedButton(
                    child: const Icon(
                      Icons.download,
                      color: Colors.blue,
                      semanticLabel: 'download',
                    ),
                    onPressed: () => {},
                  ),
                );
              },
            );
          }),
    );
  }
}
