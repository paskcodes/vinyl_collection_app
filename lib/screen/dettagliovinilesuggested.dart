import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/screen/schermatamodifica.dart';
import '../vinile/vinile.dart';

class DettaglioVinileSuggested extends StatelessWidget {
  final Vinile vinile;
  const DettaglioVinileSuggested({super.key, required this.vinile});

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
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          Navigator.push(context,MaterialPageRoute(
              builder: (context) => SchermataModifica(vinile: vinile,suggested: true,))
          );
        },
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
