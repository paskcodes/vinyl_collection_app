import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vinyl_collection_app/utils/dimensioniSchermo.dart';
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
  final _titolo = TextEditingController();
  final _artista = TextEditingController();
  final _anno = TextEditingController();
  final _etichetta = TextEditingController();
  final _picker = ImagePicker();

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

  Future<void> _showImageSourceActionSheet() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galleria'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Fotocamera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      setState(() => _coverFile = File(picked.path));
    }
  }

  Future<void> _aggiungi() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _genereId == null) return;

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
      if (mounted)
        _showAlert('Attenzione', 'Hai già questo vinile nella tua collezione.');
      return;
    }

    await DatabaseHelper.instance.aggiungiVinile(nuovo);
    if (mounted) Navigator.pop(context, true);
  }

  void _showAlert(String title, String msg) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('Aggiungi Vinile')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.screenWidth * 0.05,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceActionSheet,
                  // cambia da _pickImage a _showImageSourceActionSheet
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(20),
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      width: context.screenWidth * 0.8,
                      height: context.screenWidth * 0.8,
                      child: _coverFile != null
                          ? Image.file(_coverFile!, fit: BoxFit.cover)
                          : Image.asset(
                              'assets/immagini/vinilee.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _M3TextField(controller: _titolo, label: 'Titolo'),
              _M3TextField(controller: _artista, label: 'Artista'),
              _M3TextField(
                controller: _anno,
                label: 'Anno',
                keyboardType: TextInputType.number,
                validator: (v) {
                  final y = int.tryParse(v ?? '');
                  if (y == null || y < 1948 || y > DateTime.now().year)
                    return 'Anno non valido';
                  return null;
                },
              ),
              _M3TextField(controller: _etichetta, label: 'Etichetta'),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _genereId,
                items: _generi
                    .map(
                      (g) => DropdownMenuItem<int>(
                        value: g.id,
                        child: Text(
                          g.nome,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _genereId = v),
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                ),
                dropdownColor: Theme.of(context).colorScheme.surface,
                menuMaxHeight: 300,
              ),
              const SizedBox(height: 16),
              Center(
                child: SegmentedButton<int>(
                  segments: Condizione.values
                      .map(
                        (c) => ButtonSegment(
                          value: c.index,
                          label: Text(c.descrizione),
                        ),
                      )
                      .toList(),
                  selected: {_condizioneIdx},
                  onSelectionChanged: (s) =>
                      setState(() => _condizioneIdx = s.first),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _copie > 1
                              ? () => setState(() => _copie--)
                              : null,
                        ),
                        Text('$_copie copie'),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => setState(() => _copie++),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _preferito
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () => setState(() => _preferito = !_preferito),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: context.screenWidth * 0.8,
                  child: FilledButton.icon(
                    onPressed: _aggiungi, // sempre attivo
                    icon: const Icon(Icons.add),
                    label: const Text('Aggiungi alla collezione'),
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

class _M3TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _M3TextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16), // spazio sotto
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator:
            validator ??
            (v) => v == null || v.trim().isEmpty ? 'Campo obbligatorio' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          filled: true,
        ),
      ),
    );
  }
}