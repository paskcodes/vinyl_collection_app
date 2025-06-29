import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/database/dbvinili.dart';
import 'package:vinyl_collection_app/vinile/Vinile.dart';

class schermatacollezione extends StatefulWidget {
  const schermatacollezione({super.key});

  @override
  State<schermatacollezione> createState() => _schermatacollezioneState();
}



class _schermatacollezioneState extends State<schermatacollezione> {
  late List<Vinile> _listaVinili=[];

  @override
  void initState() {
    super.initState();
    _caricaVinili();
    //Vinile vinile1=Vinile(titolo:"Femmn", nomeArtista:"gigi d'alessio",anno: 1990,genere: Genere.rock,
    //etichettaDiscografica: "The squallors",quantita:  1,condizione: Condizione.nuovo,urlImmagine:"https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.wildtierdruck.de%2Fit%2Fproducts%2Ftieraufsteller-uhu-outdoor-set%3Fsrsltid%3DAfmBOorKMEXDrnxpvgrkqrjMa3XgR6HoLurqFq9yKZyzbBzYbiyoTNr2&psig=AOvVaw3CUw-B3mbLzyqgCUcLa6BO&ust=1751313078041000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCOD0suGzl44DFQAAAAAdAAAAABAE",
    //);
  }

  void _aggiungiVinile() async {
    final aggiunto = await Navigator.pushNamed(context, '/schermataaggiungi');
    if (aggiunto == true) {
      await _caricaVinili();
    }
  }

  Future<void> _caricaVinili() async{ //carica la lista di vinili tramite lo state(cosi rifà il render)
    final listaVinili=await DatabaseHelper.instance.getCollezione();

      setState(() {
      _listaVinili=listaVinili;
    });
  }

  Future<bool> _rimuoviVinile(Vinile vinile) async{
      return await DatabaseHelper.instance.eliminaVinile(vinile);
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
