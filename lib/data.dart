import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

typedef QueryResult = List<Map<String, Object?>>;

class DatabaseHelper {
  // ignore: prefer_typing_uninitialized_variables
  var _database;

  DatabaseHelper.init() {
    sqfliteFfiInit();

    getApplicationDocumentsDirectory().then((value) async {
      databaseFactoryFfi
          .openDatabase(join(value.path, 'database.sql'))
          .then((value) => _database = value);
    });
  }

  Future<List<String>> getLanguages() async {
    if (_database == null) {
      await Future.delayed(const Duration(milliseconds: 10));
      return getLanguages();
    }

    List<String> tables = List<String>.from((await _database
            .rawQuery('SELECT name FROM sqlite_schema WHERE type=\'table\''))
        .map((e) => e["name"]));

    return tables.where((element) => element != "sqlite_sequence").toList();
  }

  Future<QueryResult> searchToEnglish(String val, String lang) async {
    if (val.isEmpty) return [];

    QueryResult result = await _database.rawQuery(
        'SELECT id, pos, word FROM $lang WHERE word LIKE "$val%" LIMIT 30');

    return result.map((word) {
      return <String, Object?>{
        "id": word["id"],
        "val": word["word"],
      };
    }).toList();
  }

  Future<QueryResult> searchFromEnglish(String val, String lang) async {
    if (val.isEmpty) return [];

    QueryResult result = await _database.rawQuery(
        'SELECT id, pos, translations FROM $lang WHERE EXISTS (SELECT * FROM json_each(translations) WHERE value LIKE "$val%") LIMIT 30');

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

    http.Request request = http.Request('GET', Uri.parse(url));
    http.StreamedResponse streamedResponse = await request.send();

    int totalLength =
        int.parse(streamedResponse.headers["original-length"] ?? "1");
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

    // File copy = newSqlFile.copySync(join(dir.path, '2$lang.sql'));

    await _database.rawQuery('''
      CREATE TABLE "$lang" (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        word TEXT NOT NULL,
        pos TEXT NOT NULL,
        lang TEXT NOT NULL,
        display TEXT NOT NULL,
        origin TEXT,
        ipas TEXT,
        senses TEXT,
        forms TEXT,
        tags TEXT,
        translations TEXT
      );
    ''');

    await _database.rawQuery('''
      ATTACH DATABASE "${join(dir.path, '$lang.sql')}" as "new$lang";
    ''');

    await _database.rawQuery('''
      INSERT INTO "$lang" SELECT * FROM new$lang.${lang == 'French' ? 'French' : 'Dutch'};
    ''');

    await _database.rawQuery('''
      DETACH DATABASE "new$lang";
    ''');

    // copy.deleteSync();
    newSqlFile.deleteSync();

    return true;
  }

  deleteLanguage(String lang) async {
    await _database.rawQuery('DROP TABLE $lang');

    return;
  }
}

Future<Map<String, dynamic>> getUserData(bool getDatabasesSizeOnly) async {
  final prefs = await SharedPreferences.getInstance();

  List<String> languages = prefs.getStringList('languages') ?? [];

  if (getDatabasesSizeOnly == true) {
    return {
      for (String l in languages) l: prefs.getInt(l) ?? 0,
    };
  }

  bool isModeToEnglish = prefs.getBool('isModeToEnglish') ?? true;
  String language =
      prefs.getString('language') ?? (languages.isNotEmpty ? languages[0] : "");

  return {
    "isModeToEnglish": isModeToEnglish,
    "language": language,
    "languages": languages
  };
}

void deleteData() async {
  final prefs = await SharedPreferences.getInstance();

  prefs.clear();
}

void setUserData(
    {String? language,
    bool? isModeToEnglish,
    List<String>? languages,
    Map<String, dynamic>? sizeOfDatabase}) async {
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
  if (sizeOfDatabase != null) {
    print(sizeOfDatabase);
    await prefs.setInt(sizeOfDatabase["language"], sizeOfDatabase["size"] ?? 0);
    print(await prefs.getInt(sizeOfDatabase["language"]));
  }
}
