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
  // controller & keys
  final _formKey = GlobalKey<FormState>();
  final _titolo   = TextEditingController();
  final _artista  = TextEditingController();
  final _anno     = TextEditingController();
  final _etichetta= TextEditingController();
  final _picker   = ImagePicker();

  // state
  int _copie = 1;
  int? _genereId;
  int _condizioneIdx = 0;
  bool _preferito = false;
  File? _coverFile;
  List<Genere> _generi = [];

  @override
  void initState() {
    super.initState();
    _loadGeneri();
  }

  Future<void> _loadGeneri() async {
    final list = await DatabaseHelper.instance.getGeneri();
    setState(() {
      _generi = list;
      if (_genereId == null && list.isNotEmpty) _genereId = list.first.id;
    });
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _coverFile = File(picked.path));
  }

  bool get _formValid =>
      _formKey.currentState?.validate() == true && _genereId != null;

  Future<void> _aggiungi() async {
    if (!_formValid) return;

    final nuovo = Vinile(
      titolo: _titolo.text.trim(),
      artista: _artista.text.trim(),
      anno: int.tryParse(_anno.text),
      genere: _genereId,
      etichettaDiscografica: _etichetta.text.trim(),
      copie: _copie,
      condizione: Condizione.values[_condizioneIdx],
      immagine: _coverFile != null ? 'file://${_coverFile!.path}' : null,
      preferito: _preferito,
    );

    if (await DatabaseHelper.instance.vinileEsiste(nuovo)) {
      if (mounted) _showAlert('Attenzione', 'Hai già questo vinile nella tua collezione.');
      return;
    }

    await DatabaseHelper.instance.aggiungiVinile(nuovo);
    if (mounted) Navigator.pop(context, true);
  }

  void _showAlert(String title, String msg) => showDialog(
    context: context,
    builder: (_) => AlertDialog(title: Text(title), content: Text(msg), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Aggiungi vinile')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Copertina
              Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _pickImage,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 140,
                      height: 140,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: _coverFile != null
                          ? Image.file(_coverFile!, fit: BoxFit.cover)
                          : Image.asset('assets/immagini/vinilee.png', fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // TextFields
              _M3TextField(controller: _titolo, label: 'Titolo'),
              _M3TextField(controller: _artista, label: 'Artista'),
              _M3TextField(
                controller: _anno,
                label: 'Anno',
                keyboardType: TextInputType.number,
                validator: (v) {
                  final y = int.tryParse(v ?? '');
                  if (y == null || y < 1948 || y > DateTime.now().year) return 'Anno non valido';
                  return null;
                },
              ),
              _M3TextField(controller: _etichetta, label: 'Etichetta'),

              // Categoria
              DropdownButtonFormField<int>(
                value: _genereId,
                items: _generi
                    .map((g) => DropdownMenuItem<int>(value: g.id, child: Text(g.nome)))
                    .toList(),
                onChanged: (v) => setState(() => _genereId = v),
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
              const SizedBox(height: 16),

              // Condizione
              Center(
                child: SegmentedButton<int>(
                  segments: Condizione.values
                      .map((c) => ButtonSegment(value: c.index, label: Text(c.descrizione)))
                      .toList(),
                  selected: {_condizioneIdx},
                  onSelectionChanged: (s) => setState(() => _condizioneIdx = s.first),
                ),
              ),
              const SizedBox(height: 16),

              // Copie e preferito
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: _copie > 1 ? () => setState(() => _copie--) : null),
                        Text('$_copie copie'),
                        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => _copie++)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(_preferito ? Icons.star_rounded : Icons.star_border_rounded, color: Colors.amber, size: 32),
                    onPressed: () => setState(() => _preferito = !_preferito),
                  )
                ],
              ),
              const SizedBox(height: 32),

              // Pulsante salva
              Center(
                child: FilledButton.icon(
                  onPressed: _formValid ? _aggiungi : null,
                  icon: const Icon(Icons.add),
                  label: const Text('Aggiungi alla collezione'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _M3TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  const _M3TextField({required this.controller, required this.label, this.keyboardType, this.validator});

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator ?? (v) => v == null || v.trim().isEmpty ? 'Campo obbligatorio' : null,
    decoration: InputDecoration(labelText: label),
  );
}