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

  refetchList(language) async {
    if (_modeToEnglish) {
      QueryResult items = await databaseHelper.search(_querry, language);

      setState(() {
        _items = items;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Languages'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                DropdownButton(
                    value: _language,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: _languages
                        .map((String items) => DropdownMenuItem(
                              value: items,
                              child: Text(items),
                            ))
                        .toList(),
                    onChanged: (String? val) {
                      setState(() {
                        _language = val ?? "French";
                      });
                      refetchList(val);
                    }),
                ElevatedButton(
                    onPressed: () => setState(() {
                          _modeToEnglish = !_modeToEnglish;
                        }),
                    child: const Icon(
                      Icons.swap_horiz_outlined,
                    )),
                const Text("English")
              ],
            ),
            TextField(
              autofocus: true,
              onChanged: (value) async {
                List<Map<String, Object?>> items =
                    await databaseHelper.search(value, _language);
                setState(() {
                  _items = items;
                  _querry = value;
                });
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
            Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_items[index]["display"] as String),
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
            )
          ],
        ),
      ),
    );
  }
}

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  SearchState createState() => SearchState();
}
