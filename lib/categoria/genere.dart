import '../database/databasehelper.dart';

class Genere{
  final int? id;
  final String nome;

  Genere({this.id, required this.nome});

  factory Genere.fromMap(Map<String, dynamic> m) =>
      Genere(id: m['id'] as int?, nome: m['nome'] as String);

  Map<String, Object?> toMap() => {
    'id': id,
    'nome': nome,
  };

  static Future<List<Map<String, dynamic>>> generiFiltrati() async {
    List<Map<String, dynamic>> listaCompleta =
    await DatabaseHelper.instance.getCategorieConConteggio();

    List<Map<String, dynamic>> listaFiltrata = [];
    for (final Map<String, dynamic> genere in listaCompleta) {
      if ((genere['conteggio'] as int? ?? 0) > 0) {
        listaFiltrata.add(genere);
      }
    }
    return listaFiltrata;
  }

  static Future<List<Map<String, dynamic>>> tuttiGeneri() async {
    return await DatabaseHelper.instance.getCategorieConConteggio();
  }

  Genere copyWith({int? id, String? nome}) {
    return Genere(
      id: id ?? this.id,
      nome: nome ?? this.nome,
    );
  }

}

