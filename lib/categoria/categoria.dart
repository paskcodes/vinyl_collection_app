import 'dart:io';
import 'package:flutter/material.dart';

class Categoria{
  final int? i;
  final String nome;
  final String? descrizione;
  final String? colore;

Categoria({this.i,
  required this.nome,
  this.descrizione,
  String? colore
}
) : colore = colore ?? "0xFFEEEEEE";



}