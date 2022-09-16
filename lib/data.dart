import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

typedef QueryResult = List<Map<String, Object?>>;

class DatabaseHelper {
  // ignore: prefer_typing_uninitialized_variables
  var _database;
  late Map<String, http.Request> requests;
  List<String> languages = [];

  DatabaseHelper.init() {
    requests = {};
    sqfliteFfiInit();

    getApplicationDocumentsDirectory().then((value) async {
      databaseFactoryFfi
          .openDatabase(join(value.path, 'database.sql'))
          .then((value) async {
        _database = value;

        List<String> tables = List<String>.from((await _database.rawQuery(
                'SELECT name FROM sqlite_schema WHERE type=\'table\''))
            .map((e) => e["name"]));

        languages = tables
            .where((table) => table != "sqlite_sequence" && table != "userData")
            .toList();

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
        }
      });
    });
  }

  Future<Map<String, dynamic>> getUserData() async {
    if (_database == null) {
      await Future.delayed(const Duration(milliseconds: 10));
      return getUserData();
    }

    QueryResult data = await _database.rawQuery('SELECT * FROM \'userData\'');

    return {
      "languages": languages,
      for (var entry in data) entry["name"] as String: entry["value"]
    };
  }

  void setUserData(String name, String value) async {
    if (_database == null) {
      await Future.delayed(const Duration(milliseconds: 10));
      return setUserData(name, value);
    }

    _database.rawQuery(
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

    http.Request request = http.Request('GET', Uri.parse(url));
    http.StreamedResponse streamedResponse = await request.send();

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
