import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/database/databasehelper.dart';
import 'package:vinyl_collection_app/screen/schermatamodifica.dart';
import '../vinile/vinile.dart';

class DettaglioVinileSuggested extends StatefulWidget {
  final Vinile vinile;
  const DettaglioVinileSuggested({super.key, required this.vinile});

  @override
  State<DettaglioVinileSuggested> createState() => _DettaglioVinileSuggestedState();
}

class _DettaglioVinileSuggestedState extends State<DettaglioVinileSuggested> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.vinile.titolo)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Copertina grande
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 220,
                height: 220,
                child: widget.vinile.coverWidget,
              ),
            ),
          ),
          const SizedBox(height: 24),

          _InfoRow('Artista', widget.vinile.artista, textTheme),
          _InfoRow('Anno', widget.vinile.anno?.toString() ?? '—', textTheme),
          _InfoRow('Etichetta', widget.vinile.etichettaDiscografica ?? '—', textTheme),

          FutureBuilder<String?>(
            future: DatabaseHelper.instance.getGenereNomeById(widget.vinile.genere ?? -1),
            builder: (context, snapshot) {
              String value;
              if (snapshot.connectionState == ConnectionState.waiting) {
                value = 'Caricamento...';
              } else if (snapshot.hasError) {
                value = 'Errore';
              } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                value = 'Sconosciuto';
              } else {
                value = snapshot.data!;
              }
              return _InfoRow('Genere', value, textTheme);
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat
      ,
      floatingActionButton: FilledButton.icon(
        icon: const Icon(Icons.playlist_add),
        label: const Text('Aggiungi alla collezione'),
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => SchermataModifica(vinile: widget.vinile, suggested: true),
            ),
          );
          if (added == true && mounted) Navigator.pop(context, true);
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextTheme textTheme;
  const _InfoRow(this.label, this.value, this.textTheme);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value, style: textTheme.bodyMedium)),
      ],
    ),
  );
}