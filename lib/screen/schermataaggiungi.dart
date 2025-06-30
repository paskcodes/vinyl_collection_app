import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddEditVinylScreen extends StatefulWidget {
  const AddEditVinylScreen({super.key});

  @override
  State<AddEditVinylScreen> createState() => _AddEditVinylScreenState();
}

class _AddEditVinylScreenState extends State<AddEditVinylScreen> {
  final picker = ImagePicker();
  File? _immagineFile;

  Future<void> _scegliImmagine() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // opzionale: riduce dimensione
    );

    if (pickedFile != null) {
      setState(() {
        _immagineFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aggiungi Vinile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _scegliImmagine,
              child: _immagineFile != null
                  ? Image.file(_immagineFile!, height: 200)
                  : Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(
                  child: Text('Tocca per selezionare immagine'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_immagineFile != null) {
                  final path = _immagineFile!.path;

                  // salva nel modello Vinile
                  // esempio:
                  // final nuovoVinile = Vinile(immagine: path, ...);

                  // salva nel database ecc.
                }
              },
              child: const Text('Salva vinile'),
            )
          ],
        ),
      ),
    );
  }
}
