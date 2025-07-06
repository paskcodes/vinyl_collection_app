import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/database/databasehelper.dart';
import 'package:vinyl_collection_app/components/genere_tile.dart';
import 'package:vinyl_collection_app/screen/schermatapercategoria.dart';
import 'package:vinyl_collection_app/utils/dimensioniSchermo.dart';

class SchermataCategorie extends StatefulWidget {
  const SchermataCategorie({super.key});

  @override
  State<SchermataCategorie> createState() => SchermataCategorieState();
}

class SchermataCategorieState extends State<SchermataCategorie> {
  List<Map<String, dynamic>>? _listaFiltrata;

  @override
  void initState() {
    super.initState();
    aggiornaGeneri();
  }

  Future<void> aggiornaGeneri() async {
    List<Map<String, dynamic>> listaCompleta =
    await DatabaseHelper.instance.getCategorieConConteggio();

    List<Map<String, dynamic>> filteredList = [];
    for (final Map<String, dynamic> genere in listaCompleta) {
      if ((genere['conteggio'] as int? ?? 0) > 0) {
        filteredList.add(genere);
      }
    }

    setState(() {
      _listaFiltrata = filteredList;
    });
  }

  Future<void> apriSchermata(int genereId,String genereNome) async {
    await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SchermataViniliPerCategoria(genereId: genereId, genereNome: genereNome)));
    aggiornaGeneri();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Le tue categorie'), // Il titolo della tua schermata
        centerTitle: true, // Centra il titolo nell'AppBar
      ),
      body: _listaFiltrata == null
          ? const Center(child: CircularProgressIndicator()) // Mostra caricamento
          : _listaFiltrata!.isEmpty
          ? const Center(child: Text("Aggiungi vinili per visualizzare le categorie.")) // Messaggio se vuoto
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          // Calcolo più robusto per childAspectRatio
          // Basato su una larghezza della card che è circa la metà dello schermo meno lo spazio tra le colonne.
          // L'altezza è stimata in base al contenuto della GenereTile.
          childAspectRatio: (context.screenWidth / 2 - 16) / (context.screenWidth * 0.4 + (context.shortestSide * 0.045 * 2) + (context.shortestSide * 0.03) + 8 + 4 + 12 + 12),
        ),
        itemCount: _listaFiltrata!.length,
        itemBuilder: (context, index) {
          final genereMap = _listaFiltrata![index];
          final int genereId = genereMap['id'] as int;
          final String nomeGenere = genereMap['nome'] as String;
          final int conteggio = genereMap['conteggio'] as int;

          return GenereTile(
            genereId: genereId,
            nomeGenere: nomeGenere,
            numeroVinili: conteggio,
            onTap: () => apriSchermata(genereId,nomeGenere),
          );
        },
      ),
    );
  }
}