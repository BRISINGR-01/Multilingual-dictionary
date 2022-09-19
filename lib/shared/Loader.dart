// ignore_for_file: file_names

import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  const Loader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Center(
          child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      )),
    ));
  }
}
