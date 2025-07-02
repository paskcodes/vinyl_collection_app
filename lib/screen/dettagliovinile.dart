import 'package:flutter/material.dart';
import '../vinile/vinile.dart';

class DettaglioVinile extends StatelessWidget {
  final Vinile vinile;
  const DettaglioVinile({super.key, required this.vinile});

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
