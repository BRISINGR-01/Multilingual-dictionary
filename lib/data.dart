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
        'SELECT id, pos, display FROM $lang WHERE word = "val" LIMIT 30');

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
        'SELECT id, pos, display, translations FROM $lang WHERE EXISTS (SELECT * FROM json_each(translations) WHERE value LIKE "$val%") LIMIT 30');

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

  addLanguage(String lang, Function setProgress, Function setSize) async {
    String url = 'http://localhost:3000/$lang';
    // String url = 'https://dummy.restapiexample.com/api/v1/employee/1';

    // http.Response response = await http.get(Uri.parse(url));

    // print(response.contentLength);
    // if (response.statusCode == 200) {
    //   String data = response.body;

    // } else {
    //   print(response.reasonPhrase);
    // }

    http.Request request = http.Request('GET', Uri.parse(url));
    http.StreamedResponse streamedResponse = await request.send();

    Directory dir = await getApplicationDocumentsDirectory();
    File pathToSave = File(join(dir.path, '$lang.sql'));

    // num? totalLength = streamedResponse.contentLength;
    int totalLength =
        int.parse(streamedResponse.headers["original-length"] ?? "0");
    num lengthOfSaved = 0;

    IOSink out = pathToSave.openWrite();
    await streamedResponse.stream.map((List<int> d) {
      if (totalLength != 0) {
        lengthOfSaved += d.length / 1024;

        setProgress(lengthOfSaved / totalLength);
        setSize(lengthOfSaved.round());
      }

      return d;
    }).pipe(out);
    // streamedResponse.stream.pipe(out);

    // await _database.rawQuery('''CREATE TABLE "$lang" (
    //   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    //   word TEXT NOT NULL,
    //   pos TEXT NOT NULL,
    //   lang TEXT NOT NULL,
    //   display TEXT NOT NULL,
    //   origin TEXT,
    //   ipas TEXT,
    //   senses TEXT,
    //   forms TEXT,
    //   tags TEXT,
    //   translations TEXT
    // );''');

    return true;
  }

  deleteLanguage(String lang) async {
    // await _database.rawQuery('DROP TABLE $lang');

    Directory dir = await getApplicationDocumentsDirectory();
    File file = File(join(dir.path, '$lang.sql'));

    await file.delete();
    return;
  }

  close() => _database.close();
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
