// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:multilingual_dictionary/shared/utilities.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

typedef QueryResultSet = List<Map<String, Object?>>;
typedef QueryRow = Map<String, Object?>;

class DatabaseHelper {
  final DBWrapper _database = DBWrapper.init();
  bool isInitialized = false;
  late List<String> languages;
  late List<String> tables;
  late Collections collections;
  late UserData userData;

  DatabaseHelper.init() {
    _database.ensureInitialized().then((_) async {
      tables = List<String>.from((await _database.query("sqlite_schema",
              columns: ["name"], where: "type = ?", whereArgs: ['table']))
          .map((e) => e["name"]));

      languages = tables
          .where((table) =>
              table != "sqlite_sequence" &&
              table != "userData" &&
              !table.startsWith("Collection-"))
          .toList();

      if (!tables.contains("userData")) {
        await _database
            .createTable('userData', {"name": "TEXT", "value": "TEXT"});
        _database.insert('userData', {"name": 'mode', "value": "toEnglish"});
        _database
            .insert('userData', {"name": 'currentLanguage', "value": null});
        _database.insert('userData',
            {"name": 'collection-icons', "value": "{\"All\": 57585}"});
      }

      userData = UserData(_database, languages: languages);
      collections = Collections(_database,
          userData: userData, tables: tables, languages: languages);
      isInitialized = true;
    });
  }

  Future<void> ensureInitialized() async {
    if (!isInitialized) {
      await Future.delayed(const Duration(milliseconds: 10));

      return ensureInitialized();
    }
    // now that the late classes are defined
    if (!userData.isInitialized || !collections.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 10));

      return ensureInitialized();
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    QueryResultSet data = await _database.query('userData');

    return {for (var entry in data) entry["name"] as String: entry["value"]};
  }

  Future<QueryResultSet> searchToEnglish(String val, String lang) async {
    val = val.trim();
    if (val.isEmpty) return [];

    QueryResultSet result = await _database.query(lang,
        columns: ['id', 'pos', 'word'],
        where: "word LIKE ?",
        whereArgs: ['$val%'],
        limit: 30);

    return result.map((word) {
      return <String, Object?>{
        "id": word["id"],
        "val": word["word"],
      };
    }).toList();
  }

  Future<QueryResultSet> searchFromEnglish(String val, String lang) async {
    //! sanitize query properly
    String query = "";
    RegExp sanitizer = RegExp(r'([\w\s\d\-\p{L}]+)');
    Iterable<Match> matches = sanitizer.allMatches(val);
    for (final Match m in matches) {
      query += m[0]!;
    }
    if (query.isEmpty) return [];

    QueryResultSet result = await _database.query(lang,
        columns: ["id", "pos", "translations"],
        where:
            'EXISTS (SELECT * FROM json_each(translations) WHERE value LIKE \'$query%\')',
        limit: 30);

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

  Future<QueryRow> getById(int id, String lang) async {
    QueryResultSet result =
        await _database.query(lang, where: "id=?", whereArgs: [id]);

    return result.first;
  }

  addLanguage(String lang, Function setProgressAndSize) async {
    String url = 'http://localhost:3000/$lang';
    // String url = 'http://172.16.0.177:3000/$lang';

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

    await _database.createTable(lang, {
      "id": "INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL",
      "word": "TEXT NOT NULL",
      "pos": "TEXT NOT NULL",
      "display": "TEXT NOT NULL",
      "origin": "TEXT",
      "ipas": "TEXT",
      "senses": "TEXT",
      "forms": "TEXT",
      "tags": "TEXT",
      "translations": "TEXT"
    });

    await _database.execute(
        'ATTACH DATABASE \'${join(dir.path, '$lang.sql')}\' as \'$lang\';');

    await _database.execute('INSERT INTO \'$lang\' SELECT * FROM $lang.$lang');

    await _database.execute('DETACH DATABASE \'$lang\';');

    _database.insert('userData', {"name": lang, "value": totalLength});

    await _database.createTable('Collection-$lang-All',
        {"id": "INTEGER", "display": "TEXT", "groups": "TEXT"});

    newSqlFile.deleteSync();

    return true;
  }

  deleteLanguage(String lang) async {
    await _database.execute('DROP TABLE $lang');

    await _database.delete('userData', where: "name=?", whereArgs: [lang]);

    await _database.execute('VACUUM');
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

  Future? getNotificationWord({bool fromCollections = true}) async {
    if (fromCollections) {
      List<String> shuffledLanguages = languages.toList();
      shuffledLanguages.shuffle();

      // some languages might not have any saved words
      for (String lang in shuffledLanguages) {
        List words = (await collections
            .getWords("Collection-$lang-All"))["words"] as List;

        if (words.isEmpty) continue;

        int id = words[Random().nextInt(words.length)]["id"];
        Map<String, dynamic> word = await getById(id, lang);

        return {...word, "language": lang};
      }
    } else {
      String lang = languages[Random().nextInt(languages.length)];

      int amountOfWords = (await _database.query('sqlite_sequence',
              where: "name=?", whereArgs: [lang], columns: ["seq"]))
          .first["seq"] as int;

      Map<String, dynamic> word = (await _database.query(lang,
          where: "id=?", whereArgs: [Random().nextInt(amountOfWords)]))[0];

      return {...word, "language": lang};
    }
  }
}

class Collections {
  final DBWrapper _database;
  final UserData userData;
  final List<String> tables;
  final List<String> languages;
  late List<Map<String, dynamic>> _all;
  bool isInitialized = false;

  List<Map<String, dynamic>> get all => _all;

  Collections(
    this._database, {
    required this.userData,
    required this.tables,
    required this.languages,
  }) {
    List<String> collections =
        tables.where((table) => table.startsWith("Collection")).toList();

    userData.get(name: "collection-icons").then((iconsData) {
      Map<String, dynamic> icons = json.decode(iconsData as String);

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

      isInitialized = true;
    });
  }

  add(Map<String, dynamic> collection) async {
    await _database.createTable(
        collection["fullTitle"], {"id": "INTEGER", "display": "TEXT"});

    _all.add(collection);

    await _database.update(
        'userData',
        {
          "value": json.encode({for (var v in _all) v["title"]: v["icon"]})
        },
        where: "name=?",
        whereArgs: ['collection-icons']);
  }

  delete(String title) {
    _database.execute('DROP TABLE \'$title\'');
    _all.removeWhere((element) => element["fullTitle"] == title);
  }

  Future<Map<String, List>> getWords(String title) async {
    List<int> order = List<int>.from(json.decode((await _database.query(
        "userData",
        columns: ["value"],
        where: " name=?",
        whereArgs: ['$title-order']))[0]["value"] as String));

    return {"order": order, "words": await _database.query(title)};
  }

  Future<List<String>?> getWordCollections(String language, int id) async {
    QueryResultSet wordCollections = await _database.query(
        'Collection-$language-All',
        columns: ["groups"],
        where: "id=?",
        whereArgs: [id]);

    if (wordCollections.isEmpty) return null;

    return List<String>.from(
        json.decode(wordCollections[0]["groups"] as String));
  }

  addTo(String collection, Map<String, dynamic> word, String language,
      List<String> wordCollections,
      [List<int>? order]) async {
    order ??= List<int>.from(json.decode((await _database.query('userData',
        columns: ["value"],
        where: "name=?",
        whereArgs: ['$collection-order']))[0]["value"] as String));

    if ("Collection-$language-All" == collection) {
      _database.insert(collection,
          {"id": word["id"], "display": word["display"], "groups": "[]"});
    } else {
      _database
          .insert(collection, {"id": word["id"], "display": word["display"]});
      _database.update(
          'Collection-$language-All',
          {
            "groups": json.encode([...wordCollections, collection])
          },
          where: "id=?",
          whereArgs: [word["id"]]);
    }
    _database.update(
        'userData',
        {
          "value": json.encode([...order, word["id"]])
        },
        where: "name=?",
        whereArgs: ['$collection-order']);
  }

  removeFrom(String collection, Map<String, dynamic> word,
      [String? language, List<String>? wordCollections]) async {
    language ??= languages.firstWhere(
        (lang) => RegExp("Collection-$lang-.+").hasMatch(collection));
    wordCollections ??= await getWordCollections(language, word["id"]);

    if ("Collection-$language-All" == collection) {
      for (String wordCollection in wordCollections!) {
        _database
            .delete(wordCollection, where: "id =?", whereArgs: [word["id"]]);
      }
    } else {
      _database.update(
          'Collection-$language-All',
          {
            "groups": json.encode(
                wordCollections!.where((el) => el != collection).toList())
          },
          where: "id=?",
          whereArgs: [word["id"]]);
    }
    _database.delete(collection, where: "id =?", whereArgs: [word["id"]]);
  }

  setOrder(String collection, List<int> order) {
    _database.update('userData', {"value": json.encode(order)},
        where: "name=?", whereArgs: ['$collection-order']);
  }
}

class UserData {
  final DBWrapper _database;
  final List<String> languages;
  late String currentLanguage;
  late Mode mode;
  bool isInitialized = false;

  UserData(this._database, {required this.languages}) {
    _database.ensureInitialized().then((_) async {
      Map<String, dynamic> userPreferences =
          (await get(names: ["currentLanguage", "mode"]))!;

      currentLanguage = userPreferences["currentLanguage"] ?? "";
      if (!languages.contains(currentLanguage) && languages.isNotEmpty) {
        currentLanguage = languages.first;
      }

      mode = userPreferences["mode"] != "toEnglish"
          ? Mode.fromEnglish
          : Mode.toEnglish;
      isInitialized = true;
    });
  }

  Future get({String? name, List<String>? names}) async {
    if (name != null) {
      QueryResultSet query =
          await _database.query('userData', where: "name=?", whereArgs: [name]);

      if (query.isEmpty) return null;

      return query.first["value"];
    } else {
      QueryResultSet query = await _database.query('userData',
          where: "name IN (${List.filled(names!.length, "?").join(",")})",
          whereArgs: names);

      if (query.isEmpty) return null;

      return {for (QueryRow row in query) row["name"] as String: row["value"]};
    }
  }

  set(String name, String value) async {
    if (await get(name: name) != null) {
      _database.update('userData', {"value": value},
          where: "name=?", whereArgs: [name]);
    } else {
      _database.insert("userData", {"name": name, "value": value});
    }
  }

  Future<Map<String, int>> getLanguageTablesSize() async {
    QueryResultSet data = await _database.query('userData');
    Map<String, int> langData = {};

    for (QueryRow row in data) {
      if (languages.contains(row["name"])) {
        langData[row["name"] as String] = int.parse(row["value"] as String);
      }
    }

    return langData;
  }
}

class DBWrapper {
  var _dbInstance;
  DBWrapper.init() {
    sqfliteFfiInit();

    getApplicationDocumentsDirectory().then((dbDirectory) => databaseFactoryFfi
        .openDatabase(join(dbDirectory.path, 'database.sql'))
        .then((db) => _dbInstance = db));
  }

  Future execute(String sqlQuery) async {
    await ensureInitialized();

    return _dbInstance.execute(sqlQuery);
  }

  Future<QueryResultSet> query(String table,
      {bool? distinct,
      List<String>? columns,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) async {
    await ensureInitialized();

    return _dbInstance.query('"$table"',
        columns: columns, where: where, whereArgs: whereArgs, limit: limit);
  }

  void insert(String table, Map<String, Object?> values) async {
    await ensureInitialized();

    _dbInstance.insert(table, values);
  }

  Future createTable(String table, Map<String, String> values) {
    String tableColumns =
        values.entries.map((MapEntry e) => "${e.key} ${e.value},").join("\n");

    tableColumns =
        tableColumns.substring(0, tableColumns.length - 1); // remove last comma

    return execute('''
      CREATE TABLE '$table' (
        $tableColumns
      );
    ''');
  }

  update(String table, Map<String, Object?> values,
      {String? where, List<Object?>? whereArgs}) async {
    await ensureInitialized();

    _dbInstance.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<void> delete(String table,
      {String? where, List<Object?>? whereArgs}) async {
    await ensureInitialized();

    return _dbInstance.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> ensureInitialized() async {
    if (_dbInstance == null) {
      await Future.delayed(const Duration(milliseconds: 10));
      return ensureInitialized();
    }
  }
}
