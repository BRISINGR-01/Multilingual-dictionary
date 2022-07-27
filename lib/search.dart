import 'package:flutter/material.dart';
import 'package:multilingual_dictionary/data.dart';
import 'package:multilingual_dictionary/displayWord.dart';
import 'package:multilingual_dictionary/download.dart';

class SearchState extends State<Search> {
  DatabaseHelper databaseHelper = DatabaseHelper.init();

  String _language = "French";
  String _querry = "";
  bool _isModeToEnglish = true;
  List<String> _languages = ["French", "Dutch"];
  List<Map<String, Object?>> _items = [];

  @override
  initState() {
    super.initState();
    getLastUserActivity().then((value) => setState(() {
          _language = value["language"];
          _isModeToEnglish = value["isModeToEnglish"];
        }));
  }

  fetchList() async {
    QueryResult items = _isModeToEnglish
        ? await databaseHelper.searchToEnglish(_querry, _language)
        : await databaseHelper.searchFromEnglish(_querry, _language);

    setState(() {
      _items = items;
    });
  }

  addLanguage(newLang) {
    setState(() {
      _languages = [..._languages, newLang];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_isModeToEnglish
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
                    builder: (context) => const DownloadLanguages(),
                  ));
            },
          ),
        ])),
        body: Padding(
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
                                  .map((String items) => DropdownMenuItem(
                                        value: items,
                                        child: Text(items),
                                      ))
                                  .toList(),
                              underline: Container(),
                              onChanged: (String? val) {
                                _language = val as String;
                                setLastUserActivity(language: _language);
                                fetchList();
                              })
                          : const Text(
                              "English",
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: ElevatedButton(
                          onPressed: () {
                            setLastUserActivity(
                                isModeToEnglish: !_isModeToEnglish);
                            setState(() {
                              _isModeToEnglish = !_isModeToEnglish;
                            });
                            fetchList();
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
                                  .map((String items) => DropdownMenuItem(
                                        value: items,
                                        child: Text(items),
                                      ))
                                  .toList(),
                              underline: Container(),
                              onChanged: (String? val) {
                                _language = val as String;
                                setLastUserActivity(language: _language);
                                fetchList();
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
                  fetchList();
                },
                decoration: const InputDecoration(
                  hintText: 'Search',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_items[index]["val"] as String),
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black38, width: .3),
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                      onTap: () async {
                        Map wordData = await databaseHelper.getById(
                            _items[index]["id"] as int, _language);

                        if (!mounted) return;

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WordDisplay(word: wordData),
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
