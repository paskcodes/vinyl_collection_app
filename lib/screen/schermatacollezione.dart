import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/database/databasehelper.dart';
import 'package:vinyl_collection_app/screen/schermataanalisivinili.dart';
import 'package:vinyl_collection_app/screen/schermatamodifica.dart';
import 'package:vinyl_collection_app/screen/dettagliovinilecollezione.dart';
import 'package:vinyl_collection_app/utils/dimensionischermo.dart';
import 'package:vinyl_collection_app/vinile/vinile.dart';
import '../components/filtroricercawidget.dart';
import '../vinile/condizione.dart';

class SchermataCollezione extends StatefulWidget {
  const SchermataCollezione({super.key});

  @override
  State<SchermataCollezione> createState() => SchermataCollezioneState();
}

class SchermataCollezioneState extends State<SchermataCollezione> {
  late List<Vinile> _listaVinili = [];
  late List<Vinile> _tuttiIVinili = [];
  bool _mostraFiltri = false;

  // Filtri
  String _query = '';
  int? _genereId;
  Condizione? _condizione;
  int? _anno;
  bool _soloPreferiti = false;

  // Selezione multipla
  bool _modalitaSelezione = false;
  final Set<Vinile> _viniliSelezionati = {};

  @override
  void initState() {
    super.initState();
    caricaVinili();
  }

  Future<void> caricaVinili() async {
    final listaVinili = await DatabaseHelper.instance.getCollezione();
    setState(() {
      _tuttiIVinili = listaVinili;
      _listaVinili = List.from(_tuttiIVinili);
      _deselezionaTutti(); // reset selezione dopo caricamento
    });
  }

  void _filtraLocalmente({
    String query = '',
    int? genere,
    Condizione? condizione,
    int? anno,
    bool soloPreferiti = false,
  }) {
    setState(() {
      _query = query;
      _genereId = genere;
      _condizione = condizione;
      _anno = anno;
      _soloPreferiti = soloPreferiti;

      _listaVinili = _tuttiIVinili.where((vinile) {
        final matchQuery =
            _query.isEmpty ||
            vinile.titolo.toLowerCase().contains(_query.toLowerCase()) ||
            vinile.artista.toLowerCase().contains(_query.toLowerCase()) ||
            vinile.etichettaDiscografica?.toLowerCase().contains(
                  _query.toLowerCase(),
                ) ==
                true;

        final matchGenere = _genereId == null || vinile.genere == _genereId;
        final matchCondizione =
            _condizione == null || vinile.condizione == _condizione;
        final matchAnno = _anno == null || vinile.anno == _anno;
        final matchPreferiti = !_soloPreferiti || vinile.preferito == true;

        return matchQuery &&
            matchGenere &&
            matchCondizione &&
            matchAnno &&
            matchPreferiti;
      }).toList();
    });
  }

  void _toggleFiltroRicerca() {
    setState(() {
      _mostraFiltri = !_mostraFiltri;
    });
  }

  void _toggleSelezioneVinile(Vinile vinile) {
    setState(() {
      if (_viniliSelezionati.contains(vinile)) {
        _viniliSelezionati.remove(vinile);
      } else {
        _viniliSelezionati.add(vinile);
      }
      _modalitaSelezione = _viniliSelezionati.isNotEmpty;
    });
  }

  void _selezionaTutti() {
    setState(() {
      _viniliSelezionati
        ..clear()
        ..addAll(_listaVinili);
      _modalitaSelezione = true;
    });
  }

  void _deselezionaTutti() {
    setState(() {
      _viniliSelezionati.clear();
      _modalitaSelezione = false;
    });
  }

  Future<void> _eliminaSelezionati() async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text(
          'Vuoi eliminare ${_viniliSelezionati.length} vinili selezionati?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (conferma == true) {
      for (final vinile in _viniliSelezionati) {
        await DatabaseHelper.instance.eliminaVinile(vinile);
      }
      await caricaVinili();
    }
  }

  Future<void> _confermaEliminaVinile(Vinile vinile) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text(
          'Sei sicuro di voler eliminare "${vinile.titolo}" dalla collezione?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (conferma == true) {
      await DatabaseHelper.instance.eliminaVinile(vinile);
      await caricaVinili();
    }
  }

  void _modificaVinile(Vinile vinile) async {
    final modificato = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SchermataModifica(vinile: vinile, suggested: false),
      ),
    );
    if (modificato == true) {
      await caricaVinili();
    }
  }

  Future<void> _apriDettaglioVinile(Vinile vinile) async {
    final eliminato = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DettaglioVinileCollezione(vinile: vinile),
      ),
    );
    if (eliminato == true) {
      await caricaVinili();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double leadingImageSize = context.screenWidth * 0.12;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _modalitaSelezione
              ? '${_viniliSelezionati.length} selezionati'
              : 'La tua collezione',
        ),
        leading: _modalitaSelezione
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _deselezionaTutti,
              )
            : null,
        actions: [
          if (!_modalitaSelezione) ...[
            if (_tuttiIVinili
                .isNotEmpty) // <-- solo se ci sono vinili nella collezione
              IconButton(
                icon: const Icon(Icons.analytics),
                tooltip: 'Analisi vinili',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AnalisiViniliScreen(),
                    ),
                  );
                },
              ),
            IconButton(
              icon: Icon(_mostraFiltri ? Icons.close : Icons.search),
              tooltip: 'Filtri di ricerca',
              onPressed: _toggleFiltroRicerca,
            ),
          ] else ...[
            IconButton(
              tooltip: 'Seleziona tutti',
              icon: const Icon(Icons.select_all),
              onPressed: _selezionaTutti,
            ),
            IconButton(
              tooltip: 'Deseleziona tutti',
              icon: const Icon(Icons.remove_done),
              onPressed: _deselezionaTutti,
            ),
            IconButton(
              tooltip: 'Elimina selezionati',
              icon: const Icon(Icons.delete),
              onPressed: _eliminaSelezionati,
            ),
          ],
        ],
      ),

      body: Column(
        children: [
          if (_mostraFiltri)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: FiltroRicercaWidget(
                initialQuery: _query,
                initialGenere: _genereId,
                initialCondizione: _condizione,
                initialAnno: _anno,
                initialPreferiti: _soloPreferiti,
                onFiltra: _filtraLocalmente,
              ),
            ),
          Expanded(
            child: _listaVinili.isEmpty
                ? const Center(child: Text("Aggiungi un vinile"))
                : ListView.builder(
                    itemCount: _listaVinili.length,
                    itemBuilder: (context, indice) {
                      final vinile = _listaVinili[indice];
                      final selezionato = _viniliSelezionati.contains(vinile);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        color: selezionato ? Colors.blue.shade100 : null,
                        child: ListTile(
                          onTap: () {
                            if (_modalitaSelezione) {
                              _toggleSelezioneVinile(vinile);
                            } else {
                              _apriDettaglioVinile(vinile);
                            }
                          },
                          onLongPress: () => _toggleSelezioneVinile(vinile),
                          leading: SizedBox(
                            width: leadingImageSize,
                            height: leadingImageSize,
                            child: vinile.coverWidget,
                          ),
                          title: Text(vinile.titolo),
                          subtitle: Text('${vinile.artista} (${vinile.anno})'),
                          trailing: _modalitaSelezione
                              ? Icon(
                                  selezionato
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: selezionato
                                      ? Colors.blue
                                      : Colors.grey,
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        vinile.preferito
                                            ? Icons.star_rounded
                                            : Icons.star_border_rounded,
                                        color: vinile.preferito
                                            ? Colors.amber
                                            : Colors.grey,
                                      ),
                                      onPressed: () async {
                                        setState(
                                          () => vinile.preferito =
                                              !vinile.preferito,
                                        );
                                        await DatabaseHelper.instance
                                            .aggiornaPreferito(
                                              vinile.id!,
                                              vinile.preferito,
                                            );
                                      },
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (scelta) {
                                        if (scelta == 'modifica') {
                                          _modificaVinile(vinile);
                                        } else if (scelta == 'elimina') {
                                          _confermaEliminaVinile(vinile);
                                        }
                                      },
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(
                                          value: 'modifica',
                                          child: Text('Modifica'),
                                        ),
                                        PopupMenuItem(
                                          value: 'elimina',
                                          child: Text('Elimina'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}