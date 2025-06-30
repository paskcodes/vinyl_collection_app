import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


import '../vinile/vinile.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'mio_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE collezioneVinili(id INTEGER PRIMARY KEY AUTOINCREMENT,titolo TEXT NOT NULL,artista TEXT NOT NULL,anno INTEGER NOT NULL,genere INTEGER,etichetta_discografica TEXT,quantita INTEGER,condizione INTEGER,immagine TEXT,preferito INTEGER)',
        );
      },
      version: 1,
    );
  }

  Future<bool> aggiungiVinile(Vinile vinile) async {
    final db = await database;
    final result =  await db.insert(
        'collezioneVinili',
        vinile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    return result > 0;
  }

  Future<List<Vinile>> getCollezione() async {
    final db = DatabaseHelper.instance;
    final List<Map<String, dynamic>> maps =
    await db.database.then((db) => db.query('collezioneVinili'));

    return maps.map((map)=> Vinile.fromMap(map)).toList();
  }

  Future<bool> vinileEsiste(Vinile vinile) async {
      final db= await DatabaseHelper.instance.database;
      final result= await db.query('collezioneVinili',
      where: 'titolo = ? AND artista = ? AND anno =?',
      whereArgs:[vinile.titolo,vinile.nomeArtista,vinile.anno],
      );

      return result.isNotEmpty;
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

  Future<bool> eliminaVinile(Vinile vinile) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.delete('collezionevinili',
      where: 'titolo = ? AND artista = ? AND anno = ?',
      whereArgs: [vinile.titolo,vinile.nomeArtista,vinile.anno],
    );
    return result > 0;
  }
  
  Future<bool> modificaVinile(Vinile vinile) async{
    final db = await DatabaseHelper.instance.database;
    
    final result = await db.update('collezioneVinili', vinile.toMap(),
      where: 'id = ?',
      whereArgs: [vinile.id],
    );
  return result > 0;
  }

}
