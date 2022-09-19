// ignore_for_file: file_names

import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:multilingual_dictionary/data.dart';
import 'package:multilingual_dictionary/shared/Loader.dart';
import 'package:multilingual_dictionary/word/formsTable.dart';

Future<Map<String, dynamic>> getData(
    DatabaseHelper databaseHelper, String language, int id) async {
  List<String>? saved =
      await databaseHelper.collections.getWordCollections(language, id);

  return {
    "saved": saved == null ? [] : ["Collection-$language-All", ...saved],
    "wordData": await databaseHelper.getById(id, language)
  };
}

class WordDisplay extends StatefulWidget {
  final int id;
  final DatabaseHelper databaseHelper;
  final String language;
  const WordDisplay(
      {Key? key,
      required this.id,
      required this.databaseHelper,
      required this.language})
      : super(key: key);

  @override
  State<WordDisplay> createState() => _WordDisplayState();
}

class _WordDisplayState extends State<WordDisplay> {
  bool isReadyToDraw = false;
  bool areTablesOpened = false;
  List<String>? savedTo;

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
      child: FutureBuilder(
          future: getData(widget.databaseHelper, widget.language, widget.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Loader();
            }

            Map<String, dynamic> data = snapshot.data as Map<String, dynamic>;

            savedTo ??= List<String>.from(data["saved"]);

            return Scaffold(
              appBar: AppBar(
                title: Text(data["wordData"]["word"]),
                backgroundColor: Theme.of(context).colorScheme.primary,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                        tooltip: "Collections",
                        onPressed: () {
                          List collections = widget
                              .databaseHelper.collections.all
                              .where((element) =>
                                  element["language"] == widget.language)
                              .toList();
                          if (savedTo?.isEmpty ?? false) {
                            widget.databaseHelper.collections.addTo(
                                "Collection-${widget.language}-All",
                                data["wordData"],
                                widget.language,
                                savedTo!);
                            savedTo!.add("Collection-${widget.language}-All");
                            setState(() {});
                          }
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                    builder: (context, setDialogState) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    child: Container(
                                      constraints: const BoxConstraints(
                                          maxWidth: 3 * 30),
                                      child: GridView.count(
                                        shrinkWrap: true,
                                        primary: false,
                                        padding: const EdgeInsets.all(20),
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                        crossAxisCount: 3,
                                        children: collections
                                            .map((collection) => Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color: savedTo?.contains(
                                                                collection[
                                                                    "fullTitle"]) ??
                                                            false
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .tertiary
                                                        : null),
                                                alignment: Alignment.center,
                                                width: 30,
                                                height: 30,
                                                child: IconButton(
                                                  onPressed: () {
                                                    if (savedTo == null) return;

                                                    if (savedTo!.contains(
                                                        collection[
                                                            "fullTitle"])) {
                                                      widget.databaseHelper
                                                          .collections
                                                          .removeFrom(
                                                              collection[
                                                                  "fullTitle"],
                                                              data["wordData"],
                                                              widget.language,
                                                              savedTo);
                                                      if (collection[
                                                              "fullTitle"] ==
                                                          "Collection-${widget.language}-All") {
                                                        savedTo = [];
                                                      } else {
                                                        savedTo!.remove(
                                                            collection[
                                                                "fullTitle"]);
                                                      }
                                                    } else {
                                                      savedTo!.add(collection[
                                                          "fullTitle"]);
                                                      if (!savedTo!.contains(
                                                          "Collection-${widget.language}-All")) {
                                                        savedTo!.add(
                                                            "Collection-${widget.language}-All");
                                                      }
                                                      widget.databaseHelper
                                                          .collections
                                                          .addTo(
                                                              collection[
                                                                  "fullTitle"],
                                                              data["wordData"],
                                                              widget.language,
                                                              savedTo!);
                                                    }
                                                    setState(() {});
                                                    setDialogState(() {});
                                                  },
                                                  tooltip: collection["title"],
                                                  icon: collection["icon"] ==
                                                          null
                                                      ? Text(
                                                          collection["title"])
                                                      : Icon(IconData(
                                                          collection["icon"],
                                                          fontFamily:
                                                              "MaterialIcons")),
                                                )))
                                            .toList(),
                                      ),
                                    ),
                                  );
                                });
                              });
                        },
                        iconSize: 30,
                        icon: Icon(
                          savedTo?.isNotEmpty ?? false
                              ? Icons.bookmark
                              : Icons.bookmark_add_outlined,
                          color: savedTo?.isNotEmpty ?? false
                              ? Colors.yellow.shade600
                              : Colors.white,
                        )),
                  )
                ],
              ),
              bottomNavigationBar: BottomAppBar(
                shape: !isReadyToDraw || areTablesOpened
                    ? null
                    : const CircularNotchedRectangle(),
                color: Theme.of(context).colorScheme.tertiary,
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: areTablesOpened
                        ? MediaQuery.of(context).size.height
                        : 50,
                    padding: const EdgeInsets.only(top: 70),
                    child: areTablesOpened
                        ? FormsTable(
                            forms: data["wordData"]["forms"] ?? [],
                          )
                        : null),
              ),
              floatingActionButton: isReadyToDraw
                  ? Padding(
                      padding:
                          EdgeInsets.only(top: areTablesOpened ? 80.0 : 0.0),
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
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              body: WillPopScope(
                onWillPop: () {
                  Navigator.pop(context,
                      json.encode(savedTo)); //return data along with pop
                  return Future(() => false);
                },
                child: Word(
                  word: data["wordData"],
                  setReady: setReady,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.background,
            );
          }),
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
                            fontFamily: "Times Roman",
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
