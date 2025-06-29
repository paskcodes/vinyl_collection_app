import 'dart:core';
import 'package:vinyl_collection_app/vinile/condizione.dart';
import 'package:vinyl_collection_app/vinile/genere.dart';
import 'package:flutter/material.dart';

class Vinile{
  final String titolo;
  final String nomeArtista;
  final int anno;
  final Genere genere;
  final String etichettaDiscografica;
  final int quantita;
  final Condizione condizione;
  final Image immagine;
  final bool preferito;
  int ?id;

  Vinile({
    required this.titolo,
    required this.nomeArtista,
    required this.anno,
    required this.genere, 
    required this.etichettaDiscografica,
    required this.quantita,
    required this.condizione,
    required String urlImmagine,
    this.preferito = false, int? id
    }
  ) : immagine = Image.network(urlImmagine);

Map<String, Object?> toMap() {
    return {
      'id' : id,
      'titolo': titolo,
      'nomeArtista': nomeArtista,
      'anno': anno,
      'genere': genere.index, // enum → int
      'etichettaDiscografica': etichettaDiscografica,
      'quantita': quantita,
      'condizione': condizione.index, // enum → int
      'immagineUrl': immagine,
      'preferito': preferito ? 1 : 0,
    };
  }

  factory Vinile.fromMap(Map<String, dynamic> map) {
    return Vinile(
      id: map['id'],
      titolo: map['titolo'],
      nomeArtista: map['nome_artista'],
      anno: map['anno'],
      genere: Genere.values[map['genere']],
      etichettaDiscografica: map['etichetta_discografica'],
      quantita: map['quantita'],
      condizione: Condizione.values[map['condizione']],
      urlImmagine: (map['immagine']),
      preferito: map['preferito'] == 1,
    );
  }
}