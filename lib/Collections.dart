// ignore_for_file: file_names

import 'dart:convert';

import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:multilingual_dictionary/shared/data.dart';
import 'package:multilingual_dictionary/shared/LanguagesWithIcons.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:multilingual_dictionary/shared/Loader.dart';
import 'package:multilingual_dictionary/word/displayWord.dart';

class CollectionsHome extends StatelessWidget {
  final DatabaseHelper databaseHelper;
  const CollectionsHome({Key? key, required this.databaseHelper})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LanguagesWithIcons(
        databaseHelper: databaseHelper,
        builder: (flags, data) => Scaffold(
            appBar: AppBar(
              title: const Text("Collections"),
            ),
            body: databaseHelper.languages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(80),
                      child: Text(
                        "Download a language",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: databaseHelper.languages.length,
                    itemBuilder: ((context, index) {
                      return ListTile(
                        title: Text(databaseHelper.languages[index]),
                        leading: flags[databaseHelper.languages[index]],
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CollectionsList(
                                databaseHelper: databaseHelper,
                                language: databaseHelper.languages[index],
                              ),
                            )),
                      );
                    }))));
  }
}

class CollectionsList extends StatefulWidget {
  final DatabaseHelper databaseHelper;
  final String language;
  const CollectionsList(
      {Key? key, required this.databaseHelper, required this.language})
      : super(key: key);

  @override
  State<CollectionsList> createState() => _CollectionsListState();
}

class _CollectionsListState extends State<CollectionsList> {
  List<Map<String, dynamic>> collections = [];
  late Map<String, int?> collectionsIcons;
  final TextEditingController _textFieldController = TextEditingController();
  int? _icon;

  @override
  void initState() {
    super.initState();
    collectionsIcons = {
      for (var v in widget.databaseHelper.collections.all) v["title"]: v["icon"]
    };
    collections = widget.databaseHelper.collections.all
        .where((collection) => collection["language"] == widget.language)
        .toList();
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              content: TextField(
                controller: _textFieldController,
                autofocus: true,
                decoration: const InputDecoration(hintText: "Collection Name"),
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: <Widget>[
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.tertiary)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _icon != null
                        ? Icon(IconData(_icon!, fontFamily: "MaterialIcons"))
                        : const Icon(Icons.emoji_emotions_outlined),
                  ),
                  onPressed: () {
                    FlutterIconPicker.showIconPicker(context,
                        iconPackModes: [IconPack.material]).then((val) {
                      setState(() {
                        _icon = val?.codePoint;
                      });
                      setDialogState(() {
                        _icon = val?.codePoint;
                      });
                    });
                  },
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green)),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Add"),
                  ),
                  onPressed: () {
                    String title = _textFieldController.text;
                    if (title.isNotEmpty &&
                        collections.every(
                            (collection) => collection["title"] != title)) {
                      Map<String, dynamic> newCollection = {
                        "fullTitle": "Collection-${widget.language}-$title",
                        "title": title,
                        "language": widget.language,
                        "icon": _icon,
                      };
                      setState(() {
                        if (_icon != null) {
                          collectionsIcons[title] = _icon!;
                        }
                        widget.databaseHelper.collections.add(newCollection);
                        collections.add(newCollection);
                      });
                    }
                    _icon = null;
                    _textFieldController.clear();
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red)),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Cancel"),
                  ),
                  onPressed: () {
                    _icon = null;
                    _textFieldController.clear();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(widget.language),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayDialog(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
          itemCount: collections.length,
          itemBuilder: ((context, index) {
            return ListTile(
              horizontalTitleGap: 0,
              leading: collections[index]["icon"] != null
                  ? Icon(IconData(collections[index]["icon"]!,
                      fontFamily: "MaterialIcons"))
                  : null,
              title: Text(collections[index]["title"]),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Collection(
                      databaseHelper: widget.databaseHelper,
                      name: collections[index]["fullTitle"],
                      language: widget.language,
                      icon: collections[index]["icon"],
                      deleteCollection: () => setState(() {
                        widget.databaseHelper.collections
                            .delete(collections[index]["fullTitle"]);

                        collections.removeAt(index);
                      }),
                    ),
                  )),
            );
          })),
    ));
  }
}

class Collection extends StatefulWidget {
  final DatabaseHelper databaseHelper;
  final String name;
  final String language;
  final Function deleteCollection;
  final int? icon;
  const Collection({
    Key? key,
    required this.databaseHelper,
    required this.name,
    required this.icon,
    required this.language,
    required this.deleteCollection,
  }) : super(key: key);

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  List<Map<String, dynamic>>? words;
  List<int>? order;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    widget.databaseHelper.collections.getWords(widget.name).then((value) {
      if (mounted) {
        setState(() {
          order = List<int>.from(value["order"]!.toList());
          words = List<Map<String, dynamic>>.from(value["words"]!.toList());
          words = order!
              .map((id) => words!.firstWhere((word) => word["id"] == id))
              .toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (words == null) return const Loader();

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  horizontalTitleGap: 0,
                  leading: widget.icon != null
                      ? Icon(
                          IconData(widget.icon!, fontFamily: "MaterialIcons"),
                          color: Colors.white,
                        )
                      : null,
                  title: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.name.replaceFirst(RegExp(r"Collection-\w+-"), ""),
                      style: const TextStyle(
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                          fontSize: 30),
                    ),
                  )),
              actions: [
                if (widget.name != "Collection-${widget.language}-All" &&
                    isEditing)
                  IconButton(
                      onPressed: () {
                        widget.deleteCollection();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete)),
                IconButton(
                    onPressed: () {
                      setState(() {
                        isEditing = !isEditing;
                      });
                    },
                    icon: Icon(isEditing ? Icons.done : Icons.settings))
              ],
            ),
            body: words!.isEmpty
                ? Center(
                    child: Padding(
                    padding: const EdgeInsets.all(80),
                    child: Text(
                      "No words saved here!",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ))
                : DragAndDropLists(
                    children: [
                      DragAndDropList(
                          children: List.generate(
                        words!.length,
                        (index) => DragAndDropItem(
                            child: ListTile(
                          title: Text(words![index]["display"]),
                          onTap: isEditing
                              ? null
                              : () async {
                                  String returnData = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WordDisplay(
                                          id: words![index]["id"],
                                          databaseHelper: widget.databaseHelper,
                                          language: widget.language,
                                        ),
                                      ));

                                  if (!json
                                      .decode(returnData)
                                      .contains(widget.name)) {
                                    setState(() {
                                      words!.removeAt(index);
                                    });
                                  }
                                },
                        )),
                      ))
                    ],
                    onItemReorder: (int oldItemIndex, int oldListIndex,
                        int newItemIndex, int newListIndex) {
                      setState(() {
                        var movedItem = words!.removeAt(oldItemIndex);
                        words!.insert(newItemIndex, movedItem);
                      });
                      widget.databaseHelper.collections.setOrder(widget.name,
                          words!.map((word) => word["id"] as int).toList());
                    },
                    onListReorder: (_, __) {},
                    listPadding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    itemDivider: const Divider(
                      thickness: 2,
                      height: 2,
                    ),
                    itemDecorationWhileDragging: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 3,
                          offset:
                              const Offset(0, 0), // changes position of shadow
                        ),
                      ],
                    ),
                    listInnerDecoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0)),
                    ),
                    lastItemTargetHeight: 8,
                    addLastItemTargetHeightToTop: true,
                    lastListTargetSize: 40,
                    itemDragHandle: isEditing
                        ? const DragHandle(
                            child: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.menu,
                                color: Colors.blueGrey,
                              ),
                            ),
                          )
                        : null,
                  )));
  }
}
