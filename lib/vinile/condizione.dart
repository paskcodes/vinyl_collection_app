enum Condizione {
  nuovo,
  usato,
  daRestaurare;

  String get descrizione {
    switch (this) {
      case Condizione.nuovo:
        return 'Nuovo';
      case Condizione.usato:
        return 'Usato';
      case Condizione.daRestaurare:
        return 'Da restaurare';
    }
  }

  static Condizione fromDb(String? s) => Condizione.values.firstWhere(
    (e) => e.name == s,
    orElse: () => Condizione.nuovo,
  );
}