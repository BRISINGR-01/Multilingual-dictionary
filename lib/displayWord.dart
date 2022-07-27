// ignore_for_file: file_names

import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:multilingual_dictionary/formsTable.dart';

class WordDisplay extends StatefulWidget {
  final Map word;
  const WordDisplay({Key? key, required this.word}) : super(key: key);

  @override
  State<WordDisplay> createState() => _WordDisplayState();
}

class _WordDisplayState extends State<WordDisplay> {
  bool isReadyToDraw = false;
  bool areTablesOpened = false;
  void setReady() {
    setState(() {
      isReadyToDraw = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.word["word"]),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: !isReadyToDraw || areTablesOpened
            ? null
            : const CircularNotchedRectangle(),
        color: Theme.of(context).colorScheme.tertiary,
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: areTablesOpened ? MediaQuery.of(context).size.height : 50,
            padding: const EdgeInsets.only(top: 70),
            child: areTablesOpened
                ? FormsTable(
                    forms: widget.word["forms"] ?? [],
                  )
                : null),
      ),
      floatingActionButton: isReadyToDraw
          ? Padding(
              padding: EdgeInsets.only(top: areTablesOpened ? 80.0 : 0.0),
              child: FloatingActionButton(
                onPressed: () => setState(() {
                  areTablesOpened = !areTablesOpened;
                }),
                tooltip: areTablesOpened ? null : 'Tables of forms',
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                    areTablesOpened
                        ? Icons.expand_more_outlined
                        : Icons.grid_on_outlined,
                    color: Theme.of(context).colorScheme.onPrimary),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Word(word: widget.word, setReady: setReady),
      backgroundColor: Theme.of(context).colorScheme.background,
    );
  }
}

class Word extends StatelessWidget {
  const Word({Key? key, required this.word, required this.setReady})
      : super(key: key);

  final Map word;
  final Function setReady;

  @override
  Widget build(BuildContext context) {
    List<dynamic>? ipas =
        word["ipas"] == null ? null : json.decode(word["ipas"]);
    // List<dynamic>? tags = jsonDecode(word["tags"]);
    Future.delayed(const Duration(milliseconds: 400)).then((_) {
      setReady();
    });

    return Container(
      height: MediaQuery.of(context).size.height - 107.5,
      width: MediaQuery.of(context).size.width,
      color: Theme.of(context).colorScheme.background,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  word["display"],
                  style: TextStyle(
                      fontSize: 40,
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none),
                ),
                if (ipas != null)
                  Text("/$ipas/",
                      style: TextStyle(
                          fontSize: 30,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none)),
                Text(
                  word["senses"],
                  style: TextStyle(
                      fontSize: 30,
                      color: Theme.of(context).colorScheme.onBackground,
                      decoration: TextDecoration.none),
                )
              ]),
              if (word["origin"] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 25.0),
                  child: Text(word["origin"],
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                          fontFamily: "New Times Roman",
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
