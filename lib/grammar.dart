import 'package:flutter/material.dart';
import 'package:multilingual_dictionary/shared/data.dart';
import 'package:multilingual_dictionary/grammarPage.dart';
import 'package:multilingual_dictionary/shared/LanguagesWithIcons.dart';

class Grammar extends StatelessWidget {
  final DatabaseHelper databaseHelper;

  const Grammar({Key? key, required this.databaseHelper}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return databaseHelper.languages.length > 1
        ? LanguageChooser(databaseHelper: databaseHelper)
        : databaseHelper.languages.length == 1
            ? GrammarPage(
                language: databaseHelper.languages.single,
                databaseHelper: databaseHelper,
              )
            : const NoGrammar();
  }
}

class NoGrammar extends StatelessWidget {
  const NoGrammar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(80.0),
                child: Text(
                  textAlign: TextAlign.center,
                  "Downlaod a language",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            )));
  }
}

class LanguageChooser extends StatelessWidget {
  final DatabaseHelper databaseHelper;

  const LanguageChooser({Key? key, required this.databaseHelper})
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
                        builder: (context) => GrammarPage(
                          language: language,
                          databaseHelper: databaseHelper,
                        ),
                      )));
            },
          )),
    );
  }
}
