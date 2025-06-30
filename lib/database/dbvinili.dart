import 'dart:io';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


import '../vinile/vinile.dart';

class DatabaseHelper {
  static final _databaseName = "vinili.db";
  static final _databaseVersion = 1;

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if(_database != null) return _database!;
    _database= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Ottieni il percorso dove il database verrà salvato sul dispositivo
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _databaseName);

    // Controlla se il database esiste già nella directory dell'app
    bool exists = await databaseExists(path);

    if (!exists) {
      // Se il database non esiste, copia quello dall'asset
      print("Creazione di una nuova copia del database da 'assets/database/vinili.db'");

      // Assicurati che la directory esista
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        print("Errore durante la creazione della directory: $e");
      }

      // Carica il database come ByteData dal bundle degli asset
      ByteData data = await rootBundle.load(join("assets", "database", _databaseName));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Scrivi i byte nel percorso finale sul dispositivo
      await File(path).writeAsBytes(bytes, flush: true);
      print("Database copiato con successo in: $path");
    } else {
      print("Apertura del database esistente in: $path");
    }

    // Apri il database. Se è stato copiato, verrà aperto quello copiato.
    // Se _onCreate è specificato, verrà chiamato solo se il database non esisteva
    // e non è stato copiato, oppure se la versione è cambiata (necessitando un onUpgrade).
    // Nel tuo caso, se il database è pre-popolato, _onCreate non dovrebbe ricreare le tabelle.
    return await openDatabase(
      path,
      version: _databaseVersion,
      // Se il tuo database è già creato e popolato, l'onCreate dovrebbe essere vuoto
      // o gestire solo l'aggiunta di nuove tabelle in futuri aggiornamenti.
      // Non deve ricreare le tabelle che sono già presenti nel tuo .db pre-popolato.
      onCreate: (db, version) {
        // Qui potresti mettere codice per creare nuove tabelle
        // solo se _databaseVersion aumenta e il database non contiene già quella tabella
        // oppure gestire migrazioni future.
        // Per il tuo caso attuale con un db pre-popolato, puoi anche lasciare vuoto se le tabelle esistono già.
        return Future.value(); // Ritorna un Future completato
      },
      // Potresti voler aggiungere onUpgrade per gestire migrazioni future
      // onUpgrade: (db, oldVersion, newVersion) {
      //   // Logica per aggiornare lo schema del database
      // }
    );
  }


  /*Future<Database> _initDatabase() async {
    // Ottieni il percorso dove il database verrà salvato sul dispositivo
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _databaseName);

    // Apri il database.
    // Se il file 'vinili.db' non esiste a 'path', openDatabase lo creerà
    // e chiamerà automaticamente la funzione 'onCreate'.
    // Se esiste già, lo aprirà semplicemente.
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) {
        // Qui viene creata la tabella 'collezioneVinili'
        // Questo codice verrà eseguito SOLO la primissima volta che il database viene creato.
        print("Creazione della tabella 'collezioneVinili'...");
        return db.execute(
          'CREATE TABLE collezioneVinili(id INTEGER PRIMARY KEY AUTOINCREMENT,titolo TEXT NOT NULL,artista TEXT NOT NULL,anno INTEGER NOT NULL,genere INTEGER,etichettaDiscografica TEXT,quantita INTEGER,condizione INTEGER,immagine TEXT,preferito INTEGER)',
        );
      },
    );
  }*/

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

  Future<List<Vinile>> getLastVinili({int limit = 10}) async {
    final db = await database;
    final maps = await db.query(
      'collezioneVinili',
      orderBy: 'id DESC',
      limit: limit,
    );
    return maps.map(Vinile.fromMap).toList();
  }

  Future<List<Vinile>> getRandomVinili({int limit = 3}) async {
    final db = await database;
    final maps = await db.rawQuery(
      'SELECT * FROM collezioneVinili ORDER BY RANDOM() LIMIT ?',
      [limit],
    );
    return maps.map(Vinile.fromMap).toList();
  }


  Future<bool> vinileEsiste(Vinile vinile) async {
      final db= await DatabaseHelper.instance.database;
      final result= await db.query('collezioneVinili',
      where: 'titolo = ? AND artista = ? AND anno =?',
      whereArgs:[vinile.titolo,vinile.artista,vinile.anno],
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
      whereArgs: [vinile.titolo,vinile.artista,vinile.anno],
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
