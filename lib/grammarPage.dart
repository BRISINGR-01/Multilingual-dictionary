// ignore_for_file: file_names

import 'package:flutter/material.dart';

class GrammarPage extends StatelessWidget {
  final String language;
  const GrammarPage({Key? key, required this.language}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(language)),
      ),
    );
  }
}
