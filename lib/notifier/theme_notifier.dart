import 'package:flutter/material.dart';

// Semplice classe "ValueNotifier" che mantiene salvato il tema corrente.
final ValueNotifier<ThemeMode> themeNotifier =
ValueNotifier<ThemeMode>(ThemeMode.light);