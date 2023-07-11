import 'package:flutter/material.dart';
import 'package:multilingual_dictionary/grammar/noGrammar.dart';
import 'package:multilingual_dictionary/grammar/optionsPage.dart';
import 'package:multilingual_dictionary/shared/LanguagesWithIcons.dart';
import 'package:multilingual_dictionary/shared/data.dart';

class LanguageChooser extends StatelessWidget {
  final DatabaseHelper databaseHelper;
  final Map<String, dynamic> grammar;

  const LanguageChooser(
      {Key? key, required this.databaseHelper, required this.grammar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LanguagesWithIcons(
      databaseHelper: databaseHelper,
      builder: (flags, data) => Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: const Text("Grammar"),
          ),
          body: ListView.builder(
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
                        builder: (context) => grammar[language] == null
                            ? const NoGrammar()
                            : OptionsPage(
                                items: grammar[language],
                                title: language,
                              ),
                      )));
            },
          )),
    );
  }
}
