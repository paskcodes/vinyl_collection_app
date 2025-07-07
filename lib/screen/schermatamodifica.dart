import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vinyl_collection_app/vinile/vinile.dart';

import '../categoria/genere.dart';
import '../database/databasehelper.dart';
import '../vinile/condizione.dart';

class SchermataModifica extends StatefulWidget {
  final Vinile vinile;
  final bool suggested;
  const SchermataModifica({super.key,required this.vinile,required this.suggested});

  @override
  State<SchermataModifica> createState() => _SchermataModificaState();
}

class _SchermataModificaState extends State<SchermataModifica> {


  final _titoloController = TextEditingController();

  final _artistaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _annoController = TextEditingController();
  final _etichettaController = TextEditingController();

  late int _numeroCopie;
  int? _genereSelezionato;
  late int _condizione;
  late bool _preferito;
  File? _immagineFile;
  List<Genere> _categorie=[];


  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titoloController.text = widget.vinile.titolo;
    _artistaController.text = widget.vinile.artista;
    _annoController.text = widget.vinile.anno?.toString() ?? '';
    _etichettaController.text = widget.vinile.etichettaDiscografica ?? '';

    _numeroCopie = widget.vinile.copie ?? 1;
    _genereSelezionato = widget.vinile.genere;
    _condizione =widget.vinile.condizione?.index ?? 0;
    _preferito = widget.vinile.preferito;


    _titoloController.addListener(_aggiornaStato);
    _artistaController.addListener(_aggiornaStato);
    _annoController.addListener(_aggiornaStato);
    _etichettaController.addListener(_aggiornaStato);
    caricaCategorie();

  }

  Future<void> caricaCategorie() async{
    List<Genere>categorie=await DatabaseHelper.instance.getGeneri();
    setState(() {
      _categorie=categorie;
      if (_genereSelezionato == null && _categorie.isNotEmpty) {
        _genereSelezionato = _categorie.first.id;
      }
    });
  }


  void _aggiornaStato() => setState(() {});

  bool _formValido() {
    return _titoloController.text.trim().isNotEmpty &&
        _artistaController.text.trim().isNotEmpty &&
        _annoController.text.trim().isNotEmpty &&
        _etichettaController.text.trim().isNotEmpty &&
        _genereSelezionato!=null;
  }


  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _immagineFile = File(picked.path);
      });
    }
  }


  Future<void> _modifica() async {
    if (_formKey.currentState!.validate()) {
      final nuovoVinile = Vinile(id:widget.suggested? null:widget.vinile.id,titolo: _titoloController.text.trim(), artista: _artistaController.text.trim(),
        anno: int.parse(_annoController.text.trim()), genere:_genereSelezionato, etichettaDiscografica:_etichettaController.text.trim(),
        copie: _numeroCopie, condizione: Condizione.values[_condizione], immagine: _immagineFile != null ? 'file://${_immagineFile!.path}' : widget.vinile.immagine, preferito: _preferito,);
      logger.i("Vinile creato: $nuovoVinile");
      if(widget.suggested){

        if(await DatabaseHelper.instance.vinileEsiste(nuovoVinile)){
          showDialog(context: context,
              builder: (BuildContext context){
                return AlertDialog(
                  title: Text("Attenzione!"),
                  content: const Text("Hai già questo vinile nella tua collezione."),
                  actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(), child: const Text("Ok"))],
                );
              }
          );
        }else {
          logger.i("Controllo effettuato. Aggiungo il vinile al database.");
          await DatabaseHelper.instance.aggiungiVinile(nuovoVinile);
          if(mounted) {
            Navigator.pop(context, true);
          }// torna indietro
        }

      }else{
        if (nuovoVinile == widget.vinile) { // Qui usiamo il tuo nuovo operatore ==
          // Se nessun valore è cambiato, torna indietro senza mostrare la snackbar
          logger.i("Nessuna modifica rilevata, torno indietro.");
          if (mounted) {
            Navigator.pop(context, false); // Torna indietro segnalando che NON ci sono state modifiche
          }
          return; // Termina la funzione qui
        }
        if(await DatabaseHelper.instance.modificaVinile(nuovoVinile)){
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Modifica completata con successo'),
                duration: Duration(seconds: 2),
              ),
            );
            Navigator.pop(context, true); // torna indietro segnalando il successo
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _titoloController.dispose();
    _artistaController.dispose();
    _annoController.dispose();
    _etichettaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aggiungi il tuo vinile:"),
      ),
      body: SingleChildScrollView(        //se esce fuori dallo schermo dà errore,con singlechildscrollview no.
        padding: const EdgeInsets.all(16),
        child: Form(
            key: _formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,//allineati orizzontalmente a sinistra
              children: [
                //gestione immagine
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                        border:Border.all(color: Colors.grey)
                    ),
                    child:_immagineFile != null
                  ? Image.file(_immagineFile!, fit: BoxFit.cover)
                  : widget.vinile.coverWidget,
                  ),
                ),

                const SizedBox(width: 16,),
                //gestione form
                Expanded(child: Column(
                  children: [
                    TextFormField(
                      controller: _titoloController,
                      decoration: const InputDecoration(labelText: 'Titolo'),
                      validator: (value) => value!.isEmpty? 'Inserisci un titolo' : null,
                    ),
                    TextFormField(
                      controller: _artistaController,
                      decoration: const InputDecoration(labelText: 'Artista'),
                      validator: (value) => value!.isEmpty? 'Inserisci un artista' : null,
                    ),
                    TextFormField(
                      controller: _annoController,
                      decoration: const InputDecoration(labelText: 'Anno'),
                      keyboardType: TextInputType.number,
                      validator: (value) => ( value!.isEmpty || int.tryParse(value)==null|| int.tryParse(value)!<1948 || int.tryParse(value)!>DateTime.now().year)? 'Inserisci un anno valido' : null,
                    ),
                    TextFormField(
                      controller: _etichettaController,
                      decoration: const InputDecoration(labelText: 'Etichetta'),
                      validator: (value) => value!.isEmpty? 'Inserisci un etichetta' : null,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Copie possedute"),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (_numeroCopie > 1) _numeroCopie--;
                            });
                          },
                        ),

                        Text("$_numeroCopie"),

                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _numeroCopie++;
                            });
                          },
                        ),

                      ],

                    ),
                    DropdownButtonFormField<int>(
                      value: _genereSelezionato,
                      items: _categorie.map((categoria) {
                        return DropdownMenuItem<int>(
                          value: categoria.id,
                          child: Text(categoria.nome),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _genereSelezionato = val;
                        });
                      },
                      decoration: const InputDecoration(labelText: "Categoria"),
                    ),
                    DropdownButtonFormField<int>(
                      value: _condizione,
                      items: Condizione.values
                          .asMap()
                          .entries
                          .map((e) => DropdownMenuItem(
                          value: e.key,
                        child: Text(e.value.descrizione),
                      ),)
                          .toList(),
                      onChanged: (val) => setState(() => _condizione = val!),
                      decoration: const InputDecoration(labelText: "Condizione"),
                    ),
                    IconButton(
                      icon: Icon(
                        _preferito ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          _preferito = !_preferito;
                        });
                      },
                    ),
                    const Text("Preferito"),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _formValido() ? _modifica : null,
                      child:widget.suggested
                          ? const Text("Aggiungi alla collezione")
                          : const Text("Conferma modifiche"),
                    ),
                  ],
                )
                )


              ],//fine childer
            )
        ),
      ),

    );
}
}
