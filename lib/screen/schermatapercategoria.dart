import 'package:flutter/material.dart';
import '../categoria/genere.dart';
import '../database/databasehelper.dart';
import '../vinile/vinile.dart';
import '../screen/schermatamodifica.dart';
import '../screen/dettagliovinilecollezione.dart';
import '../utils/dimensionischermo.dart';

class SchermataViniliPerCategoria extends StatefulWidget {
  final int genereId;
  final String genereNome;

  const SchermataViniliPerCategoria({
    super.key,
    required this.genereId,
    required this.genereNome,
  });

  @override
  State<SchermataViniliPerCategoria> createState() => _SchermataViniliPerCategoriaState();
}

class _SchermataViniliPerCategoriaState extends State<SchermataViniliPerCategoria> {
  late List<Vinile> _vinili = [];
  Set<int> _viniliSelezionati = {};
  late String _nomeGenere;

  bool get _modalitaSelezione => _viniliSelezionati.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nomeGenere = widget.genereNome;
    _carica();
  }

  Future<void> _carica() async {
    final list = await DatabaseHelper.instance.getViniliByGenere(widget.genereId);
    if (mounted) setState(() => _vinili = list);
  }

  void _toggleSelezione(int vinileId) {
    setState(() {
      if (_viniliSelezionati.contains(vinileId)) {
        _viniliSelezionati.remove(vinileId);
      } else {
        _viniliSelezionati.add(vinileId);
      }
    });
  }

  void _selezionaTutti() {
    setState(() {
      _viniliSelezionati = _vinili.map((v) => v.id!).toSet();
    });
  }

  void _deselezionaTutti() {
    setState(() => _viniliSelezionati.clear());
  }

  Future<void> _eliminaMultipli() async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text('Vuoi eliminare ${_viniliSelezionati.length} vinili selezionati?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Elimina', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (conferma == true) {
      for (final id in _viniliSelezionati) {
        final vinile = _vinili.firstWhere((v) => v.id == id);
        await DatabaseHelper.instance.eliminaVinile(vinile);
      }
      _viniliSelezionati.clear();
      await _carica();
    }
  }

  Future<void> _cambiaGenereMultiplo() async {
    final nuovoGenereId = await showDialog<int>(
      context: context,
      builder: (_) => _DialogSelezioneGenere(),
    );

    if (nuovoGenereId != null) {
      for (final id in _viniliSelezionati) {
        final vinile = _vinili.firstWhere((v) => v.id == id);
        await DatabaseHelper.instance.aggiornaGenereVinile(vinile.id!, nuovoGenereId);
      }
      _viniliSelezionati.clear();
      await _carica();
    }
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
        content: Text('Eliminare "${v.titolo}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Elimina', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) await DatabaseHelper.instance.eliminaVinile(v);
    await _carica();
  }

  Future<void> _rinominaGenere() async {
    final TextEditingController controller = TextEditingController(text: _nomeGenere);
    final generiEsistenti = await DatabaseHelper.instance.getGeneri();

    final nuovoNome = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Rinomina categoria"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nuovo nome categoria',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
          ElevatedButton(
            onPressed: () {
              final input = controller.text.trim();
              if (input.isEmpty) return;
              Navigator.pop(context, input);
            },
            child: const Text("Salva"),
          ),
        ],
      ),
    );

    if (nuovoNome != null && nuovoNome != _nomeGenere.trim()) {
      final giaEsiste = generiEsistenti.any((g) => g.nome.toLowerCase() == nuovoNome.toLowerCase());

    if (giaEsiste) {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Esiste già una categoria con questo nome.")),
    );
    return;
    }

    await DatabaseHelper.instance.rinominaCategoria(widget.genereId, nuovoNome);
    setState(() => _nomeGenere = nuovoNome);
  }
  }


  @override
  Widget build(BuildContext context) {
    final double leadingSize = context.screenWidth * 0.12;

    return Scaffold(
      appBar: AppBar(
        title: Text(_modalitaSelezione ? '${_viniliSelezionati.length} selezionati' : _nomeGenere),
        actions: _modalitaSelezione
            ? [
          IconButton(icon: const Icon(Icons.select_all), onPressed: _selezionaTutti),
          IconButton(icon: const Icon(Icons.remove_done), onPressed: _deselezionaTutti),
          IconButton(icon: const Icon(Icons.category), onPressed: _cambiaGenereMultiplo),
          IconButton(icon: const Icon(Icons.delete), onPressed: _eliminaMultipli),
        ]
            : [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _rinominaGenere,
            tooltip: 'Rinomina categoria',
          )
        ],
      ),
      body: _vinili.isEmpty
          ? const Center(child: Text('Nessun vinile in questa categoria.'))
          : ListView.builder(
        itemCount: _vinili.length,
        itemBuilder: (_, i) {
          final v = _vinili[i];
          final selezionato = _viniliSelezionati.contains(v.id);
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              onTap: () => _modalitaSelezione ? _toggleSelezione(v.id!) : _apriDettaglio(v),
              onLongPress: () => _toggleSelezione(v.id!),
              selected: selezionato,
              selectedTileColor: Colors.blue.withValues(),
              leading: SizedBox(
                width: leadingSize,
                height: leadingSize,
                child: v.coverWidget,
              ),
              title: Text(v.titolo),
              subtitle: Text('${v.artista} (${v.anno ?? '—'})'),
              trailing: _modalitaSelezione
                  ? Checkbox(
                value: selezionato,
                onChanged: (_) => _toggleSelezione(v.id!),
              )
                  : PopupMenuButton<String>(
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

class _DialogSelezioneGenere extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Genere>>(
      future: DatabaseHelper.instance.getGeneri(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final generi = snapshot.data!;

        return AlertDialog(
          title: const Text("Scegli un genere"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: generi.length,
              itemBuilder: (_, index) => ListTile(
                title: Text(generi[index].nome),
                onTap: () => Navigator.pop(context, generi[index].id),
              ),
            ),
          ),
        );
      },
    );
  }
}
