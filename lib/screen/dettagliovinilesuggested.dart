import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/screen/schermatamodifica.dart';
import '../vinile/vinile.dart';

class DettaglioVinileSuggested extends StatefulWidget { // <--- Da StatelessWidget a StatefulWidget
  final Vinile vinile;
  const DettaglioVinileSuggested({super.key, required this.vinile});

  @override
  State<DettaglioVinileSuggested> createState() => _DettaglioVinileSuggestedState();
}

class _DettaglioVinileSuggestedState extends State<DettaglioVinileSuggested> { // <--- Nuova classe State
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.vinile.titolo)), // Usa widget.vinile
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Copertina
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: widget.vinile.coverWidget, // Usa widget.vinile
            ),
          ),
          const SizedBox(height: 20),

          _InfoRow('Artista', widget.vinile.artista), // Usa widget.vinile
          _InfoRow('Anno', widget.vinile.anno?.toString() ?? '–'), // Usa widget.vinile
          _InfoRow('Etichetta', widget.vinile.etichettaDiscografica ?? '–'), // Usa widget.vinile
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async { // <--- Aggiungi 'async' qui
          // Aspetta il risultato dalla SchermataModifica
          final bool? added = await Navigator.push<bool>( // <--- Aspetta un booleano
            context,
            MaterialPageRoute(
              builder: (context) => SchermataModifica(vinile: widget.vinile, suggested: true),
            ),
          );

          // Se l'elemento è stato aggiunto con successo, torna indietro segnalando true
          if (added == true) {
            if (mounted) { // Assicurati che il widget sia ancora montato
              Navigator.pop(context, true); // <--- Passa true alla HomeScreen
            }
          }
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