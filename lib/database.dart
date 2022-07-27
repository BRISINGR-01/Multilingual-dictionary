import 'dart:convert';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  var _database;

  DatabaseHelper.init(String lang) {
    sqfliteFfiInit();

    databaseFactoryFfi
        .openDatabase(
            'C:/Users/alexp/Desktop/VSC/multilingual_dictionary/databases/all Lang.sql')
        .then((value) => _database = value);
  }

  Future<QueryResult> searchToEnglish(String val, String lang) async {
    if (val.isEmpty) return [];

    QueryResult result = await _database.rawQuery(
        'SELECT id, display FROM $lang WHERE word LIKE "$val%" LIMIT 30');

    return result.map((word) {
      return <String, Object?>{
        "id": word["id"],
        "val": word["display"],
      };
    }).toList();
  }

  Future<QueryResult> searchFromEnglish(String val, String lang) async {
    if (val.isEmpty) return [];

    QueryResult result = await _database.rawQuery(
        'SELECT id, display, translations FROM $lang WHERE EXISTS (SELECT * FROM json_each(translations) WHERE value LIKE "$val%") LIMIT 30');

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

  close() => _database.close();
}

typedef QueryResult = List<Map<String, Object?>>;
