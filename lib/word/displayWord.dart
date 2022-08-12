// ignore_for_file: file_names

import 'dart:convert' show json;
import 'package:flutter/material.dart';
// import 'package:multilingual_dictionary/ExpandableFab.dart';
import 'package:multilingual_dictionary/word/formsTable.dart';

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
    if (mounted && !isReadyToDraw) {
      setState(() {
        isReadyToDraw = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
            // ? const ExampleExpandableFab()
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: Word(
          word: widget.word,
          setReady: setReady,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
    );
  }
}

class Word extends StatelessWidget {
  const Word({
    Key? key,
    required this.word,
    required this.setReady,
  }) : super(key: key);

  final Map word;
  final Function setReady;

  @override
  Widget build(BuildContext context) {
    List<dynamic>? ipas =
        word["ipas"] == null ? null : json.decode(word["ipas"]);
    // List<dynamic>? tags = jsonDecode(word["tags"]);
    Future.delayed(const Duration(milliseconds: 00)).then((_) {
      setReady();
    });

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        height: constraints.maxHeight,
        width: constraints.maxWidth,
        color: Theme.of(context).colorScheme.background,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              minWidth: constraints.maxWidth,
              // maxHeight: constraints.maxHeight * 1.0,
              // maxWidth: constraints.maxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
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
                  // const Spacer(),
                  if (word["origin"] != null)
                    Text(word["origin"],
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                            fontFamily: "New Times Roman",
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none)),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
