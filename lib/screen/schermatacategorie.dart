import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/components/genere_tile.dart';
import 'package:vinyl_collection_app/screen/schermatapercategoria.dart';
import 'package:vinyl_collection_app/utils/dimensionischermo.dart';
import '../categoria/genere.dart';
import '../database/databasehelper.dart';

class SchermataCategorie extends StatefulWidget {
  const SchermataCategorie({super.key});

  @override
  State<SchermataCategorie> createState() => SchermataCategorieState();
}

class SchermataCategorieState extends State<SchermataCategorie> {
  List<Map<String, dynamic>>? _listaFiltrata;
  Set<int> _categorieSelezionate = {};
  bool _modalitaSelezione = false;
  bool _mostraTutte = false;

  @override
  void initState() {
    super.initState();
    aggiornaGeneri();
  }

  Future<void> aggiornaGeneri() async {
    List<Map<String, dynamic>> lista = _mostraTutte
        ? await Genere.tuttiGeneri()
        : await Genere.generiFiltrati();
    setState(() {
      _listaFiltrata = lista;
    });
  }

  void toggleMostraTutte() {
    setState(() {
      _mostraTutte = !_mostraTutte;
    });
    aggiornaGeneri();
  }

  void vaiAggiuntaCategoria() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Funzione da implementare: aggiunta categoria")),
    );
  }

  void onTileTap(int id, String nome, int conteggio) {
    if (_modalitaSelezione) {
      setState(() {
        if (_categorieSelezionate.contains(id)) {
          _categorieSelezionate.remove(id);
          if (_categorieSelezionate.isEmpty) _modalitaSelezione = false;
        } else {
          _categorieSelezionate.add(id);
        }
      });
    } else {
      apriSchermata(id, nome);
    }
  }

  void onTileLongPress(int id) {
    setState(() {
      _modalitaSelezione = true;
      _categorieSelezionate.add(id);
    });
  }

  Future<void> apriSchermata(int genereId, String genereNome) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SchermataViniliPerCategoria(genereId: genereId, genereNome: genereNome),
      ),
    );
    aggiornaGeneri();
  }

  Future<void> eliminaCategorieSelezionate() async {
    List<Map<String, dynamic>> eliminabili = _listaFiltrata!
        .where((genere) =>
    _categorieSelezionate.contains(genere['id']) && genere['conteggio'] == 0)
        .toList();

    final nonEliminabili = _listaFiltrata!
        .where((genere) =>
    _categorieSelezionate.contains(genere['id']) && genere['conteggio'] > 0)
        .toList();

    if (eliminabili.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Non puoi eliminare categorie che contengono vinili.")),
      );
      return;
    }

    String messaggio = "Eliminare ${eliminabili.length} categoria/e?";
    if (nonEliminabili.isNotEmpty) {
      messaggio += "\n(${nonEliminabili.length} non verranno eliminate perché contengono vinili)";
    }


    bool conferma = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Conferma eliminazione"),
        content: Text(messaggio),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annulla")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Elimina")),
        ],
      ),
    ) ?? false;


    if (conferma) {
      for (var genere in eliminabili) {
        await DatabaseHelper.instance.elimina(genere['id']);
      }
      _categorieSelezionate.clear();
      _modalitaSelezione = false;
      aggiornaGeneri();
    }
  }

  Future<void> modificaCategoria() async {
    if (_categorieSelezionate.length != 1) return;
    final id = _categorieSelezionate.first;
    final genere = _listaFiltrata!.firstWhere((g) => g['id'] == id);
    final controller = TextEditingController(text: genere['nome']);

    final nuovoNome = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Modifica nome categoria"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: "Nuovo nome"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text("Salva")),
        ],
      ),
    );

    if (nuovoNome != null && nuovoNome.isNotEmpty) {
      bool nomeEsistente = _listaFiltrata!.any(
            (genere) => genere['nome'].toLowerCase() == nuovoNome.toLowerCase() && genere['id'] != id,
      );

      if (nomeEsistente) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Esiste già una categoria con questo nome.")),
        );
        return;
      }

      await DatabaseHelper.instance.rinomina(id, nuovoNome);
      _categorieSelezionate.clear();
      _modalitaSelezione = false;
      aggiornaGeneri();
    }

  }

  /*Widget _buildAddCategoryTile(BuildContext context) {
    final double cardWidth = context.screenWidth * 0.4;
    final double iconSize = cardWidth * 0.6;
    final double titleSize = context.shortestSide * 0.045;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: vaiAggiuntaCategoria,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: scheme.surfaceContainerHighest,
        child: Container(
          width: cardWidth,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, size: iconSize, color: scheme.onSurfaceVariant),
              const SizedBox(height: 8),
              Text(
                'Nuova categoria',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: titleSize,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modalitaSelezione
            ? "${_categorieSelezionate.length} selezionate"
            : 'Le tue categorie'),
        centerTitle: true,
        leading: _modalitaSelezione
            ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _categorieSelezionate.clear();
              _modalitaSelezione = false;
            });
          },
        )
            : null,
        actions: _modalitaSelezione
            ? [
          if (_categorieSelezionate.length == 1)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Modifica nome',
              onPressed: modificaCategoria,
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Elimina (solo vuote)',
            onPressed: eliminaCategorieSelezionate,
          ),
        ]
            : [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: 'Aggiungi categoria',
            onPressed: vaiAggiuntaCategoria,
          ),
          IconButton(
            icon: Icon(_mostraTutte ? Icons.visibility_off : Icons.visibility),
            tooltip: _mostraTutte
                ? 'Mostra solo categorie con vinili'
                : 'Mostra tutte le categorie',
            onPressed: toggleMostraTutte,
          ),
        ],
      ),
      body: _listaFiltrata == null
          ? const Center(child: CircularProgressIndicator())
          : _listaFiltrata!.isEmpty
          ? const Center(child: Text("Aggiungi vinili per visualizzare le categorie."))
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: (context.screenWidth / 2 - 16) /
              (context.screenWidth * 0.4 +
                  (context.shortestSide * 0.045 * 2) +
                  (context.shortestSide * 0.03) +
                  8 +
                  4 +
                  12 +
                  12),
        ),
        itemCount: _listaFiltrata!.length,//+1
        itemBuilder: (context, index) {
          /*if (index == _listaFiltrata!.length) {
            return _buildAddCategoryTile(context);
          } else {*/
            final genereMap = _listaFiltrata![index];
            final int id = genereMap['id'];
            final String nome = genereMap['nome'];
            final int conteggio = genereMap['conteggio'];

            return GestureDetector(
              onTap: () => onTileTap(id, nome, conteggio),
              onLongPress: () => onTileLongPress(id),
              child: Stack(
                children: [
                  GenereTile(
                    genereId: id,
                    nomeGenere: nome,
                    numeroVinili: conteggio,
                    onTap: () => onTileTap(id, nome, conteggio),
                  ),
                  if (_modalitaSelezione)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(
                        _categorieSelezionate.contains(id)
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            );
          //}
        },
      ),
    );
  }
}
