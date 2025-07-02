import 'package:flutter/material.dart';
import '../vinile/vinile.dart';
import '../database/databasehelper.dart';

class DettaglioVinile extends StatelessWidget {
  final Vinile vinile;
  const DettaglioVinile({super.key, required this.vinile});

  Future<void> _aggiungiAllaCollezione(BuildContext context) async {
    if(await DatabaseHelper.instance.vinileEsiste(vinile)){
      showDialog(context: context,
          builder: (BuildContext context){
            return AlertDialog(
              title: Text("Attenzione!"),
              content: const Text("Hai già questo vinile nella tua collezione."),
              actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(), child: const Text("Ok"))],
            );
          }
      );
    }else{
      await DatabaseHelper.instance.aggiungiVinile(vinile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vinile aggiunto alla collezione')),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(vinile.titolo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Copertina
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: vinile.coverWidget,
            ),
          ),
          const SizedBox(height: 20),

          _InfoRow('Artista', vinile.artista),
          _InfoRow('Anno', vinile.anno?.toString() ?? '–'),
          _InfoRow('Etichetta', vinile.etichettaDiscografica ?? '–'),
          _InfoRow('Genere (id)', vinile.genere?.toString() ?? '–'),
          _InfoRow('Quantità', vinile.quantita?.toString() ?? '–'),
          _InfoRow('Condizione', vinile.condizione.name),
          _InfoRow('Preferito', vinile.preferito ? 'Sì' : 'No'),
          _InfoRow('Creato il', vinile.creatoIl),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _aggiungiAllaCollezione(context),
        icon: const Icon(Icons.playlist_add),
        label: const Text('Aggiungi'),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
