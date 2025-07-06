import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/screen/schermatamodifica.dart';
import '../vinile/vinile.dart';
import '../database/databasehelper.dart';

class DettaglioVinileCollezione extends StatefulWidget {
  final Vinile vinile;
  const DettaglioVinileCollezione({super.key, required this.vinile});

  @override
  State<DettaglioVinileCollezione> createState() => _DettaglioVinileCollezioneState();
}

class _DettaglioVinileCollezioneState extends State<DettaglioVinileCollezione> {
  late Vinile _vinileCorrente;

  @override
  void initState() {
    super.initState();
    _vinileCorrente = widget.vinile;
  }

  Future<void> _refreshVinileData() async {
    if (_vinileCorrente.id != null) {
      final updated = await DatabaseHelper.instance.getVinile(_vinileCorrente.id!);
      if (updated != null && mounted) {
        setState(() => _vinileCorrente = updated);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_vinileCorrente.titolo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _vinileCorrente.coverWidget,
            ),
          ),
          const SizedBox(height: 20),
          _InfoRow('Artista', _vinileCorrente.artista),
          _InfoRow('Anno', _vinileCorrente.anno?.toString() ?? '–'),
          _InfoRow('Etichetta', _vinileCorrente.etichettaDiscografica ?? '–'),
          FutureBuilder<String?>(
            future: _vinileCorrente.genereNome,
            builder: (context, snap) {
              final genere = snap.data ?? 'Non specificato';
              return _InfoRow('Genere', genere);
            },
          ),
          _InfoRow('Copie possedute', _vinileCorrente.copie?.toString() ?? '–'),
          _InfoRow('Condizione', _vinileCorrente.condizione?.descrizione ?? '–'),
          _InfoRow('Preferito', _vinileCorrente.preferito ? 'Sì' : 'No'),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'edit_${_vinileCorrente.id ?? UniqueKey()}',
            onPressed: () async {
              final modified = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => SchermataModifica(
                    vinile: _vinileCorrente,
                    suggested: false,
                  ),
                ),
              );
              if (modified == true) {
                await _refreshVinileData();
                if (mounted) Navigator.of(context).pop(true);
              }
            },
            child: const Icon(Icons.edit),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'delete_${_vinileCorrente.id ?? UniqueKey()}',
            onPressed: () async {
              final conferma = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
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
                await DatabaseHelper.instance.eliminaVinile(_vinileCorrente);
                if (mounted) Navigator.of(context).pop(true);
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
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
