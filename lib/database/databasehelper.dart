import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../vinile/vinile.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async =>
      _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'vinili.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE collezioneVinili(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titolo TEXT NOT NULL,
            artista TEXT NOT NULL,
            anno INTEGER NOT NULL,
            genere INTEGER,
            etichetta_discografica TEXT,
            quantita INTEGER,
            condizione INTEGER,
            immagine TEXT,
            preferito INTEGER DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertVinile(Vinile v) async {
    final db = await database;

    // blocca duplicati (titolo+artista+anno)
    final exists = await db.query(
      'collezioneVinili',
      where: 'titolo = ? AND artista = ? AND anno = ?',
      whereArgs: [v.titolo, v.artista, v.anno],
    );
    if (exists.isNotEmpty) throw Exception('Vinile già presente');

    return db.insert('collezioneVinili', {
      ...v.toMap(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Vinile>> getAllVinili() async {
    final db = await database;
    final maps = await db.query('collezioneVinili');
    return maps.map(Vinile.fromMap).toList();
  }

  /// ultimi N vinili ordinati per data di inserimento (default 10)
  Future<List<Vinile>> getLastVinili({int limit = 10}) async {
    final db = await database;
    final maps = await db.query(
      'collezioneVinili',
      orderBy: 'datetime(created_at) DESC',
      limit: limit,
    );
    return maps.map(Vinile.fromMap).toList();
  }

  /// un vinile casuale (o più di uno)
  Future<List<Vinile>> getRandomVinili({int limit = 3}) async {
    final db = await database;
    final maps = await db.rawQuery(
      'SELECT * FROM collezioneVinili ORDER BY RANDOM() LIMIT ?',
      [limit],
    );
    return maps.map(Vinile.fromMap).toList();
  }

  Future<int> deleteVinile(int id) async {
    final db = await database;
    return db.delete('collezioneVinili', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateVinile(Vinile v) async {
    final db = await database;
    return db.update('collezioneVinili', v.toMap(),
        where: 'id = ?', whereArgs: [v.id]);
  }

  Future<List<Vinile>> getViniliPreferiti() async {
    final db = DatabaseHelper.instance;

    final List<Map<String, dynamic>> maps = await db.database.then( (db) => db.query(
      'collezioneVinili',
      where: 'preferito = ?',
      whereArgs: [1],
    ));

    return maps.map((map)=> Vinile.fromMap(map)).toList();
  }

  Future<bool> vinileEsiste(Vinile vinile) async {
    final db= await DatabaseHelper.instance.database;
    final result= await db.query('collezioneVinili',
      where: 'titolo = ? AND artista = ? AND anno =?',
      whereArgs:[vinile.titolo,vinile.artista,vinile.anno],
    );

    return result.isNotEmpty;
  }
}