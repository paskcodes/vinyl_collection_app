import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/vinile/Vinile.dart';

class schermatacollezione extends StatefulWidget {
  const schermatacollezione({super.key});

  @override
  State<schermatacollezione> createState() => _schermatacollezioneState();
}

class _schermatacollezioneState extends State<schermatacollezione> {
  List<Vinile> _listaVinili=[];

  @override
  void initState() {
    super.initState();
    _caricaVinili();
  }

  void _aggiungiVinile() async {
    final aggiunto = await Navigator.pushNamed(context, '/schermataaggiungi');
    if (aggiunto == true) {
      await _caricaVinili();
    }
  }

  Future<void> _caricaVinili() async{ //carica la lista di vinili tramite lo state(cosi rifà il render)
   // final listaVinili=getVinili();
   // setState(() {
   //   _listaVinili=listaVinili;
   // });
  }

  Future<void> _rimuoviVinile(Vinile vinile) async{
  //  await eliminaVinile(vinile);
  //  await _caricaVinili();
  }

  void _modificaVinile(Vinile vinile) async {
    final modificato = await Navigator.pushNamed(context, '/schermatamodifica', arguments: vinile);
    if (modificato == true) {
      await _caricaVinili();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("La tua collezione"),
        actions: [
          IconButton(
              onPressed: _aggiungiVinile,
              icon: Image.asset(
              'assets/icone/nuovoVinile.png',
              width: 24,
              height: 24,
            ),
          )
        ],
      ),
      body: _listaVinili.isEmpty ? const Center(child: Text("Aggiungi un vinile"))
          : ListView.builder(
            itemCount: _listaVinili.length,
            itemBuilder: (context,indice) {
              final vinile = _listaVinili[indice];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: vinile.immagine,
                  ),

                  title: Text(vinile.titolo),
                  subtitle: Text('${vinile.nomeArtista} (${vinile.anno})'),

                  trailing: PopupMenuButton<String>(
                    onSelected: (scelta) {
                      if (scelta == 'modifica') {
                        _modificaVinile(vinile);
                      } else if (scelta == 'elimina'){
                                _rimuoviVinile(vinile);}
                    },
                    itemBuilder: (context) =>
                    const [
                      PopupMenuItem(value: 'modifica', child: Text('Modifica')),
                      PopupMenuItem(value: 'elimina', child: Text('Elimina')),
                    ],
                  ),
                ),
              );
            },  //fine itemBuilder di ListView
          ),
    );
  }

}
