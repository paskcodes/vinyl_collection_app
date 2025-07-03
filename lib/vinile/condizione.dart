enum Condizione{
  Nuovo, Usato, DaRestaurare;

  static Condizione fromDb(String? s) =>
      Condizione.values.firstWhere(
            (e) => e.name == s,
        orElse: () => Condizione.Nuovo,
      );
}