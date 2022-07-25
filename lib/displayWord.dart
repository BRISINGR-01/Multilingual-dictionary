import 'dart:convert';

import 'package:flutter/material.dart';

class WordDisplay extends StatelessWidget {
  final Map word;
  const WordDisplay({Key? key, required this.word}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> senses = json.decode(word["senses"]);
    List<dynamic>? ipas =
        word["ipas"] == null ? null : json.decode(word["ipas"]);
    List<dynamic>? tags = jsonDecode(word["tags"]);

    return Scaffold(
      appBar: AppBar(
        title: Text(word["word"]),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Theme.of(context).colorScheme.tertiary,
        child: Container(
          height: 50.0,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Tables of forms',
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.grid_on_outlined,
            color: Theme.of(context).colorScheme.onPrimary),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                word["display"],
                style: TextStyle(
                    fontSize: 40,
                    color: Theme.of(context).colorScheme.onBackground,
                    fontFamily: "New Times Roman",
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none),
              ),
              if (ipas != null)
                Text("/$ipas/",
                    style: TextStyle(
                        fontSize: 30,
                        color: Theme.of(context).colorScheme.primary,
                        fontFamily: "New Times Roman",
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none)),
              Expanded(
                child: ListView.builder(
                    itemCount: senses.length,
                    itemBuilder: (context, index) {
                      return Text('- ${senses[index]}',
                          style: TextStyle(
                              fontSize: 30,
                              color: Theme.of(context).colorScheme.onBackground,
                              fontFamily: "New Times Roman",
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none));
                    }),
              ),
              if (word["origin"] != null)
                Text(word["origin"],
                    style: const TextStyle(
                        fontSize: 30,
                        color: Colors.grey,
                        fontFamily: "New Times Roman",
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none)),
            ],
          ),
        ),
      ),
    );
  }
}
