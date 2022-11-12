import 'package:flutter/material.dart';
import 'package:multilingual_dictionary/Drawer.dart';
import 'package:multilingual_dictionary/notificationservice.dart';
import 'package:multilingual_dictionary/shared/data.dart';
import 'package:multilingual_dictionary/shared/Loader.dart';
import 'package:multilingual_dictionary/shared/utilities.dart';
import 'package:multilingual_dictionary/word/displayWord.dart';
import 'package:multilingual_dictionary/downloadList.dart';

class Search extends StatefulWidget {
  final String query;
  final String? language;
  const Search({super.key, this.query = "", this.language});

  @override
  SearchState createState() => SearchState();
}

class SearchState extends State<Search> {
  DatabaseHelper databaseHelper = DatabaseHelper.init();
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  bool shouldAutoFocus = true;
  bool _isLoading = true;
  TextEditingController controller = TextEditingController();
  String _currentLanguage = "";
  String _query = "";
  Mode _mode = Mode.toEnglish;
  List<Map<String, Object?>> _options = [];
  late FocusNode searchFieldFocusNode;

  @override
  initState() {
    super.initState();
    searchFieldFocusNode = FocusNode();

    databaseHelper.ensureInitialized().then((_) async {
      String currentLanguage =
          widget.language ?? databaseHelper.userData.currentLanguage;

      // databaseHelper.getNotificationWord(fromCollections: false)!.then((value) {
      // print(value);
      // NotificationService().showNotification(value["word"], value["display"]);
      // });

      controller.text = widget.query;

      setState(() {
        _currentLanguage = currentLanguage;
        _mode = databaseHelper.userData.mode;
        _isLoading = false;
        _query = widget.query;
      });
      if (widget.query.isNotEmpty) {
        fetchOptions(widget.query);
      }
    });
  }

  fetchOptions(String querry) async {
    QueryResultSet items = _mode == Mode.toEnglish
        ? await databaseHelper.searchToEnglish(querry, _currentLanguage)
        : await databaseHelper.searchFromEnglish(querry, _currentLanguage);

    setState(() {
      _options = items;
    });
  }

  editLanguagesList({String? addLang, String? removeLang}) {
    if (addLang != null) {
      setState(() {
        databaseHelper.languages.add(addLang);

        if (databaseHelper.languages.length == 1) {
          _currentLanguage = databaseHelper.languages[0];
          databaseHelper.userData.set("currentLanguage", _currentLanguage);
        }
      });
    } else {
      setState(() {
        _query = '';
        _options = [];
        databaseHelper.languages.remove(removeLang);

        if (!databaseHelper.languages.contains(_currentLanguage)) {
          _currentLanguage = databaseHelper.languages.isNotEmpty
              ? databaseHelper.languages[0]
              : "";
          databaseHelper.userData.set("currentLanguage", _currentLanguage);
        }
      });
    }
  }

  @override
  void dispose() {
    searchFieldFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!databaseHelper.isInitialized) {
      return const Loader();
    }

    return SafeArea(
      child: Scaffold(
        primary: true,
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.dehaze),
              onPressed: () {
                if (_key.currentState!.isDrawerOpen == false) {
                  _key.currentState!.openDrawer();
                } else {
                  _key.currentState!.openEndDrawer();
                }
              }),
          title: databaseHelper.languages.isEmpty
              ? const Text("")
              : Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _mode == Mode.toEnglish
                          ? '$_currentLanguage to English'
                          : 'English to $_currentLanguage',
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
        ),
        body: Scaffold(
            key: _key,
            drawer: CustomDrawer(
                databaseHelper: databaseHelper,
                editLanguagesList: editLanguagesList),
            body: _isLoading
                ? const Loader()
                : databaseHelper.languages.isEmpty
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(.5),
                                    blurRadius: 4,
                                    offset: const Offset(3.5, 6.5),
                                  )
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DownloadLanguages(
                                        downloadedLanguages:
                                            databaseHelper.languages,
                                        editLanguagesList: editLanguagesList,
                                        databaseHelper: databaseHelper,
                                      ),
                                    )),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).colorScheme.background),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          side: BorderSide(
                                              width: 5,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary))),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.download,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 50,
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                "Download a language",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child:
                            Column(mainAxisSize: MainAxisSize.max, children: [
                          Container(
                            color: Theme.of(context).colorScheme.background,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 8, 0, 4),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: _mode == Mode.toEnglish
                                          ? DropdownButton(
                                              value: _currentLanguage,
                                              items: databaseHelper.languages
                                                  .map((String items) =>
                                                      DropdownMenuItem(
                                                        value: items,
                                                        child: Text(items),
                                                      ))
                                                  .toList(),
                                              underline: Container(),
                                              onChanged: (String? val) {
                                                _currentLanguage =
                                                    val as String;
                                                databaseHelper.userData.set(
                                                    "currentLanguage", val);
                                                fetchOptions(_query);
                                                searchFieldFocusNode
                                                    .requestFocus();
                                              })
                                          : const Text(
                                              "English",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      child: ElevatedButton(
                                          onPressed: () {
                                            databaseHelper.userData.set(
                                                "mode",
                                                _mode == Mode.toEnglish
                                                    ? "toEnglish"
                                                    : "fromEnglish");
                                            setState(() {
                                              _mode = _mode == Mode.toEnglish
                                                  ? Mode.fromEnglish
                                                  : Mode.toEnglish;
                                            });
                                            fetchOptions(_query);
                                          },
                                          child: const Icon(
                                            Icons.swap_horiz_outlined,
                                          )),
                                    ),
                                    Expanded(
                                      child: _mode == Mode.fromEnglish
                                          ? DropdownButton(
                                              value: _currentLanguage,
                                              items: databaseHelper.languages
                                                  .map((String items) =>
                                                      DropdownMenuItem(
                                                        value: items,
                                                        child: Text(items),
                                                      ))
                                                  .toList(),
                                              underline: Container(),
                                              onChanged: (String? val) {
                                                _currentLanguage =
                                                    val as String;
                                                databaseHelper.userData.set(
                                                    "currentLanguage", val);
                                                fetchOptions(_query);
                                              })
                                          : const Text(
                                              "English",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                    ),
                                  ]),
                            ),
                          ),
                          Container(
                            color: Colors.white,
                            child: TextField(
                              controller: controller,
                              focusNode: searchFieldFocusNode,
                              autofocus: shouldAutoFocus,
                              onChanged: (value) async {
                                setState(() {
                                  _query = value;
                                });
                                fetchOptions(_query);
                              },
                              decoration: const InputDecoration(
                                hintText: 'Search',
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.lightBlueAccent,
                                      width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.lightBlueAccent,
                                      width: 2.0),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: _options.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title:
                                        Text(_options[index]["val"] as String),
                                    shape: const RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.black38, width: .3),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(3)),
                                    ),
                                    onTap: () async {
                                      controller.clear();
                                      int id = _options[index]["id"] as int;
                                      setState(() {
                                        _options = [];
                                        _query = "";
                                      });

                                      if (!mounted) return;

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => WordDisplay(
                                                id: id,
                                                language: _currentLanguage,
                                                databaseHelper: databaseHelper),
                                          ));
                                    },
                                  );
                                }),
                          ),
                        ]),
                      )),
      ),
    );
  }
}
