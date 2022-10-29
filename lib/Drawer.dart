// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:multilingual_dictionary/Camera.dart';
import 'package:multilingual_dictionary/Collections.dart';
import 'package:multilingual_dictionary/data.dart';
import 'package:multilingual_dictionary/downloadList.dart';
import 'package:multilingual_dictionary/grammar.dart';

class CustomDrawer extends StatefulWidget {
  final DatabaseHelper databaseHelper;
  final Function editLanguagesList;
  const CustomDrawer(
      {Key? key, required this.databaseHelper, required this.editLanguagesList})
      : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
      ListTile(
        title: const Text('Settings'),
        leading:
            Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black38, width: .3),
        ),
        onTap: () {},
      ),
      ListTile(
        title: const Text('Download Languages'),
        leading:
            Icon(Icons.download, color: Theme.of(context).colorScheme.primary),
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black38, width: .3),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DownloadLanguages(
                  downloadedLanguages: widget.databaseHelper.languages,
                  editLanguagesList: widget.editLanguagesList,
                  databaseHelper: widget.databaseHelper,
                ),
              ));
        },
      ),
      ListTile(
        title: const Text('Collections'),
        leading: Icon(Icons.collections_bookmark_outlined,
            color: Theme.of(context).colorScheme.primary),
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black38, width: .3),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CollectionsHome(
                  databaseHelper: widget.databaseHelper,
                ),
              ));
        },
      ),
      ListTile(
        title: const Text('Grammar'),
        leading: Icon(Icons.menu_book_outlined,
            color: Theme.of(context).colorScheme.primary),
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black38, width: .3),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Grammar(
                  databaseHelper: widget.databaseHelper,
                ),
              ));
        },
      ),
      ListTile(
        title: const Text('Camera'),
        leading: Icon(Icons.photo_camera,
            color: Theme.of(context).colorScheme.primary),
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black38, width: .3),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CameraInitializer(),
              ));
        },
      ),
    ]));
  }
}
