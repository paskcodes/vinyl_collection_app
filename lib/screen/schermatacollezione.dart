import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/database/databasehelper.dart';
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


  // VARIABILI DI FILTRO
  String _query = '';
  int? _genereId;
  Condizione? _condizione;
  int? _anno;
  bool _soloPreferiti = false;



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
    });
  }

  Future<void> _rimuoviVinile(Vinile vinile) async {
    await DatabaseHelper.instance.eliminaVinile(vinile);
    await caricaVinili();
  }

  void _modificaVinile(Vinile vinile) async {
    final modificato = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchermataModifica(vinile: vinile, suggested: false),
      ),
    );
    if (modificato == true) {
      await caricaVinili();
    }
  }

  Future<void> _confermaEliminaVinile(Vinile vinile) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text('Sei sicuro di voler eliminare "${vinile.titolo}" dalla collezione?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Elimina', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (conferma == true) {
      await _rimuoviVinile(vinile);
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
        final matchQuery = _query.isEmpty ||
            vinile.titolo.toLowerCase().contains(_query.toLowerCase()) ||
            vinile.artista.toLowerCase().contains(_query.toLowerCase()) ||
            vinile.etichettaDiscografica!.toLowerCase().contains(_query.toLowerCase());

        final matchGenere = _genereId == null || vinile.genere == _genereId;
        final matchCondizione = _condizione == null || vinile.condizione == _condizione;
        final matchAnno = _anno == null || vinile.anno == _anno;
        final matchPreferiti = !_soloPreferiti || vinile.preferito == true;

        return matchQuery && matchGenere && matchCondizione && matchAnno && matchPreferiti;
      }).toList();
    });
  }


  void _toggleFiltroRicerca() {
    setState(() {
      _mostraFiltri = !_mostraFiltri;
    });
  }



  @override
  Widget build(BuildContext context) {
    final double leadingImageSize = context.screenWidth * 0.12;
    return Scaffold(
      appBar: AppBar(
        title: const Text("La tua collezione"),
        actions: [
          IconButton(
            icon: Icon(_mostraFiltri ? Icons.close : Icons.search),
            onPressed: _toggleFiltroRicerca,
          ),
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
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              onTap: () => _apriDettaglioVinile(vinile),
              leading: SizedBox(
                width: leadingImageSize,
                height: leadingImageSize,
                child: vinile.coverWidget,
              ),
              title: Text(vinile.titolo),
              subtitle: Text('${vinile.artista} (${vinile.anno})'),
              trailing: PopupMenuButton<String>(
                onSelected: (scelta) {
                  if (scelta == 'modifica') {
                    _modificaVinile(vinile);
                  } else if (scelta == 'elimina') {
                    _confermaEliminaVinile(vinile);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'modifica', child: Text('Modifica')),
                  PopupMenuItem(value: 'elimina', child: Text('Elimina')),
                ],
              ),
            ),
          );
        },
      ),
    ),
    ]
    )
    );
  }

}
