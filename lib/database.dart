class DatabaseHelper {
  DatabaseHelper(String lang);

  Future<List<Map<String, Object?>>> search(String val, String lang, db) async {
    if (val.isEmpty) return [];

    var result = await db.rawQuery(
        'SELECT id, display FROM $lang WHERE word LIKE "$val%" LIMIT 30');

    return result.toList();
  }

  getById(int id, String lang, db) async {
    var result = await db.rawQuery('SELECT * FROM $lang WHERE id = $id');

    return result.toList()[0];
  }

  close(db) => db.close();
}
