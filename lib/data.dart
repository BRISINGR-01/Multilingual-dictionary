import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

typedef QueryResult = List<Map<String, Object?>>;

class DatabaseHelper {
  // ignore: prefer_typing_uninitialized_variables
  var _database;

  DatabaseHelper.init() {
    sqfliteFfiInit();

    databaseFactoryFfi
        .openDatabase(
            'C:/Users/alexp/Desktop/VSC/multilingual_dictionary/assets/database.sql')
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

Future<Map<String, dynamic>> getLastUserActivity() async {
  final prefs = await SharedPreferences.getInstance();

  final mode = prefs.getBool('isModeToEnglish') ?? true;
  final language = prefs.getString('language') ?? "French";

  return {"isModeToEnglish": mode, "language": language};
}

void setLastUserActivity({String? language, bool? isModeToEnglish}) async {
  final prefs = await SharedPreferences.getInstance();

  if (language != null) {
    await prefs.setString('language', language);
  }
  if (isModeToEnglish != null) {
    await prefs.setBool('isModeToEnglish', isModeToEnglish);
  }
}
