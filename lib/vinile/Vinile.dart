import 'dart:core';
import 'dart:ui';
import 'package:flutter/material.dart';


import 'package:vinyl_collection_app/vinile/Condizione.dart';
import 'package:vinyl_collection_app/vinile/Genere.dart';

class Vinile{
  String _titolo;
  String _nomeArtista;
  int _anno;
  Genere _genere;
  String _etichettaDiscografica;
  int _quantita;
  Condizione _condizione;
  Image _immagine;
  bool _preferito;

  Vinile(
      this._titolo, this._nomeArtista, this._anno,
      this._genere, this._etichettaDiscografica,
      this._quantita, this._condizione,
      String urlImmagine,
      {bool preferito=false}
      ) : _immagine = Image.network(urlImmagine),
          _preferito = preferito;


  Condizione get condizione => _condizione;

  set condizione(Condizione value) {
    _condizione = value;
  }

  int get quantita => _quantita;

  set quantita(int value) {
    _quantita = value;
  }

  String get etichetta_discografica => _etichettaDiscografica;

  set etichetta_discografica(String value) {
    _etichettaDiscografica = value;
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

  set preferito(bool preferito){
    _preferito=preferito;
  }

  bool get preferito => _preferito;
}