import 'package:flutter/material.dart';
import 'package:multilingual_dictionary/data.dart';
import 'package:multilingual_dictionary/displayWord.dart';
import 'package:multilingual_dictionary/downloadList.dart';

class SearchState extends State<Search> {
  DatabaseHelper databaseHelper = DatabaseHelper.init();
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  bool shouldAutoFocus = true;
  bool _isLoading = true;
  String _currentLanguage = "";
  String _query = "";
  bool _isModeToEnglish = true;
  List<String> _languages = [];
  List<Map<String, Object?>> _options = [];

  @override
  initState() {
    super.initState();

    databaseHelper.getUserData().then((data) async {
      String currentLanguage = data["currentLanguage"] ?? "";
      List<String> languages = data["languages"];

      if (!languages.contains(currentLanguage) && languages.isNotEmpty) {
        currentLanguage = languages[0];
      }

      setState(() {
        _languages = languages;
        _currentLanguage = currentLanguage;
        _isModeToEnglish = data["isModeToEnglish"] != "false";
        _isLoading = false;
      });
    });
  }

  fetchOptions(String querry) async {
    QueryResult items = _isModeToEnglish
        ? await databaseHelper.searchToEnglish(querry, _currentLanguage)
        : await databaseHelper.searchFromEnglish(querry, _currentLanguage);

    setState(() {
      _options = items;
    });
  }

  editLanguagesList({String? addLang, String? removeLang}) {
    if (addLang != null) {
      setState(() {
        _languages.add(addLang);

        if (_languages.length == 1) {
          _currentLanguage = _languages[0];
          databaseHelper.setUserData("currentLanguage", _currentLanguage);
        }
      });
    } else {
      setState(() {
        _query = '';
        _options = [];
        _languages.remove(removeLang);

        if (!_languages.contains(_currentLanguage)) {
          _currentLanguage = _languages.isNotEmpty ? _languages[0] : "";
          databaseHelper.setUserData("currentLanguage", _currentLanguage);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          title: _languages.isEmpty
              ? const Text("")
              : Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _isModeToEnglish
                          ? '$_currentLanguage to English'
                          : 'English to $_currentLanguage',
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
        ),
        body: Scaffold(
            key: _key,
            drawer: Drawer(
                child: ListView(padding: EdgeInsets.zero, children: [
              // ListTile(
              //   title: const Text('Settings'),
              //   leading: Icon(Icons.settings,
              //       color: Theme.of(context).colorScheme.tertiary),
              //   shape: const RoundedRectangleBorder(
              //     side: BorderSide(color: Colors.black38, width: .3),
              //   ),
              //   onTap: () {},
              // ),
              ListTile(
                title: const Text('Download Languages'),
                leading: Icon(Icons.download,
                    color: Theme.of(context).colorScheme.primary),
                shape: const RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black38, width: .3),
                ),
                onTap: () {
                  setState(() {
                    shouldAutoFocus = false;
                  });
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DownloadLanguages(
                          downloadedLanguages: _languages,
                          editLanguagesList: editLanguagesList,
                          databaseHelper: databaseHelper,
                        ),
                      ));
                },
              ),
            ])),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _languages.isEmpty
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
                                        downloadedLanguages: _languages,
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
                        padding: const EdgeInsets.all(8),
                        child:
                            Column(mainAxisSize: MainAxisSize.max, children: [
                          Container(
                            color: Theme.of(context).colorScheme.background,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 4),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: _isModeToEnglish
                                          ? DropdownButton(
                                              value: _currentLanguage,
                                              items: _languages
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
                                                databaseHelper.setUserData(
                                                    "currentLanguage", val);
                                                fetchOptions(_query);
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
                                            databaseHelper.setUserData(
                                                "isModeToEnglish",
                                                "${!_isModeToEnglish}");
                                            setState(() {
                                              _isModeToEnglish =
                                                  !_isModeToEnglish;
                                            });
                                            fetchOptions(_query);
                                          },
                                          child: const Icon(
                                            Icons.swap_horiz_outlined,
                                          )),
                                    ),
                                    Expanded(
                                      child: !_isModeToEnglish
                                          ? DropdownButton(
                                              value: _currentLanguage,
                                              items: _languages
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
                                                databaseHelper.setUserData(
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
                                      Map wordData =
                                          await databaseHelper.getById(
                                              _options[index]["id"] as int,
                                              _currentLanguage);

                                      if (!mounted) return;

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                WordDisplay(word: wordData),
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

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  SearchState createState() => SearchState();
}
