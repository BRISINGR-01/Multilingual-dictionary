import 'package:flutter/material.dart';

class NoGrammar extends StatelessWidget {
  final bool hasNoLanguages;
  const NoGrammar({Key? key, this.hasNoLanguages = false}) : super(key: key);

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
                  hasNoLanguages
                      ? "Downlaod a language"
                      : "No grammar is available",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            )));
  }
}
