import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/components/genere_tile.dart';
import 'package:vinyl_collection_app/screen/schermatapercategoria.dart';
import '../database/databasehelper.dart';

class SchermataCategorie extends StatefulWidget {
  const SchermataCategorie({super.key});

  @override
  State<SchermataCategorie> createState() => SchermataCategorieState();
}

class SchermataCategorieState extends State<SchermataCategorie> {
  List<Map<String, dynamic>>? _listaFiltrata;
  final Set<int> _categorieSelezionate = {};
  bool _modalitaSelezione = false;
  bool _mostraTutte = false;

  // Getter pubblico per _mostraTutte
  bool get mostraTutte => _mostraTutte;

  @override
  void initState() {
    super.initState();
    aggiornaGeneri();
  }

  Future<void> aggiornaGeneri() async {
    final db = DatabaseHelper.instance;
    List<Map<String, dynamic>> listaBase = _mostraTutte
        ? await DatabaseHelper.instance.getCategorieConConteggio()
        : await DatabaseHelper.instance.generiFiltrati();

    // Aggiungi le copertine per ogni genere
    List<Map<String, dynamic>> listaCompleta = [];
    for (var genere in listaBase) {
      int id = genere['id'];
      List<String> copertine = await db.getCopertineViniliByGenere(id);
      listaCompleta.add({...genere, 'copertine': copertine});
    }

    setState(() {
      _listaFiltrata = listaCompleta;
    });
  }

  void toggleMostraTutte() {
    setState(() {
      _mostraTutte = !_mostraTutte;
    });
    aggiornaGeneri();
  }

  Future<bool> vaiAggiuntaCategoria() async {
    final controller = TextEditingController();
    String? errore;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Aggiungi nuova categoria"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: "Nome categoria",
                      errorText: errore,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Annulla"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nuovoNome = controller.text.trim();
                    if (nuovoNome.isEmpty) {
                      setState(() => errore = "Inserisci un nome.");
                      return;
                    }

                    final esisteGia = _listaFiltrata?.any(
                      (genere) =>
                          genere['nome'].toLowerCase() ==
                          nuovoNome.toLowerCase(),
                    );

                    if (esisteGia == true) {
                      setState(() => errore = "Categoria già esistente.");
                      return;
                    }

                    await DatabaseHelper.instance.inserisciGenere(nuovoNome);
                    await aggiornaGeneri();
                    Navigator.pop(context, true);
                  },
                  child: const Text("Salva"),
                ),
              ],
            );
          },
        );
      },
    );

    return result == true;
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
        builder: (context) => SchermataViniliPerCategoria(
          genereId: genereId,
          genereNome: genereNome,
        ),
      ),
    );
    aggiornaGeneri();
  }

  Future<void> eliminaCategorieSelezionate() async {
    List<Map<String, dynamic>> eliminabili = _listaFiltrata!
        .where(
          (genere) =>
              _categorieSelezionate.contains(genere['id']) &&
              genere['conteggio'] == 0,
        )
        .toList();

    final nonEliminabili = _listaFiltrata!
        .where(
          (genere) =>
              _categorieSelezionate.contains(genere['id']) &&
              genere['conteggio'] > 0,
        )
        .toList();

    if (eliminabili.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Non puoi eliminare categorie che contengono vinili."),
        ),
      );
      return;
    }

    String messaggio = "Eliminare ${eliminabili.length} categoria/e?";
    if (nonEliminabili.isNotEmpty) {
      messaggio +=
          "\n(${nonEliminabili.length} non verranno eliminate perché contengono vinili)";
    }

    bool conferma =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Conferma eliminazione"),
            content: Text(messaggio),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Annulla"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Elimina"),
              ),
            ],
          ),
        ) ??
        false;

    if (conferma) {
      for (var genere in eliminabili) {
        await DatabaseHelper.instance.eliminaCategoria(genere['id']);
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annulla"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Salva"),
          ),
        ],
      ),
    );

    if (nuovoNome != null && nuovoNome.isNotEmpty) {
      bool nomeEsistente = _listaFiltrata!.any(
        (genere) =>
            genere['nome'].toLowerCase() == nuovoNome.toLowerCase() &&
            genere['id'] != id,
      );

      if (nomeEsistente) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Esiste già una categoria con questo nome."),
          ),
        );
        return;
      }

      await DatabaseHelper.instance.rinominaCategoria(id, nuovoNome);
      _categorieSelezionate.clear();
      _modalitaSelezione = false;
      aggiornaGeneri();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                  tooltip: mostraTutte
                      ? "Mostra solo categorie con vinili"
                      : "Mostra tutte le categorie",
                  icon: Icon(
                    mostraTutte ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: toggleMostraTutte,
                ),
              ],
      ),
      body: _listaFiltrata == null
          ? const Center(child: CircularProgressIndicator())
          : _listaFiltrata!.isEmpty
          ? const Center(
              child: Text("Aggiungi vinili per visualizzare le categorie."),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: _listaFiltrata!.length,
              itemBuilder: (context, index) {
                final genereMap = _listaFiltrata![index];
                final int id = genereMap['id'];
                final String nome = genereMap['nome'];
                final int conteggio = genereMap['conteggio'];
                final List<String> copertine = List<String>.from(
                  genereMap['copertine'] ?? [],
                );

                return GestureDetector(
                  onTap: () => onTileTap(id, nome, conteggio),
                  onLongPress: () => onTileLongPress(id),
                  child: Stack(
                    children: [
                      GenereTile(
                        genereId: id,
                        nomeGenere: nome,
                        numeroVinili: conteggio,
                        copertineVinili: copertine,
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
                            color: _categorieSelezionate.contains(id) ? Theme.of(context).colorScheme.primary : Colors.grey,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}