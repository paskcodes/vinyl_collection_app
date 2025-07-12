import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/database/database_helper.dart';
import 'package:vinyl_collection_app/screen/schermateSecondarie/schermata_analisi_vinili.dart';
import 'package:vinyl_collection_app/screen/schermateSecondarie/schermata_modifica.dart';
import 'package:vinyl_collection_app/screen/schermateSecondarie/dettaglio_vinile_collezione.dart';
import 'package:vinyl_collection_app/utils/dimensioni_schermo.dart';
import 'package:vinyl_collection_app/vinile/vinile.dart';
import '../../components/filtro_ricerca_widget.dart';
import '../../vinile/condizione.dart';

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
      //per rendere i filtri "persistenti"
      _query = query;
      _genereId = genere;
      _condizione = condizione;
      _anno = anno;
      _soloPreferiti = soloPreferiti;

      int? annoMin;
      int? annoMax;

      if (anno != null) {
        final lunghezza = anno.toString().length;
        if (lunghezza == 1) {
          annoMin = anno * 1000;
          annoMax = annoMin + 999;
        } else if (lunghezza == 2) {
          annoMin = anno * 100;
          annoMax = annoMin + 99;
        } else if (lunghezza == 3) {
          annoMin = anno * 10;
          annoMax = annoMin + 9;
        } else if (lunghezza == 4) {
          annoMin = anno;
          annoMax = anno;
        }
      }

      _listaVinili = _tuttiIVinili.where((vinile) {
        final matchQuery =
            query.isEmpty ||
                vinile.titolo.toLowerCase().contains(query.toLowerCase()) ||
                vinile.artista.toLowerCase().contains(query.toLowerCase()) ||
                vinile.etichettaDiscografica?.toLowerCase().contains(query.toLowerCase()) == true;

        final matchGenere = genere == null || vinile.genere == genere;
        final matchCondizione = condizione == null || vinile.condizione == condizione;
        final matchAnno = anno == null || (vinile.anno! >= (annoMin ?? 0) && vinile.anno! <= (annoMax ?? 9999));
        final matchPreferiti = !soloPreferiti || vinile.preferito == true;

        return matchQuery && matchGenere && matchCondizione && matchAnno && matchPreferiti;
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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final selectedBackgroundColor = isDarkMode
        ? Theme.of(context).colorScheme.primary.withValues()
        : Theme.of(context).colorScheme.primary.withValues();
    final selectedTextColor = isDarkMode ? Colors.white : Colors.black;
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
                .isNotEmpty) //solo se ci sono vinili nella collezione
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

      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
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
          if (_listaVinili.isEmpty)
            const Center(child: Text("Aggiungi un vinile")),
          ..._listaVinili.map((vinile) {
            final selezionato = _viniliSelezionati.contains(vinile);
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: selezionato ? selectedBackgroundColor : null,
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
                title: Text(
                  vinile.titolo,
                  style: TextStyle(
                    color: selezionato ? selectedTextColor : null,
                  ),
                ),
                subtitle: Text(
                  '${vinile.artista} (${vinile.anno})',
                  style: TextStyle(
                    color: selezionato ? selectedTextColor : null,
                  ),
                ),
                trailing: _modalitaSelezione
                    ? Icon(
                  selezionato
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: selezionato
                      ? Theme.of(context).colorScheme.primary
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
                        color: vinile.preferito ? Colors.amber : Colors.grey,
                      ),
                      onPressed: () async {
                        setState(() => vinile.preferito = !vinile.preferito);
                        await DatabaseHelper.instance.aggiornaPreferito(
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
          }).toList(),
        ],
      ),

    );
  }
}