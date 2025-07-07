import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/components/genere_tile.dart';
import 'package:vinyl_collection_app/screen/schermatapercategoria.dart';
import 'package:vinyl_collection_app/utils/dimensionischermo.dart';

import '../categoria/genere.dart';

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
    List<Map<String, dynamic>> lista = await Genere.generiFiltrati();
    setState(() {
      _listaFiltrata = lista;
    });
  }

  Future<void> apriSchermata(int genereId,String genereNome) async {
    await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SchermataViniliPerCategoria(genereId: genereId, genereNome: genereNome)));
    aggiornaGeneri();
}
  // All'interno della classe SchermataCategorieState
  Widget _buildAddCategoryTile(BuildContext context) {
    final double cardWidth   = context.screenWidth * 0.4;
    final double iconSize    = cardWidth * 0.6;
    final double titleSize   = context.shortestSide * 0.045; // Stessa dimensione del titolo delle categorie
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: null,//aggiungere vai a aggiungi categorie
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: scheme.surfaceContainerHighest,
        child: Container(
          width: cardWidth,
          padding: const EdgeInsets.all(12),
          child: Column( // Usa Column per icona e testo
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline, // Un'icona 'add' con cerchio potrebbe essere più esplicita
                size: iconSize,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8), // Spazio tra icona e testo
              Text(
                'Nuova categoria',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: titleSize,
                  color: scheme.onSurfaceVariant, // Colore del testo adattivo
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        itemCount: _listaFiltrata!.length+1,
        itemBuilder: (context, index) {
          if(index==_listaFiltrata!.length){
            return _buildAddCategoryTile(context);
          }else{
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
          }
        },
      ),
    );
  }
}