library vinile_model;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/vinile/condizione.dart';
import 'package:vinyl_collection_app/vinile/genere.dart';

class Vinile {
  /* ---------- campi ---------- */
  final int? id;                    // PK autoincrement
  final String titolo;
  final String artista;             // ex “nomeArtista”
  final int anno;
  final Genere? genere;             // FK verso tabella generi (può essere null)
  final String? etichettaDiscografica;
  final int? quantita;
  final Condizione? condizione;
  final String? immagine;           // path locale o URL
  final bool preferito;
  final String? createdAt;          // ISO‑8601 (“2025‑06‑30T14:05:00”)

  /* ---------- costruttore ---------- */
  Vinile({
    this.id,
    required this.titolo,
    required this.artista,
    required this.anno,
    this.genere,
    this.etichettaDiscografica,
    this.quantita,
    this.condizione,
    this.immagine,
    this.preferito = false,
    String? createdAt,
  }):createdAt = createdAt ?? DateTime.now().toIso8601String() ;

  /* ---------- helper per la UI ---------- */
  /// Restituisce un widget immagine da usare ovunque (Network o File).
  Widget get coverWidget => immagine != null
      ? (immagine!.startsWith('http')
      ? Image.network(immagine!, fit: BoxFit.cover)
      : Image.file(File(immagine!), fit: BoxFit.cover))
      : const Icon(Icons.album, size: 40);

  /* ---------- serializzazione ---------- */
  Map<String, Object?> toMap() => {
    'id': id,
    'titolo': titolo,
    'artista': artista,
    'anno': anno,
    'genere': genere?.index,
    'etichetta_discografica': etichettaDiscografica,
    'quantita': quantita,
    'condizione': condizione?.index,
    'immagine': immagine,
    'preferito': preferito ? 1 : 0,
    "createdAt" : createdAt,
  };

  factory Vinile.fromMap(Map<String, dynamic> m) => Vinile(
    id: m['id'] as int?,
    titolo: m['titolo'] as String,
    artista: m['artista'] as String,
    anno: m['anno'] as int,
    genere: m['genere'] != null ? Genere.values[m['genere'] as int] : null,
    etichettaDiscografica: m['etichetta_discografica'] as String?,
    quantita: m['quantita'] as int?,
    condizione: m['condizione'] != null
        ? Condizione.values[m['condizione'] as int]
        : null,
    immagine: m['immagine'] as String?,
    preferito: (m['preferito'] as int? ?? 0) == 1,
    createdAt: m["createdAt"] as String?,
  );
}
