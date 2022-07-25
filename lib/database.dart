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

  Future<QueryResult> search(String val, String lang) async {
    if (val.isEmpty) return [];

    var result = await _database.rawQuery(
        'SELECT id, display FROM $lang WHERE word LIKE "$val%" LIMIT 30');

    return result.toList();
  }

  getById(int id, String lang) async {
    var result = await _database.rawQuery('SELECT * FROM $lang WHERE id = $id');

    return result.toList()[0];
  }

  close() => _database.close();
}

typedef QueryResult = List<Map<String, Object?>>;
