library vinile_model;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/vinile/condizione.dart';

class Vinile {
  /* ---------- campi ---------- */
  int? id;                    // PK autoincrement
  final String titolo;
  final String artista;
  final int? anno;
  final int? genere;                // FK verso tabella generi
  final String? etichettaDiscografica;
  final int? quantita;
  final Condizione condizione;
  final String? immagine;           // asset, file locale o URL
  final bool preferito;
  final String creatoIl;            // ISO‑8601

  /* ---------- costruttore ---------- */
  Vinile({
    this.id,
    required this.titolo,
    required this.artista,
    this.anno,
    this.genere,
    this.etichettaDiscografica,
    this.quantita,
    this.condizione = Condizione.Nuovo,
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
    'quantita': quantita,
    'condizione': condizione.name,    // salva la stringa
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
    quantita: m['quantita'] as int?,
    condizione: Condizione.fromDb(m['condizione'] as String?),
    immagine: m['immagine'] as String?,
    preferito: (m['preferito'] as int? ?? 0) == 1,
    creatoIl: m['creato_il'] as String?,
  );
}
