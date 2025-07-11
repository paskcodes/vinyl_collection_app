import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/database/databasehelper.dart';

import '../categoria/genere.dart';
import '../vinile/condizione.dart';

class FiltroRicercaWidget extends StatefulWidget {
  final Function({
    String query,
    int? genere,
    Condizione? condizione,
    int? anno,
    bool soloPreferiti,
  })
  onFiltra;

  final String initialQuery;
  final int? initialGenere;
  final Condizione? initialCondizione;
  final int? initialAnno;
  final bool initialPreferiti;

  const FiltroRicercaWidget({
    super.key,
    required this.onFiltra,
    this.initialQuery = '',
    this.initialGenere,
    this.initialCondizione,
    this.initialAnno,
    this.initialPreferiti = false,
  });

  @override
  State<FiltroRicercaWidget> createState() => _FiltroRicercaWidgetState();
}

class _FiltroRicercaWidgetState extends State<FiltroRicercaWidget> {
  late TextEditingController _queryController;
  late TextEditingController _annoController;
  int? _genere;
  Condizione? _condizione;
  int? _anno;
  bool _soloPreferiti = false;
  List<Genere> _listaGeneri = [];

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.initialQuery);
    _annoController = TextEditingController(
      text: widget.initialAnno?.toString() ?? '',
    );
    _genere = widget.initialGenere;
    _condizione = widget.initialCondizione;
    _anno = widget.initialAnno;
    _soloPreferiti = widget.initialPreferiti;
    aggiornaGeneri();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _annoController.dispose();
    super.dispose();
  }

  Future<void> aggiornaGeneri() async {
    final listaMappe = await DatabaseHelper.instance.generiFiltrati();
    setState(() {
      _listaGeneri = listaMappe.map((m) => Genere.fromMap(m)).toList();
    });
  }

  void _applicaFiltro() {
    widget.onFiltra(
      query: _queryController.text,
      genere: _genere,
      condizione: _condizione,
      anno: _anno,
      soloPreferiti: _soloPreferiti,
    );
  }

  void _resetFiltri() {
    setState(() {
      _queryController.clear();
      _annoController.clear();
      _genere = null;
      _condizione = null;
      _anno = null;
      _soloPreferiti = false;
    });
    _applicaFiltro();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _queryController,
          decoration: const InputDecoration(
            labelText: 'Cerca titolo, artista, etichetta',
          ),
          onChanged: (_) => _applicaFiltro(),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Genere'),
                value:
                    _genere != null && _listaGeneri.any((g) => g.id == _genere)
                    ? _listaGeneri.firstWhere((g) => g.id == _genere).nome
                    : null,
                items: _listaGeneri
                    .map(
                      (g) =>
                          DropdownMenuItem(value: g.nome, child: Text(g.nome)),
                    )
                    .toList(),
                onChanged: (val) {
                  final genereSelezionato = _listaGeneri
                      .where((g) => g.nome == val)
                      .toList();
                  setState(() {
                    _genere = genereSelezionato.isNotEmpty
                        ? genereSelezionato.first.id
                        : null;
                    _applicaFiltro();
                  });
                },
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: DropdownButtonFormField<Condizione>(
                decoration: const InputDecoration(labelText: 'Condizione'),
                value: _condizione,
                items: Condizione.values
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.descrizione),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() => _condizione = val);
                  _applicaFiltro();
                },
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: TextField(
                controller: _annoController,
                decoration: const InputDecoration(labelText: 'Anno'),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  setState(() => _anno = int.tryParse(val));
                  _applicaFiltro();
                },
              ),
            ),
          ],
        ),
        // Sostituisci CheckboxListTile con SwitchListTile
        SwitchListTile(
          title: const Text('Solo preferiti'),
          value: _soloPreferiti,
          onChanged: (val) {
            setState(() => _soloPreferiti = val); // 'val' qui non sarà mai null
            _applicaFiltro();
          },
        ),
        TextButton.icon(
          onPressed: _resetFiltri,
          icon: const Icon(Icons.refresh),
          label: const Text('Reset filtri'),
        ),
        const Divider(thickness: 1),
      ],
    );
  }
}