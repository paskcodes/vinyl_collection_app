import 'package:flutter/material.dart';
import '../service/discogs_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final DiscogsService _discogsService = DiscogsService();

  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await _discogsService.searchVinyls(query);
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

  Widget _buildResultItem(Map<String, dynamic> item) {
    return ListTile(
      leading: item['cover_image'] != null
          ? Image.network(item['cover_image'], width: 50, fit: BoxFit.cover)
          : const Icon(Icons.album),
      title: Text(item['title'] ?? 'Senza titolo'),
      subtitle: Text('${item['type']} - ${item['year'] ?? 'Anno sconosciuto'}'),
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
                ElevatedButton(
                  onPressed: _search,
                  child: const Text('Cerca'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading) const CircularProgressIndicator(),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            if (!_isLoading && _results.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    return _buildResultItem(_results[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
