import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FormsTable extends StatelessWidget {
  FormsTable({Key? key, required this.forms});

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
