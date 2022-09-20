// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

typedef QueryResult = List<Map<String, Object?>>;

class DatabaseHelper {
  var _database;
  late Map<String, http.Request> requests;
  bool isInitialized = false;
  List<String> languages = [];
  late CollectionsFunctions collections;

  DatabaseHelper.init() {
    sqfliteFfiInit();

    getApplicationDocumentsDirectory().then((value) async {
      databaseFactoryFfi
          .openDatabase(join(value.path, 'database.sql'))
          .then((db) async {
        _database = db;

        List<String> tables = List<String>.from((await _database.rawQuery(
                'SELECT name FROM sqlite_schema WHERE type=\'table\''))
            .map((e) => e["name"]));

        // await _database.rawQuery(
        //     'DELETE FROM \'userData\' where name = \'collection-icons\'');

        languages = tables
            .where((table) =>
                table != "sqlite_sequence" &&
                table != "userData" &&
                !table.startsWith("Collection-"))
            .toList();

        // tables.forEach((element) {
        //   print(element);
        //   if (element.startsWith("Coll")) {
        //     _database.rawQuery('Drop table "$element"');
        //   }
        // });

        // await _database.rawQuery(
        //     'UPDATE "userData" SET value = \'{"All": 61155}\' WHERE name = "collection-icons"');

        // _database.rawQuery('DROP TABLE "Collection-Dutch-All"');
        // await _database.rawQuery('''
        //   CREATE TABLE 'Collection-Dutch-All' (
        //     id INTEGER,
        //     display TEXT NOT NULL,
        //     groups TEXT
        //   );
        // ''');

        if (!tables.contains("userData")) {
          await _database.rawQuery('''
            CREATE TABLE 'userData' (
              name TEXT ,
              value TEXT
            );
          ''');
          await _database.rawQuery(
              'INSERT INTO \'userData\' (name, value) VALUES (\'isModeToEnglish\', \'true\')');
          await _database.rawQuery(
              'INSERT INTO \'userData\' (name, value) VALUES (\'currentLanguage\', \'\')');
          await _database.rawQuery(
              'INSERT INTO \'userData\' (name, value) VALUES (\'collection-icons\', \'{"All": 57585}\')');
        }
        collections = CollectionsFunctions(
            _database, () => isInitialized = true, languages);
      });
    });
  }

  Future<Map<String, dynamic>> getUserData() async {
    if (_database == null) {
      await Future.delayed(const Duration(milliseconds: 10));
      return getUserData();
    }

    QueryResult data = await _database.rawQuery('SELECT * FROM \'userData\'');

    return {for (var entry in data) entry["name"] as String: entry["value"]};
  }

  setUserData(String name, String value) async {
    if (_database == null) {
      await Future.delayed(const Duration(milliseconds: 10));
      return setUserData(name, value);
    }

    return _database.rawQuery(
        'UPDATE \'userData\' SET value = \'$value\' WHERE name = \'$name\'');
  }

  Future<QueryResult> searchToEnglish(String val, String lang) async {
    val = val.trim();
    if (val.isEmpty) return [];

    QueryResult result = await _database.rawQuery(
        'SELECT id, pos, word FROM $lang WHERE word LIKE \'$val%\' LIMIT 30');

    return result.map((word) {
      return <String, Object?>{
        "id": word["id"],
        "val": word["word"],
      };
    }).toList();
  }

  Future<QueryResult> searchFromEnglish(String val, String lang) async {
    String query = "";
    RegExp sanitizer = RegExp(r'([\w\s\d\-\p{L}]+)');
    Iterable<Match> matches = sanitizer.allMatches(val);
    for (final Match m in matches) {
      query += m[0]!;
    }
    if (query.isEmpty) return [];

    QueryResult result = await _database.rawQuery(
        'SELECT id, pos, translations FROM $lang WHERE EXISTS (SELECT * FROM json_each(translations) WHERE value LIKE \'$query%\') LIMIT 30');

    return result.map((word) {
      List<dynamic> translations = json.decode(word["translations"] as String);

      return {
        "id": word["id"],
        "val": translations
            .where((tr) => (tr as String).startsWith(val))
            .join(", ")
      };
    }).toList();
  }

  getById(int id, String lang) async {
    var result = await _database.rawQuery('SELECT * FROM $lang WHERE id = $id');

    return result.toList()[0];
  }

  addLanguage(String lang, Function setProgressAndSize) async {
    String url = 'http://localhost:3000/$lang';
    // String url = 'http://192.168.1.106:3000/$lang';

    http.StreamedResponse streamedResponse;
    try {
      http.Request request = http.Request('GET', Uri.parse(url));
      streamedResponse = await request.send();
    } catch (e) {
      return false;
    }

    int totalLength =
        int.parse(streamedResponse.headers["original-length"] ?? "0");
    num lengthOfSaved = 0;

    Directory dir = await getApplicationDocumentsDirectory();
    File newSqlFile = File(join(dir.path, '$lang.sql'));

    IOSink out = newSqlFile.openWrite();
    await streamedResponse.stream.map((List<int> d) {
      if (totalLength != 0) {
        lengthOfSaved += d.length / 1024;

        setProgressAndSize(lengthOfSaved / totalLength, lengthOfSaved.round());
      }

      return d;
    }).pipe(out);

    requests.remove(lang);

    await _database.rawQuery('''
      CREATE TABLE '$lang' (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        word TEXT NOT NULL,
        pos TEXT NOT NULL,
        display TEXT NOT NULL,
        origin TEXT,
        ipas TEXT,
        senses TEXT,
        forms TEXT,
        tags TEXT,
        translations TEXT
      );
    ''');

    await _database.rawQuery(
        'ATTACH DATABASE \'${join(dir.path, '$lang.sql')}\' as \'$lang\';');

    await _database.rawQuery('INSERT INTO \'$lang\' SELECT * FROM $lang.$lang');

    await _database.rawQuery('DETACH DATABASE \'$lang\';');

    await _database.rawQuery(
        'INSERT INTO \'userData\' (name, value) VALUES (\'$lang\', \'$totalLength\')');

    await _database.rawQuery('''
      CREATE TABLE 'Collection-$lang-All' (
        id INTEGER ,
        display TEXT,
        groups TEXT
      );
    ''');

    newSqlFile.deleteSync();

    return true;
  }

  deleteLanguage(String lang) async {
    await _database.rawQuery('DROP TABLE $lang');

    await _database.rawQuery('DELETE FROM userData WHERE name = \'$lang\'');

    await _database.rawQuery('VACUUM');
  }

  cancel(String lang) {}

  Future<Map<String, dynamic>?> getGrammar(String language) async {
    language = "Italian";
    String rawBundle = await rootBundle.loadString('assets/grammarBundle.json');

    return json.decode(rawBundle)[language];
  }

  Future<Map<String, dynamic>?> getLanguageData() async {
    String rawBundle = await rootBundle.loadString('assets/languagesData.json');

    return json.decode(rawBundle);
  }
}

class CollectionsFunctions {
  final _database;
  final finishInitialization;
  final List<String> languages;
  late List<Map<String, dynamic>> _all;

  List<Map<String, dynamic>> get all => _all;

  CollectionsFunctions(
      this._database, this.finishInitialization, this.languages) {
    _database
        .rawQuery(
            'SELECT value FROM \'userData\' WHERE name = \'collection-icons\'')
        .then((icons) {
      icons = json.decode(icons[0]["value"]);
      _database
          .rawQuery('SELECT name FROM sqlite_schema WHERE type=\'table\'')
          .then((tables) {
        List<String> collections =
            List<String>.from(tables.map((table) => table["name"]))
                .where((table) => table.startsWith("Collection"))
                .toList();

        _all = collections
            .map((title) => {
                  "fullTitle": title,
                  "title": title.replaceFirst(RegExp(r"Collection-\w+-"), ""),
                  "language": title
                      .replaceFirst(RegExp(r"Collection-"), "")
                      .replaceFirst(RegExp(r"-.+"), ""),
                  "icon":
                      icons[title.replaceFirst(RegExp(r"Collection-\w+-"), "")],
                })
            .toList();
      });

      finishInitialization();
    });
  }

  add(Map<String, dynamic> collection) async {
    await _database.rawQuery('''
            CREATE TABLE '${collection["fullTitle"]}' (
              id INTEGER ,
              display TEXT
            );
          ''');

    _all.add(collection);

    await _database.rawQuery('UPDATE \'userData\' SET value = \'${json.encode({
          for (var v in _all) v["title"]: v["icon"]
        })}\' WHERE name = \'collection-icons\'');
  }

  delete(String title) {
    _database.rawQuery('DROP TABLE \'$title\'');
    _all.removeWhere((element) => element["fullTitle"] == title);
  }

  Future<Map<String, List>> getWords(String title) async {
    List<int> order = List<int>.from(json.decode((await _database.rawQuery(
            "SELECT value from 'userData' WHERE name = '$title-order'"))[0]
        ["value"]));

    return {
      "order": order,
      "words": await _database.rawQuery('SELECT * FROM \'$title\'')
    };
  }

  Future<List<String>?> getWordCollections(String language, int id) async {
    QueryResult wordCollections = await _database.rawQuery(
        'SELECT groups FROM \'Collection-$language-All\' where id = $id');

    if (wordCollections.isEmpty) return null;

    return List<String>.from(
        json.decode(wordCollections[0]["groups"] as String));
  }

  addTo(String collection, Map<String, dynamic> word, String language,
      List<String> wordCollections,
      [List<int>? order]) async {
    order ??= List<int>.from(json.decode((await _database.rawQuery(
            "SELECT value from 'userData' WHERE name = '$collection-order'"))[0]
        ["value"]));

    if ("Collection-$language-All" == collection) {
      _database.rawQuery(
          'INSERT INTO \'$collection\' (id, display, groups) VALUES (\'${word["id"]}\', \'${word["display"]}\', \'[]\')');
    } else {
      _database.rawQuery(
          'INSERT INTO \'$collection\' (id, display) VALUES (\'${word["id"]}\', \'${word["display"]}\')');
      _database.rawQuery(
          'UPDATE \'Collection-$language-All\' SET groups = \'${json.encode([
            ...wordCollections,
            collection
          ])}\' WHERE id = ${word["id"]}');
    }
    _database.rawQuery('UPDATE \'userData\' SET value = \'${json.encode([
          ...order,
          word["id"]
        ])}\' WHERE name = \'$collection-order\'');
  }

  removeFrom(String collection, Map<String, dynamic> word,
      [String? language, List<String>? wordCollections]) async {
    language ??= languages.firstWhere(
        (lang) => RegExp("Collection-$lang-.+").hasMatch(collection));
    wordCollections ??= await getWordCollections(language, word["id"]);

    if ("Collection-$language-All" == collection) {
      for (String wordCollection in wordCollections!) {
        _database.rawQuery(
            'DELETE FROM \'$wordCollection\' WHERE id = ${word["id"]}');
      }
    } else {
      _database.rawQuery(
          'UPDATE \'Collection-$language-All\' SET groups = \'${json.encode(wordCollections!.where((el) => el != collection).toList())}\' WHERE id = ${word["id"]}');
    }
    _database.rawQuery('DELETE FROM \'$collection\' WHERE id = ${word["id"]}');
  }

  setOrder(String collection, List<int> order) {
    _database.rawQuery(
        'UPDATE \'userData\' SET value = \'${json.encode(order)}\' WHERE name = \'$collection-order\'');
  }
}
