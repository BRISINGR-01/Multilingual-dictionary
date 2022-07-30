import 'package:flutter/material.dart';
import 'package:multilingual_dictionary/data.dart';
import 'package:multilingual_dictionary/displayWord.dart';
import 'package:multilingual_dictionary/downloadList.dart';

class SearchState extends State<Search> {
  DatabaseHelper databaseHelper = DatabaseHelper.init();

  bool isFirstTime = false;
  bool _isLoading = true;
  String _currentLanguage = "";
  String _query = "";
  bool _isModeToEnglish = true;
  List<String> _languages = [];
  List<Map<String, Object?>> _options = [];

  @override
  initState() {
    super.initState();

    getUserData(false).then((data) async {
      bool isModeToEnglish = data["isModeToEnglish"];
      String language = data["language"];
      List<String> languages = data["languages"];

      if (languages.isNotEmpty) {
        setState(() {
          _isModeToEnglish = isModeToEnglish;
          _currentLanguage = language;
          _languages = languages;
          _isLoading = false;
        });
      } else {
        languages = await databaseHelper.getLanguages();

        setState(() {
          _isModeToEnglish = isModeToEnglish;
          _currentLanguage = language.isNotEmpty
              ? language
              : languages.isNotEmpty
                  ? languages[0]
                  : "";
          _languages = languages;
          _isLoading = false;
          isFirstTime = languages.isEmpty;
        });

        if (languages.isNotEmpty) {
          setUserData(languages: languages, language: languages[0]);
        }
      }
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
        if (_languages.length == 1) _currentLanguage = _languages[0];
      });
    } else {
      setState(() {
        _query = '';
        _options = [];
        _languages.remove(removeLang);
        if (!_languages.contains(_currentLanguage)) {
          _currentLanguage = _languages.isNotEmpty ? _languages[0] : "";
        }
      });
    }

    setUserData(languages: _languages, language: _currentLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            // systemOverlayStyle: SystemUiOverlayStyle.light,
            title: _languages.isEmpty
                ? const Text("")
                : Text(_isModeToEnglish
                    ? '$_currentLanguage to English'
                    : 'English to $_currentLanguage'),
          ),
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
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              "Please download a language first",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ElevatedButton(
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
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                            width: 5,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary)))),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.download,
                                color: Theme.of(context).colorScheme.primary,
                                size: 50,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(mainAxisSize: MainAxisSize.max, children: [
                        Container(
                          color: Colors.white,
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
                                            _currentLanguage = val as String;
                                            setUserData(
                                                language: _currentLanguage);
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
                                        setUserData(
                                            isModeToEnglish: !_isModeToEnglish);
                                        setState(() {
                                          _isModeToEnglish = !_isModeToEnglish;
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
                                            _currentLanguage = val as String;
                                            setUserData(
                                                language: _currentLanguage);
                                            fetchOptions(_query);
                                          })
                                      : const Text(
                                          "English",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                ),
                              ]),
                        ),
                        Container(
                          color: Colors.white,
                          child: TextField(
                            autofocus: !isFirstTime,
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
                                    color: Colors.lightBlueAccent, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.lightBlueAccent, width: 2.0),
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
                                  title: Text(_options[index]["val"] as String),
                                  shape: const RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Colors.black38, width: .3),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(3)),
                                  ),
                                  onTap: () async {
                                    Map wordData = await databaseHelper.getById(
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
    );
  }
}

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  SearchState createState() => SearchState();
}
