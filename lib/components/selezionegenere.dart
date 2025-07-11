import 'package:flutter/material.dart';

import '../categoria/genere.dart';
import '../database/databasehelper.dart';

class DialogSelezioneGenere extends StatefulWidget {
  const DialogSelezioneGenere({super.key});

  @override
  State<DialogSelezioneGenere> createState() => _DialogSelezioneGenereState();
}

class _DialogSelezioneGenereState extends State<DialogSelezioneGenere> {
  int? _genereSelezionato;
  List<Genere> _generi = [];

  @override
  void initState() {
    super.initState();
    _caricaGeneri();
  }

  Future<void> _caricaGeneri() async {
    final generi = await DatabaseHelper.instance.getGeneri();
    setState(() => _generi = generi);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Scegli nuovo genere'),
      content: _generi.isEmpty
          ? const CircularProgressIndicator()
          : DropdownButton<int>(
              value: _genereSelezionato,
              hint: const Text('Seleziona genere'),
              isExpanded: true,
              items: _generi
                  .map(
                    (genere) => DropdownMenuItem(
                      value: genere.id,
                      child: Text(genere.nome),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _genereSelezionato = val),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        TextButton(
          onPressed: _genereSelezionato == null
              ? null
              : () => Navigator.pop(context, _genereSelezionato),
          child: const Text('Conferma'),
        ),
      ],
    );
  }
}