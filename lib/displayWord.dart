import 'dart:convert';

import 'package:flutter/material.dart';

class WordDisplay extends StatelessWidget {
  final Map word;
  const WordDisplay({Key? key, required this.word}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(word);
    List<dynamic> senses = jsonDecode(word["senses"]);
    String? ipas = word["ipas"] == null ? null : jsonDecode(word["ipas"]);
    // List<dynamic>? examples = jsonDecode(word["examples"]);
    // List<dynamic>? tags = jsonDecode(word["tags"]);
    return Column(
      children: [
        Text(word["display"]),
        Text(word["origin"]),
        if (ipas != null) Text("/$ipas/"),
        Expanded(
          child: ListView.builder(
              itemCount: senses.length,
              itemBuilder: (context, index) {
                return Text(senses[index]);
              }),
        )
      ],
    );
  }
}
