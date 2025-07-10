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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vinile.titolo),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Cover con effetto vetrina
          Center(
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: AspectRatio(
                aspectRatio: 1,
                child: widget.vinile.coverWidget,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Box informativi in stile moderno
          _ModernInfoBox(
            icon: Icons.person,
            label: 'Artista',
            value: widget.vinile.artista,
          ),
          _ModernInfoBox(
            icon: Icons.calendar_today,
            label: 'Anno',
            value: widget.vinile.anno?.toString() ?? '–',
          ),
          _ModernInfoBox(
            icon: Icons.album,
            label: 'Etichetta',
            value: widget.vinile.etichettaDiscografica ?? '–',
          ),
          FutureBuilder<String?>(
            future: DatabaseHelper.instance.getGenereNomeById(widget.vinile.genere ?? -1),
            builder: (context, snapshot) {
              String value;
              if (snapshot.connectionState == ConnectionState.waiting) {
                value = 'Caricamento...';
              } else if (snapshot.hasError) {
                value = 'Errore';
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                value = 'Sconosciuto';
              } else {
                value = snapshot.data!;
              }

              return _ModernInfoBox(
                icon: Icons.category,
                label: 'Genere',
                value: value,
              );
            },
          ),
        ],
      ),

      // Pulsante coerente graficamente con DettaglioVinileCollezione
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: FilledButton.icon(
          icon: const Icon(Icons.playlist_add),
          label: const Text('Aggiungi alla collezione'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
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
      ),
    );
  }
}

// BOX COERENTE con DettaglioVinileCollezione
class _ModernInfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const _ModernInfoBox({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: iconColor ?? theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}