import 'dart:core';
import 'dart:ffi';
import 'dart:ui';

import 'package:vinyl_collection_app/vinile/Condizione.dart';
import 'package:vinyl_collection_app/vinile/Genere.dart';

class Vinile{
  String _titolo;
  String _nomeArtista;
  int _anno;
  Genere _genere;
  String _etichetta_discografica;
  int _quantita;
  Condizione _condizione;
  Image? _immagine;

  Vinile(
      this._titolo, this._nomeArtista, this._anno,
      this._genere, this._etichetta_discografica,
      this._quantita, this._condizione,
      [Image? immagine]  // parametro opzionale
  ) : _immagine = immagine;


  Condizione get condizione => _condizione;

  set condizione(Condizione value) {
    _condizione = value;
  }

  int get quantita => _quantita;

  set quantita(int value) {
    _quantita = value;
  }

  String get etichetta_discografica => _etichetta_discografica;

  set etichetta_discografica(String value) {
    _etichetta_discografica = value;
  }

  Genere get genere => _genere;

  set genere(Genere value) {
    _genere = value;
  }

  int get anno => _anno;

  set anno(int value) {
    _anno = value;
  }

  String get nomeArtista => _nomeArtista;

  set nomeArtista(String value) {
    _nomeArtista = value;
  }

  String get titolo => _titolo;

  set titolo(String value) {
    _titolo = value;
  }

  Image? get immagine => _immagine;

  set immagine(Image? immagine) {
    _immagine = immagine;
  }

}