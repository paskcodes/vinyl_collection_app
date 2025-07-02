class Genere{
  final int? id;
  final String nome;

  Genere({this.id,
    required this.nome,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'nome': nome,
  };

  factory Genere.fromMap(Map<String, dynamic> m) => Genere(
    id: m['id'] as int?,
    nome: m['nome'] as String,
  );
}

