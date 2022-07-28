import 'package:flutter/material.dart';
import 'package:multilingual_dictionary/data.dart';
import 'package:multilingual_dictionary/displayWord.dart';
import 'package:multilingual_dictionary/downloadList.dart';

class SearchState extends State<Search> {
  DatabaseHelper databaseHelper = DatabaseHelper.init();

  bool _isLoading = true;
  String _language = "";
  String _querry = "";
  bool _isModeToEnglish = true;
  List<String> _languages = [];
  List<Map<String, Object?>> _options = [];

  @override
  initState() {
    super.initState();

    // setUserData(languages: []);
    getUserData().then((data) async {
      bool isModeToEnglish = data["isModeToEnglish"];
      String language = data["language"];
      List<String> languages = data["languages"];

      if (languages.isNotEmpty) {
        setState(() {
          _isModeToEnglish = isModeToEnglish;
          _language = language;
          _languages = languages;
          _isLoading = false;
        });
      } else {
        languages = await databaseHelper.getLanguages();

        setState(() {
          _isModeToEnglish = isModeToEnglish;
          _language = language.isNotEmpty
              ? language
              : languages.isNotEmpty
                  ? languages[0]
                  : "";
          _languages = languages;
          _isLoading = false;
        });

        if (languages.isNotEmpty) {
          setUserData(languages: languages, language: language[0]);
        }
      }
    });
  }

  fetchOptions() async {
    QueryResult items = _isModeToEnglish
        ? await databaseHelper.searchToEnglish(_querry, _language)
        : await databaseHelper.searchFromEnglish(_querry, _language);

    setState(() {
      _options = items;
    });
  }

  editLanguagesList(List<String> languages) {
    if (!languages.contains(_language)) {
      String? newCurrentLanguage = languages.isNotEmpty ? languages[0] : null;
      setUserData(language: newCurrentLanguage, languages: languages);
      setState(() {
        _language = newCurrentLanguage ?? "";
        _languages = languages;
      });
    } else {
      setUserData(languages: languages);
      setState(() {
        _languages = languages;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _languages.isEmpty
              ? const Text("")
              : Text(_isModeToEnglish
                  ? '$_language to English'
                  : 'English to $_language'),
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
                        editLanguagesList: editLanguagesList),
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
                                    editLanguagesList: editLanguagesList),
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
                                        value: _language,
                                        items: _languages
                                            .map((String items) =>
                                                DropdownMenuItem(
                                                  value: items,
                                                  child: Text(items),
                                                ))
                                            .toList(),
                                        underline: Container(),
                                        onChanged: (String? val) {
                                          _language = val as String;
                                          setUserData(language: _language);
                                          fetchOptions();
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
                                      fetchOptions();
                                    },
                                    child: const Icon(
                                      Icons.swap_horiz_outlined,
                                    )),
                              ),
                              Expanded(
                                child: !_isModeToEnglish
                                    ? DropdownButton(
                                        value: _language,
                                        items: _languages
                                            .map((String items) =>
                                                DropdownMenuItem(
                                                  value: items,
                                                  child: Text(items),
                                                ))
                                            .toList(),
                                        underline: Container(),
                                        onChanged: (String? val) {
                                          _language = val as String;
                                          setUserData(language: _language);
                                          fetchOptions();
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
                          autofocus: true,
                          onChanged: (value) async {
                            _querry = value;
                            fetchOptions();
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
                                      _options[index]["id"] as int, _language);

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
                  ));
  }
}

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  SearchState createState() => SearchState();
}
