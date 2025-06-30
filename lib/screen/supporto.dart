/*
import 'package:flutter/material.dart';

import '../models/vinile.dart';
import '../services/database_service.dart';
import '../vinile/condizione.dart';
import '../vinile/genere.dart';
import '../vinile/vinile.dart'; // dove sono i metodi aggiornaVinile, eliminaVinile

class ModificaVinilePage extends StatefulWidget {
  final Vinile vinile;

  const ModificaVinilePage({super.key, required this.vinile});

  @override
  State<ModificaVinilePage> createState() => _ModificaVinilePageState();
}

class _ModificaVinilePageState extends State<ModificaVinilePage> {
  late TextEditingController _titoloController;
  late TextEditingController _artistaController;
  late TextEditingController _annoController;
  late TextEditingController _etichettaController;
  late int _quantita;
  late Genere _genereSelezionato;
  late Condizione _condizioneSelezionata;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titoloController = TextEditingController(text: widget.vinile.titolo);
    _artistaController = TextEditingController(text: widget.vinile.nomeArtista);
    _annoController = TextEditingController(
      text: widget.vinile.anno.toString(),
    );
    _etichettaController = TextEditingController(
      text: widget.vinile.etichettaDiscografica,
    );
    _quantita = widget.vinile.quantita;
    _genereSelezionato = widget.vinile.genere;
    _condizioneSelezionata = widget.vinile.condizione;
  }

  @override
  void dispose() {
    _titoloController.dispose();
    _artistaController.dispose();
    _annoController.dispose();
    _etichettaController.dispose();
    super.dispose();
  }

  Future<void> _salvaModifiche() async {
    if (_formKey.currentState!.validate()) {
      widget.vinile.titolo = _titoloController.text.trim();
      widget.vinile.nomeArtista = _artistaController.text.trim();
      widget.vinile.anno =
          int.tryParse(_annoController.text) ?? widget.vinile.anno;
      widget.vinile.etichetta_discografica = _etichettaController.text.trim();
      widget.vinile.quantita = _quantita;
      widget.vinile.genere = _genereSelezionato;
      widget.vinile.condizione = _condizioneSelezionata;

      await aggiornaVinile(widget.vinile);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _decrementaQuantita() async {
    if (_quantita <= 1) {
      final conferma = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Eliminare vinile?"),
          content: const Text(
            "La quantità è 1. Eliminare questo vinile dalla collezione?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annulla"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Elimina", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (conferma == true) {
        await eliminaVinile(widget.vinile);
        if (mounted) Navigator.pop(context);
      }
    } else {
      setState(() => _quantita--);
    }
  }

  Future<bool> _controllaModificheNonSalvate() async {
    final haModifiche =
        _titoloController.text.trim() != widget.vinile.titolo ||
        _artistaController.text.trim() != widget.vinile.nomeArtista ||
        _annoController.text.trim() != widget.vinile.anno.toString() ||
        _etichettaController.text.trim() !=
            widget.vinile.etichetta_discografica ||
        _quantita != widget.vinile.quantita ||
        _genereSelezionato != widget.vinile.genere ||
        _condizioneSelezionata != widget.vinile.condizione;

    if (!haModifiche) return true;

    final conferma = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Modifiche non salvate"),
        content: const Text(
          "Hai modificato delle informazioni. Vuoi uscire senza salvare?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Resta"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Esci"),
          ),
        ],
      ),
    );

    return conferma ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _controllaModificheNonSalvate,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Modifica Vinile"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final esci = await _controllaModificheNonSalvate();
              if (esci && mounted) Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _salvaModifiche,
              tooltip: "Conferma modifiche",
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              widget.vinile.immagine,
              const SizedBox(width: 16),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _titoloController,
                        decoration: const InputDecoration(labelText: "Titolo"),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? "Campo obbligatorio"
                            : null,
                      ),
                      TextFormField(
                        controller: _artistaController,
                        decoration: const InputDecoration(labelText: "Artista"),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? "Campo obbligatorio"
                            : null,
                      ),
                      TextFormField(
                        controller: _annoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Anno"),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? "Campo obbligatorio"
                            : null,
                      ),
                      TextFormField(
                        controller: _etichettaController,
                        decoration: const InputDecoration(
                          labelText: "Etichetta discografica",
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? "Campo obbligatorio"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      const Text("Quantità"),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _decrementaQuantita,
                            icon: const Icon(Icons.remove),
                          ),
                          Text(
                            _quantita.toString(),
                            style: const TextStyle(fontSize: 18),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _quantita++),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text("Genere"),
                      DropdownButtonFormField<Genere>(
                        value: _genereSelezionato,
                        onChanged: (valore) {
                          if (valore != null)
                            setState(() => _genereSelezionato = valore);
                        },
                        items: Genere.values.map((genere) {
                          return DropdownMenuItem(
                            value: genere,
                            child: Text(genere.name),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text("Condizione"),
                      DropdownButtonFormField<Condizione>(
                        value: _condizioneSelezionata,
                        onChanged: (valore) {
                          if (valore != null)
                            setState(() => _condizioneSelezionata = valore);
                        },
                        items: Condizione.values.map((condizione) {
                          return DropdownMenuItem(
                            value: condizione,
                            child: Text(condizione.name),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

 */