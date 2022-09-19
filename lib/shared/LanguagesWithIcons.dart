// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:multilingual_dictionary/data.dart';
import 'package:multilingual_dictionary/shared/Loader.dart';

class LanguagesWithIcons extends StatelessWidget {
  final DatabaseHelper databaseHelper;
  final Function builder;
  const LanguagesWithIcons(
      {Key? key, required this.databaseHelper, required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: FutureBuilder(
            future: databaseHelper.getLanguageData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Loader();
              }

              Map<String, dynamic> data = snapshot.data as Map<String, dynamic>;

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

              return builder(flags, data);
            }));
  }
}
