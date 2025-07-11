import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/screen/dettagliovinilesuggested.dart';
import 'package:vinyl_collection_app/vinile/vinile.dart';
import '../service/discogs_service.dart';

// Importa la tua estensione per le dimensioni dello schermo
import '../utils/dimensionischermo.dart'; // Assicurati che il percorso sia corretto

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final DiscogsService _discogsService = DiscogsService();

  List<Vinile> _results = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      // Se la query è vuota, potresti voler pulire i risultati o mostrare un messaggio
      setState(() {
        _results = [];
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<Vinile> results = await _discogsService.ricerca(query);
      setState(() {
        _results = results;
      });
    } catch (e) {
      setState(() {
        _error = 'Errore durante la ricerca: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildResultItem(Vinile vinile) {
    // Calcola una dimensione per l'immagine leading basata sulla larghezza dello schermo
    // Ad esempio, il 12% della larghezza dello schermo, o un valore minimo/massimo
    final double leadingImageSize = context.screenWidth * 0.12; // Esempio
    // Puoi anche usare context.shortestSide per una dimensione che si adatti meglio
    // final double leadingImageSize = context.shortestSide * 0.1;

    return ListTile(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DettaglioVinileSuggested(vinile: vinile),
          ),
        );
      },
      leading: SizedBox(
        // Avvolgi l'immagine in un SizedBox per controllare le dimensioni
        width: leadingImageSize,
        height: leadingImageSize,
        child: vinile.immagine != null && vinile.immagine!.isNotEmpty
            ? Image.network(vinile.immagine!, fit: BoxFit.cover)
            : const Icon(
                Icons.album,
              ), // Considera di dare una dimensione all'icona
      ),
      title: Text(vinile.titolo),
      subtitle: Text(
        '${vinile.artista} - ${vinile.anno?.toString() ?? 'Anno sconosciuto'}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cerca su Discogs')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Cerca artista o album',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _search, child: const Text('Cerca')),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading) const CircularProgressIndicator(),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (!_isLoading && _results.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) =>
                      _buildResultItem(_results[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}