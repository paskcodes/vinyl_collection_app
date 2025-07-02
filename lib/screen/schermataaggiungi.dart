import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../categoria/genere.dart';
import '../database/databasehelper.dart';
import '../vinile/condizione.dart';
import '../vinile/vinile.dart';

class SchermataAggiungi extends StatefulWidget {


  const SchermataAggiungi({super.key});

  @override
  State<SchermataAggiungi> createState() => _SchermataAggiungiState();
}



class _SchermataAggiungiState extends State<SchermataAggiungi> {
  final _formKey = GlobalKey<FormState>();

  final _titoloController = TextEditingController();
  final _artistaController = TextEditingController();
  final _annoController = TextEditingController();
  final _etichettaController = TextEditingController();

  int _quantita = 1;
  int? _genereSelezionato;
  int _condizione = 0;
  bool _preferito = false;
  File? _immagineFile;
  List<Genere> _categorie=[];


  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titoloController.addListener(_aggiornaStato);
    _artistaController.addListener(_aggiornaStato);
    _annoController.addListener(_aggiornaStato);
    _etichettaController.addListener(_aggiornaStato);
    caricaCategorie();
  }

  Future<void> caricaCategorie() async{
    List<Genere>categorie=await DatabaseHelper.instance.getCategorie();
    setState(() {
      _categorie=categorie;
    });
  }


  void _aggiornaStato() => setState(() {});

  bool _formValido() {
    return _titoloController.text.trim().isNotEmpty &&
        _artistaController.text.trim().isNotEmpty &&
        _annoController.text.trim().isNotEmpty &&
        _etichettaController.text.trim().isNotEmpty &&
        _genereSelezionato==null;
  }


  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _immagineFile = File(picked.path);
      });
    }
  }

  Future<void> _aggiungi() async {
    if (_formKey.currentState!.validate()) {
      final nuovoVinile = Vinile(titolo: _titoloController.text.trim(), artista: _artistaController.text.trim(),
        anno: int.parse(_annoController.text.trim()), genere:_genereSelezionato, etichettaDiscografica:_etichettaController.text.trim(),
        quantita: _quantita, condizione: Condizione.values[_condizione], immagine: _immagineFile?.path ,preferito: _preferito,);
      print("Vinile creato: $nuovoVinile");
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
      }else{
        print("Sto per tornare indietro con true");
        await DatabaseHelper.instance.aggiungiVinile(nuovoVinile);
        Navigator.pop(context,true); // torna indietro

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
                    child: _immagineFile != null
                        ? Image.file(_immagineFile!, fit: BoxFit.cover)
                        : Image.asset('assets/immagini/vinilee.png', fit: BoxFit.cover),
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
                        const Text("Quantità"),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (_quantita > 1) _quantita--;
                            });
                          },
                        ),

                        Text("$_quantita"),

                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _quantita++;
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
                          value: e.key, child: Text(e.value.name)))
                          .toList(),
                      onChanged: (val) => setState(() => _condizione = val!),
                      decoration: const InputDecoration(labelText: "Condizione"),
                    ),
                    DropdownButtonFormField<int>(
                      value: _condizione,
                      items: Condizione.values
                          .asMap()
                          .entries
                          .map((e) => DropdownMenuItem(
                          value: e.key, child: Text(e.value.name)))
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
                      onPressed: _formValido() ? _aggiungi : null,
                      child: const Text("Aggiungi Vinile"),
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
