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
        .then((value) async {
      _database = value;
    });
  }

  Future<List<String>> getLanguages() async {
    if (_database == null) {
      await Future.delayed(const Duration(milliseconds: 10));
      return getLanguages();
    }
    await Future.delayed(Duration(milliseconds: 2000));

    List<String> tables = List<String>.from((await _database
            .rawQuery('SELECT name FROM sqlite_schema WHERE type=\'table\''))
        .map((e) => e["name"]));

    return tables.where((element) => element != "sqlite_sequence").toList();
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

Future<Map<String, dynamic>> getUserData() async {
  final prefs = await SharedPreferences.getInstance();

  bool isModeToEnglish = prefs.getBool('isModeToEnglish') ?? true;
  List<String> languages = prefs.getStringList('languages') ?? [];
  String language =
      prefs.getString('language') ?? (languages.isNotEmpty ? languages[0] : "");

  return {
    "isModeToEnglish": isModeToEnglish,
    "language": language,
    "languages": languages
  };
}

void setUserData(
    {String? language, bool? isModeToEnglish, List<String>? languages}) async {
  final prefs = await SharedPreferences.getInstance();

  if (language != null) {
    await prefs.setString('language', language);
  }
  if (isModeToEnglish != null) {
    await prefs.setBool('isModeToEnglish', isModeToEnglish);
  }
  if (languages != null) {
    await prefs.setStringList('languages', languages);
  }
}
