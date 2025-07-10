library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/vinile/condizione.dart';

import '../database/databasehelper.dart';

class Vinile {
  /* ---------- campi ---------- */
  int? id;                    // PK autoincrement
  final String titolo;
  final String artista;
  final int? anno;
  final int? genere;                // FK verso tabella generi
  final String? etichettaDiscografica;
  final int? copie;
  final Condizione? condizione;
  final String? immagine;           // asset, file locale o URL
  bool preferito;
  final String creatoIl;            // ISO‑8601

  /* ---------- costruttore ---------- */
  Vinile({
    this.id,
    required this.titolo,
    required this.artista,
    this.anno,
    this.genere,
    this.etichettaDiscografica,
    this.copie,
    this.condizione = Condizione.nuovo,
    this.immagine,
    this.preferito = false,
    String? creatoIl,
  }) : creatoIl = creatoIl ?? DateTime.now().toIso8601String();

  /* ---------- helper per la UI ---------- */
  Widget get coverWidget {
    if (immagine == null) {
      return const Icon(Icons.album, size: 40);
    }
    if (immagine!.startsWith('http')) {
      return Image.network(immagine!, fit: BoxFit.cover);
    }
    if (immagine!.startsWith('/') || immagine!.startsWith('file://')) {
      return Image.file(File(immagine!.replaceFirst('file://', '')),
          fit: BoxFit.cover);
    }
    return Image.asset(immagine!, fit: BoxFit.cover);
  }

  /* ---------- serializzazione ---------- */
  Map<String, Object?> toMap() => {
    'id': id,
    'titolo': titolo,
    'artista': artista,
    'anno': anno,
    'genere': genere,
    'etichetta_discografica': etichettaDiscografica,
    'quantita': copie,
    'condizione': condizione?.name,    // salva la stringa
    'immagine': immagine,
    'preferito': preferito ? 1 : 0,
    'creato_il': creatoIl,
  };

  factory Vinile.fromMap(Map<String, dynamic> m) => Vinile(
    id: m['id'] as int?,
    titolo: m['titolo'] as String,
    artista: m['artista'] as String,
    anno: m['anno'] as int?,
    genere: m['genere'] as int?,
    etichettaDiscografica: m['etichetta_discografica'] as String?,
    copie: m['quantita'] as int?,
    condizione: Condizione.fromDb(m['condizione']?.toString()),
    immagine: m['immagine'] as String?,
    preferito: (m['preferito'] as int? ?? 0) == 1,
    creatoIl: m['creato_il'] as String?,
  );

  Future<String?> get genereNome async {
    if (genere == null) {
      return null; // O una stringa come 'Nessun Genere'
    }
    // Chiama il metodo di DatabaseHelper per ottenere il nome del genere
    return await DatabaseHelper.instance.getGenereNomeById(genere!);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // Stessa istanza
    if (other.runtimeType != runtimeType) return false; // Tipi diversi

    // Cast sicuro dell'altro oggetto a Vinile
    final Vinile otherVinile = other as Vinile;

    // Confronta tutti i campi rilevanti per l'uguaglianza logica
    // L'ID non viene confrontato qui, perché due vinili possono essere logicamente uguali
    // anche se uno ha un ID (già salvato) e l'altro no (appena creato/modificato)
    return titolo == otherVinile.titolo &&
        artista == otherVinile.artista &&
        anno == otherVinile.anno &&
        genere == otherVinile.genere &&
        etichettaDiscografica == otherVinile.etichettaDiscografica &&
        copie == otherVinile.copie &&
        condizione == otherVinile.condizione &&
        immagine == otherVinile.immagine && // Confronta anche l'immagine
        preferito == otherVinile.preferito;
    // creatoIl non viene confrontato perché è un timestamp di creazione
  }

  @override
  int get hashCode {
    // Genera un hash code basato sugli stessi campi usati per equals
    return Object.hash(
      titolo,
      artista,
      anno,
      genere,
      etichettaDiscografica,
      copie,
      condizione,
      immagine,
      preferito,
    );
  }


}
