import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logger/logger.dart';

import '../categoria/genere.dart';
import '../vinile/vinile.dart';

final logger = Logger();

class DatabaseHelper {

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'vinili.db'),
      onCreate: (db, version) async {
        await db.execute('''
    CREATE TABLE generi (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL UNIQUE
    );
  ''');

        await db.execute('''
    CREATE TABLE collezioneVinili (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      titolo TEXT NOT NULL,
      artista TEXT NOT NULL,
      anno INTEGER NOT NULL,
      genere INTEGER NOT NULL,
      etichetta_discografica TEXT NOT NULL,
      quantita INTEGER NOT NULL DEFAULT 1,
      condizione INTEGER NOT NULL,
      immagine TEXT,
      preferito INTEGER DEFAULT 0,
      creato_il TEXT NOT NULL,
      FOREIGN KEY(genere) REFERENCES generi(id)
    );
  ''');

        // Inserisci generi iniziali
        final batch = db.batch();
        final generi = [
          'Rock',
          'Electronic',
          'Pop',
          'Country',
          'Jazz',
          'Funk',
          'Soul',
          'Classical',
          'Hiphop',
          'Latin',
          'Reggae',
          'Blues',
        ];
        for (final g in generi) {
          batch.insert('generi', {'nome': g});
        }
        await batch.commit(noResult: true);
  },
      version: 1,
    );
  }

  Future<void> aggiungiVinile(Vinile v) async {
    final db = await database;
    final exists = await db.query(
      'collezioneVinili',
      where: 'titolo = ? AND artista = ? AND anno = ?',
      whereArgs: [v.titolo, v.artista, v.anno],
    );
    if (exists.isNotEmpty) throw Exception('Vinile già presente');

    db.insert('collezioneVinili', {
      ...v.toMap(),
    });
  }

  Future<Vinile?> getVinile(int id)async{
    final db  = await database;
    final maps= await db.query('collezioneVinili',
      where: 'id = ?',
      whereArgs: [id],
    );
    if(maps.isNotEmpty){
      return Vinile.fromMap(maps.first);
    }
    else{
      return null;
    }
  }

  Future<List<Vinile>> getCollezione() async {
    final db = await database;
    final maps = await db.query('collezioneVinili',
        orderBy: 'LOWER(titolo) ASC',
    );


    List<Vinile> lista= maps.map(Vinile.fromMap).toList();
    if(lista.isEmpty){
      logger.e("è vuota!\n\n\n");
    }
    else
      {
        logger.i("La lista è : ${lista.length} + ${lista.toString()} ");
      }
    return lista;
  }

  /// ultimi N vinili ordinati per data di inserimento (default 10)
  Future<List<Vinile>> getLastVinili({int limit = 10}) async {
    final db = await database;
    final maps = await db.query(
      'collezioneVinili',
      orderBy: 'datetime("creato_il") DESC',
      limit: limit,
    );
    List<Vinile> lista=maps.map(Vinile.fromMap).toList();
    if(lista.isEmpty){
      logger.e("è vuota!\n\n\n");
    }
    else
    {
      logger.i("La lista è : ${lista.length} + ${lista.toString()} ");
    }

    return lista;
  }

  /// un vinile casuale (o più di uno)
  Future<List<Vinile>> getRandomVinili({int limit = 6}) async {
    final db = await database;
    final maps = await db.rawQuery(
      'SELECT * FROM collezioneVinili ORDER BY RANDOM() LIMIT ?',
      [limit],
    );
    return maps.map(Vinile.fromMap).toList();
  }



  Future<int> eliminaVinile(Vinile vinile) async {
    final db = await database;
    return db.delete('collezioneVinili', where: 'id = ?', whereArgs: [vinile.id]);
  }

  Future<bool> modificaVinile(Vinile v) async {
    final db = await database;
    final result= await db.update('collezioneVinili', v.toMap(),
        where: 'id = ?',
        whereArgs: [v.id]);
   return result == 1;
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

  Future<List<Genere>> getGeneri() async{
    final db = await database;
    final maps = await db.query("generi");
    List<Genere> lista= maps.map(Genere.fromMap).toList();
    return lista;
  }

  Future<String?> getGenereNomeById(int idGenere) async {
    final db = await database; // Ottieni l'istanza del database

    // Esegui una query sulla tabella 'generi' filtrando per 'id'
    final List<Map<String, dynamic>> maps = await db.query(
      'generi',
      columns: ['nome'], // Seleziona solo la colonna 'nome'
      where: 'id = ?',
      whereArgs: [idGenere],
      limit: 1, // Ci aspettiamo solo un risultato per un dato ID
    );

    // Se troviamo un risultato, estrai il nome e restituiscilo
    if (maps.isNotEmpty) {
      return maps.first['nome'] as String;
    } else {
      // Se nessun genere con quell'ID è stato trovato, ritorna null
      return null;
    }
  }

  Future<int> inserisciGenere(String nome) async =>
      (await database).insert('generi', {'nome': nome.trim()});

  Future<List<Map<String, dynamic>>> getCategorieConConteggio() async =>
      (await database).rawQuery('''
      SELECT g.id, g.nome,
             SUM(COALESCE(v.quantita, 0)) AS conteggio
      FROM generi g
      LEFT JOIN collezioneVinili v ON v.genere = g.id
      GROUP BY g.id, g.nome
      ORDER BY g.nome;
    ''');

  Future<String> getGenere(int id) async{
    final db= await DatabaseHelper.instance.database;
    final maps= await db.query('generi',
      where:"id = ?",
      whereArgs:[id] ,
    );
    return maps.map(Genere.fromMap).first.nome;
  }

  Future<int?> controlloGenere(String? nome) async {
    if (nome == null || nome.trim().isEmpty) return null;

    final db = await database;
    final res = await db.query(
      'generi',
      where: 'nome = ?',
      whereArgs: [nome.trim()],
      limit: 1,
    );

    if (res.isNotEmpty) {
      return res.first['id'] as int; // già esiste
    }
    return null;
  }

  //Visto che ogni genere quando viene inserito nel DB riceve un proprio ID, possiamo gestirci gli ID come se fossero parte di un ENUM
  Future<List<Vinile>> getViniliByGenere(int idGenere) async {
    final maps = await (await database).query(
      'collezioneVinili',
      where: 'genere = ?', whereArgs: [idGenere],
      orderBy: 'creato_il DESC',
    );
    return maps.map(Vinile.fromMap).toList();
  }

  Future<void> elimina(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('generi', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> rinomina(int id, String nuovoNome) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('generi', {'nome': nuovoNome}, where: 'id = ?', whereArgs: [id]);
  }


  Future<void> aggiornaGenereVinile(int vinileId, int nuovoGenereId) async {
    final db = await database;
    await db.update('collezioneVinili', {'genere': nuovoGenereId},
        where: 'id = ?', whereArgs: [vinileId]);
  }

  /// Restituisce fino a 4 URL di copertine per un determinato genere, ordinate per data di inserimento (più recenti prima).
  Future<List<String>> getCopertineViniliByGenere(int idGenere, {int limit = 4}) async {
    final db = await database;
    final result = await db.query(
      'collezioneVinili',
      columns: ['immagine'],
      where: 'genere = ? AND immagine IS NOT NULL AND immagine != ""',
      whereArgs: [idGenere],
      orderBy: 'datetime(creato_il) DESC',
      limit: limit,
    );

    return result.map((row) => row['immagine'] as String).toList();
  }

  Future<String?> getGenerePiuComune() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT g.nome, COUNT(v.id) AS cnt
      FROM collezioneVinili v
      JOIN generi g ON v.genere = g.id
      GROUP BY v.genere
      ORDER BY cnt DESC
      LIMIT 1
    ''');
    return result.isNotEmpty ? result.first['nome'] as String? : null;
  }

}