import 'package:flutter/material.dart';
import 'package:multilingual_dictionary/grammar/languageChooser.dart';
import 'package:multilingual_dictionary/grammar/noGrammar.dart';
import 'package:multilingual_dictionary/grammar/optionsPage.dart';
import 'package:multilingual_dictionary/shared/Loader.dart';
import 'package:multilingual_dictionary/shared/data.dart';

class Grammar extends StatelessWidget {
  final DatabaseHelper databaseHelper;

  const Grammar({Key? key, required this.databaseHelper}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: databaseHelper.getGrammar(),
        builder: ((context, snapshot) {
          if (!snapshot.hasData) {
            return const Loader();
          }

          if (snapshot.data == null) {
            return const NoGrammar();
          }

          Map<String, dynamic> grammar = snapshot.data as Map<String, dynamic>;

          return databaseHelper.languages.length > 1
              ? LanguageChooser(
                  databaseHelper: databaseHelper,
                  grammar: grammar,
                )
              : databaseHelper.languages.length == 1
                  ? OptionsPage(
                      items: grammar[databaseHelper.languages.first],
                      title: databaseHelper.languages.first,
                    )
                  : const NoGrammar();
        }),
      ),
    );
  }
}
