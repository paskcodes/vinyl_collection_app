import 'package:flutter/material.dart';

extension Dimensionischermo on BuildContext {
  /// Larghezza totale dello schermo
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Altezza totale dello schermo
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Lato più corto dello schermo (utile per layout basati sulla dimensione minore)
  double get shortestSide => MediaQuery.of(this).size.shortestSide;

  /// Lato più lungo dello schermo
  double get longestSide => MediaQuery.of(this).size.longestSide;

  /// Controlla se il dispositivo è in modalità orizzontale
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;

  /// Controlla se il dispositivo è in modalità verticale
  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;
}