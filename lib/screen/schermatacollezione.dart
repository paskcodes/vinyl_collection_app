import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/database/databasehelper.dart';
import 'package:vinyl_collection_app/screen/schermatamodifica.dart';
import 'package:vinyl_collection_app/screen/dettagliovinilecollezione.dart'; // Importa la schermata dettaglio
import 'package:vinyl_collection_app/utils/dimensioniSchermo.dart';
import 'package:vinyl_collection_app/vinile/vinile.dart';

class SchermataCollezione extends StatefulWidget {
  const SchermataCollezione({super.key});

  @override
  State<SchermataCollezione> createState() => SchermataCollezioneState();
}

class SchermataCollezioneState extends State<SchermataCollezione> {
  late List<Vinile> _listaVinili = [];

  @override
  void initState() {
    super.initState();
    print("carico l'initstate");
    caricaVinili();
  }

  Future<void> caricaVinili() async {
    print("Provo a caricre i vinili in schermata collezione");
    final listaVinili = await DatabaseHelper.instance.getCollezione();
    setState(() {
      _listaVinili = listaVinili;
    });
  }

  Future<void> _rimuoviVinile(Vinile vinile) async {
    await DatabaseHelper.instance.eliminaVinile(vinile);
    await caricaVinili();
  }

  void _modificaVinile(Vinile vinile) async {
    final modificato = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchermataModifica(vinile: vinile, suggested: false),
      ),
    );
    if (modificato == true) {
      await caricaVinili();
    }
  }

  Future<void> _confermaEliminaVinile(Vinile vinile) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text('Sei sicuro di voler eliminare "${vinile.titolo}" dalla collezione?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (conferma == true) {
      await _rimuoviVinile(vinile);
    }
  }

  Future<void> _apriDettaglioVinile(Vinile vinile) async {
    final eliminato = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DettaglioVinileCollezione(vinile: vinile),
      ),
    );

    if (eliminato == true) {
      // Se è stato eliminato, ricarica la lista
      await caricaVinili();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Puoi definire le dimensioni qui una volta, se le usi più volte.
    // Esempio: larghezza dell'immagine leading proporzionale allo schermo
    final double leadingImageSize = context.screenWidth * 0.12; // Esempio: 12% della larghezza dello schermo
    return Scaffold(
      appBar: AppBar(
        title: const Text("La tua collezione"),
      ),
      body: _listaVinili.isEmpty
          ? const Center(child: Text("Aggiungi un vinile"))
          : ListView.builder(
        itemCount: _listaVinili.length,
        itemBuilder: (context, indice) {
          final vinile = _listaVinili[indice];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              onTap: () => _apriDettaglioVinile(vinile),
              leading: SizedBox(
                width: leadingImageSize, // Usa la dimensione calcolata
                height: leadingImageSize, // Usa la stessa dimensione per un'immagine quadrata
                child: vinile.coverWidget,
              ),
              title: Text(vinile.titolo),
              subtitle: Text('${vinile.artista} (${vinile.anno})'),
              trailing: PopupMenuButton<String>(
                onSelected: (scelta) {
                  if (scelta == 'modifica') {
                    _modificaVinile(vinile);
                  } else if (scelta == 'elimina') {
                    _confermaEliminaVinile(vinile);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'modifica', child: Text('Modifica')),
                  PopupMenuItem(value: 'elimina', child: Text('Elimina')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
