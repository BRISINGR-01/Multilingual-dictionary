import 'package:flutter/material.dart';
import 'package:multilingual_dictionary/database.dart';
import 'package:multilingual_dictionary/displayWord.dart';

class SearchState extends State<Search> {
  DatabaseHelper databaseHelper = DatabaseHelper.init("Dutch");

  final List<String> _languages = ["French", "Dutch"];
  List<Map<String, Object?>> _items = [];
  String _language = "French";
  String _querry = "";
  bool _modeToEnglish = true;

  fetchList() async {
    QueryResult items = _modeToEnglish
        ? await databaseHelper.searchToEnglish(_querry, _language)
        : await databaseHelper.searchFromEnglish(_querry, _language);

    setState(() {
      _items = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Languages'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(mainAxisSize: MainAxisSize.max, children: [
            Container(
              color: Colors.white,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: _modeToEnglish
                      ? <Widget>[
                          DropdownButton(
                              value: _language,
                              items: _languages
                                  .map((String items) => DropdownMenuItem(
                                        value: items,
                                        child: Text(items),
                                      ))
                                  .toList(),
                              onChanged: (String? val) {
                                _language = val as String;
                                fetchList();
                              }),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _modeToEnglish = !_modeToEnglish;
                                  });
                                  fetchList();
                                },
                                child: const Icon(
                                  Icons.swap_horiz_outlined,
                                )),
                          ),
                          const Text(
                            "English",
                            style: TextStyle(fontSize: 16),
                          )
                        ]
                      : <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(right: 15),
                            child: Text(
                              "English",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _modeToEnglish = !_modeToEnglish;
                                  });
                                  fetchList();
                                },
                                child: const Icon(
                                  Icons.swap_horiz_outlined,
                                )),
                          ),
                          DropdownButton(
                              value: _language,
                              items: _languages
                                  .map((String items) => DropdownMenuItem(
                                        value: items,
                                        child: Text(items),
                                      ))
                                  .toList(),
                              onChanged: (String? val) {
                                _language = val as String;
                                fetchList();
                              }),
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
