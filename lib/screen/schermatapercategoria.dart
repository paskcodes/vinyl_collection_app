// lib/screen/schermata_vinili_genere.dart
import 'package:flutter/material.dart';
import '../database/databasehelper.dart';
import '../vinile/vinile.dart';
import '../screen/schermatamodifica.dart';
import '../screen/dettagliovinilecollezione.dart';
import '../utils/dimensioniSchermo.dart';

class SchermataViniliPerCategoria extends StatefulWidget {
  final int genereId;
  final String genereNome;
  const SchermataViniliPerCategoria({
    super.key,
    required this.genereId,
    required this.genereNome,
  });

  @override
  State<SchermataViniliPerCategoria> createState() =>
      _SchermataViniliPerCategoriaState();
}

class _SchermataViniliPerCategoriaState extends State<SchermataViniliPerCategoria> {
  late List<Vinile> _vinili = [];

  @override
  void initState() {
    super.initState();
    _carica();
  }

  Future<void> _carica() async {
    final list = await DatabaseHelper.instance.getViniliByGenere(widget.genereId);
    if (mounted) setState(() => _vinili = list);
  }

  Future<void> _elimina(Vinile v) async {
    await DatabaseHelper.instance.eliminaVinile(v);
    await _carica();
  }

  Future<void> _modifica(Vinile v) async {
    final mod = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => SchermataModifica(vinile: v, suggested: false)),
    );
    if (mod == true) await _carica();
  }

  Future<void> _apriDettaglio(Vinile v) async {
    final modElim = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DettaglioVinileCollezione(vinile: v)),
    );
    if (modElim == true) await _carica();
  }

  Future<void> _confermaElimina(Vinile v) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text('Eliminare \"${v.titolo}\"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
          TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('Elimina', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) await _elimina(v);
  }

  @override
  Widget build(BuildContext context) {
    final double leadingSize = context.screenWidth * 0.12;

    return Scaffold(
      appBar: AppBar(title: Text(widget.genereNome)),
      body: _vinili.isEmpty
          ? const Center(child: Text('Nessun vinile in questa categoria.'))
          : ListView.builder(
        itemCount: _vinili.length,
        itemBuilder: (_, i) {
          final v = _vinili[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              onTap: () => _apriDettaglio(v),
              leading: SizedBox(
                width: leadingSize,
                height: leadingSize,
                child: v.coverWidget,
              ),
              title: Text(v.titolo),
              subtitle: Text('${v.artista} (${v.anno ?? '—'})'),
              trailing: PopupMenuButton<String>(
                onSelected: (s) {
                  if (s == 'modifica') _modifica(v);
                  if (s == 'elimina') _confermaElimina(v);
                },
                itemBuilder: (_) => const [
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
