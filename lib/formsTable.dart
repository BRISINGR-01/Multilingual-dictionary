// ignore_for_file: file_names

import 'package:flutter/material.dart';

class FormsTable extends StatelessWidget {
  const FormsTable({Key? key, required this.forms}) : super(key: key);

  final List forms;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.tertiary,
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Coming Soon",
              style: TextStyle(
                  fontSize: 50,
                  color: Theme.of(context).colorScheme.onTertiary)),
        ),
      ),
    );
  }
}
