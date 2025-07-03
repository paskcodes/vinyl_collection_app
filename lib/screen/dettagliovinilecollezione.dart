import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/screen/schermatamodifica.dart';
import '../vinile/vinile.dart';
import '../database/databasehelper.dart';

class DettaglioVinileCollezione extends StatelessWidget {
  final Vinile vinile;
  const DettaglioVinileCollezione({super.key, required this.vinile});

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
          _InfoRow('Genere', vinile.genere?.toString() ?? '–'),
          _InfoRow('Quantità', vinile.quantita?.toString() ?? '–'),
          _InfoRow('Condizione', vinile.condizione!.name),
          _InfoRow('Preferito', vinile.preferito ? 'Sì' : 'No'),
        ],
      ),
      floatingActionButton: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'edit',  // serve per distinguere i bottoni
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SchermataModifica(vinile: vinile, suggested: false)),
            );
          },
          child: const Icon(Icons.edit),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'delete',
          onPressed: () async {
            final conferma = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Conferma eliminazione'),
                content: const Text('Sei sicuro di voler eliminare questo vinile?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Annulla'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Elimina'),
                  ),
                ],
              ),
            );

            if (conferma == true) {
              // qui metti la logica per eliminare il vinile, ad es.:
              await DatabaseHelper.instance.eliminaVinile(vinile);
              Navigator.of(context).pop(true); // torni indietro dopo eliminazione
            }
          },
          child: const Icon(Icons.delete),
        ),
      ],
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
