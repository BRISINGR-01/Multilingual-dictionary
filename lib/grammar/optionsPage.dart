import 'package:flutter/material.dart';
import 'package:multilingual_dictionary/grammar/article.dart';
import 'package:multilingual_dictionary/grammar/noGrammar.dart';

class OptionsPage extends StatelessWidget {
  final Map<String, dynamic> items;
  final String title;
  const OptionsPage({Key? key, required this.items, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> titles = items.keys.toList();

    if (titles.isEmpty) return const NoGrammar();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(title),
        ),
        body: ListView.builder(
            itemCount: titles.length,
            itemBuilder: (context, i) {
              return ListTile(
                  title: Text(titles[i]),
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black38, width: .3),
                  ),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              items[titles[i]]!.containsKey("title")
                                  ? Article(body: items[titles[i]])
                                  : OptionsPage(
                                      items: items[titles[i]],
                                      title: titles[i],
                                    ))));
            }),
      ),
    );
  }
}
