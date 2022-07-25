import 'package:flutter/material.dart';
import 'package:multilingual_dictionary/search.dart';

void main() async {
  runApp(MaterialApp(
    home: const Search(),
    theme: ThemeData(
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: Colors.lightBlue.shade400,
        onPrimary: Colors.white,
        secondary: Colors.lightGreen,
        onSecondary: Colors.black,
        tertiary: const Color.fromARGB(255, 201, 143, 253),
        onTertiary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        background: Colors.grey.shade100,
        onBackground: Colors.black,
        surface: Colors.grey.shade200,
        onSurface: Colors.black,
      ),
      textTheme: const TextTheme(
        headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        headline4: TextStyle(
            fontSize: 52.0, fontWeight: FontWeight.bold, color: Colors.black),
        headline6: TextStyle(
            fontSize: 36.0, fontStyle: FontStyle.italic, color: Colors.grey),
        bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
      ),
    ),
  ));
}
