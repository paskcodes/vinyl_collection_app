import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/screen/schermateSecondarie/dettaglio_vinile_suggerito.dart';
import 'package:vinyl_collection_app/vinile/vinile.dart';
import '../../service/discogs_service.dart';

// Importa la tua estensione per le dimensioni dello schermo
import '../../utils/dimensioni_schermo.dart'; // Assicurati che il percorso sia corretto

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

    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (!isOnline) {
      setState(() {
        _isLoading = false;
        _results = [];
        _error = 'Funzionalità non disponibile offline';
      });
      return;
    }

    try {
      List<Vinile> results = await _discogsService.ricerca(query);
      setState(() {
        _results = results;
      });
    } catch (e) {
      setState(() {
        _error = 'Errore durante la ricerca';
        _results = [];
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
    final double leadingImageSize = context.screenWidth * 0.12; // Esempio

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
        //immagine in un SizedBox per controllarne le dimensioni
        width: leadingImageSize,
        height: leadingImageSize,
        child: vinile.immagine != null && vinile.immagine!.isNotEmpty
            ? Image.network(vinile.immagine!, fit: BoxFit.cover)
            : const Icon(
                Icons.album,
              ),
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
      appBar: AppBar(title: const Text(style: TextStyle(fontWeight: FontWeight.bold), 'Cerca su Discogs')),
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
            if (_error != null && _results.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.wifi_off,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
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