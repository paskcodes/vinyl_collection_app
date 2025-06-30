import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../vinile/vinile.dart';

class VinileDatabase {
  static Future<Database> getDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'vinili.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE collezioneVinili (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titolo TEXT NOT NULL,
            nome_artista TEXT NOT NULL,
            anno INTEGER NOT NULL,
            genere INTEGER,
            etichetta_discografica TEXT,
            quantita INTEGER,
            condizione INTEGER,
            immagine TEXT,
            preferito INTEGER
          )
        ''');
      },
    );
  }

  static Future<int> insertVinile(Vinile vinile) async {
    final db = await getDatabase();

    // Controlla se già presente (titolo + artista + anno)
    final existing = await db.query(
      'vinyls',
      where: 'titolo = ? AND nome_artista = ? AND anno = ?',
      whereArgs: [vinile.titolo, vinile.artista, vinile.anno],
    );

    if (existing.isNotEmpty) {
      throw Exception('Questo vinile è già presente nella collezione.');
    }

    return await db.insert(
      'vinyls',
      vinile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Vinile>> getAllVinili() async {
    final db = await getDatabase();
    final maps = await db.query('vinyls');
    return maps.map((map) => Vinile.fromMap(map)).toList();
  }

  static Future<int> deleteVinile(int id) async {
    final db = await getDatabase();
    return await db.delete(
      'vinyls',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
