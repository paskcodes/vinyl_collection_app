import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vinyl_collection_app/utils/dimensioni_schermo.dart';
import '../../vinile/genere.dart';
import '../../database/database_helper.dart';
import '../../vinile/condizione.dart';
import '../../vinile/vinile.dart';

class SchermataModifica extends StatefulWidget {
  final Vinile vinile;
  final bool suggested;

  const SchermataModifica({
    super.key,
    required this.vinile,
    required this.suggested,
  });

  @override
  State<SchermataModifica> createState() => _SchermataModificaState();
}


class _SchermataModificaState extends State<SchermataModifica> {
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
    final v = widget.vinile;
    _titolo.text = v.titolo;
    _artista.text = v.artista;
    _anno.text = v.anno?.toString() ?? '';
    _etichetta.text = v.etichettaDiscografica ?? '';
    _copie = v.copie ?? 1;
    _genereId = v.genere;
    _condizioneIdx = v.condizione?.index ?? 0;
    _preferito = v.preferito;
    _loadGeneri();
  }

  Future<void> _loadGeneri() async {
    final list = await DatabaseHelper.instance.getGeneri();
    if (!mounted) return;
    setState(() {
      _generi = list;
      _genereId ??= list.isNotEmpty ? list.first.id : null;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      setState(() => _coverFile = File(picked.path));
    }
  }

  bool get _formValid =>
      _formKey.currentState?.validate() == true && _genereId != null;

  Future<void> _salva() async {
    if (!_formValid) return;
    final nuovo = Vinile(
      id: widget.suggested ? null : widget.vinile.id,
      titolo: _titolo.text.trim(),
      artista: _artista.text.trim(),
      anno: int.tryParse(_anno.text),
      genere: _genereId,
      etichettaDiscografica: _etichetta.text.trim(),
      copie: _copie,
      condizione: Condizione.values[_condizioneIdx],
      immagine: _coverFile != null
          ? 'file://${_coverFile!.path}'
          : widget.vinile.immagine,
      preferito: _preferito,
    );

    if (widget.suggested) {
      final esiste = await DatabaseHelper.instance.vinileEsiste(nuovo);
      if (esiste) {
        if (mounted) {
          _showAlert(
            'Attenzione',
            'Hai già questo vinile nella tua collezione.',
          );
        }
        return;
      }
      await DatabaseHelper.instance.aggiungiVinile(nuovo);
      if (mounted) Navigator.pop(context, true);
    } else {
      if (nuovo == widget.vinile) {
        Navigator.pop(context, false);
        return;
      }
      final ok = await DatabaseHelper.instance.modificaVinile(nuovo);
      if (ok && mounted) Navigator.pop(context, true);
    }
  }

  Widget _buildImageWithFallback(String? path) {
    if (path == null || path.isEmpty) {
      return Image.asset('assets/immagini/vinile.png', fit: BoxFit.cover);
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/immagini/vinile.png', fit: BoxFit.cover);
        },
      );
    }

    if (path.startsWith('file://')) {
      return Image.file(
        File(Uri.parse(path).toFilePath()),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/immagini/vinile.png', fit: BoxFit.cover);
        },
      );
    }

    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset('assets/immagini/vinile.png', fit: BoxFit.cover);
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.suggested ? 'Aggiungi vinile' : 'Modifica vinile',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceActionSheet,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(20),
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      width: context.screenWidth * 0.8,
                      height: context.screenWidth * 0.8,
                      child: _coverFile != null
                          ? Image.file(
                        _coverFile!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/immagini/vinile.png', fit: BoxFit.cover);
                        },
                      )
                          : _buildImageWithFallback(widget.vinile.immagine),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _M3TextField(controller: _titolo, label: 'Titolo'),
              const SizedBox(height: 16),
              _M3TextField(controller: _artista, label: 'Artista'),
              const SizedBox(height: 16),
              _M3TextField(
                controller: _anno,
                label: 'Anno',
                keyboardType: TextInputType.number,
                validator: (v) {
                  final y = int.tryParse(v ?? '');
                  if (y == null || y < 1948 || y > DateTime.now().year) {
                    return 'Anno non valido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
                child: FilledButton.icon(
                  onPressed: _formValid ? _salva : null,
                  icon: Icon(widget.suggested ? Icons.add : Icons.check),
                  label: Text(
                    widget.suggested
                        ? 'Aggiungi alla collezione'
                        : 'Salva modifiche',
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

// ------------ widget helper --------------
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
  Widget build(BuildContext context) => TextFormField(
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
  );
}