import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../vinile/vinile.dart';
import '../vinile/condizione.dart';
import '../database/database_helper.dart';

class DiscogsService {
  static final String? _token = dotenv.env['DISCOGS_TOKEN'];
  static const String _baseUrl = 'https://api.discogs.com/database/search';

  // Ricerche libere (titolo / artista / label *full‑text*)
  Future<List<Vinile>> ricerca(String query) async {
    final uri = _buildUri({'q': query, 'type': 'master'}); // Usa 'master' invece di 'release'
    final res = await http.get(uri);
    _checkResponse(res);
    final List results = (jsonDecode(res.body)['results'] as List?) ?? [];

    return _mapResults(results);
  }

  // Release «hot» su Discogs
  Future<List<Vinile>> cercaViniliTendenza({int limit = 10}) async {
    final uri = _buildUri({
      'type': 'master', // Usa 'master' per evitare duplicati
      'sort': 'hot',
      'per_page': '$limit',
    });
    final res = await http.get(uri);
    _checkResponse(res);
    final List results = (jsonDecode(res.body)['results'] as List?) ?? [];

    return _mapResults(results);
  }

  Uri _buildUri(Map<String, String> params) {
    if (_token == null || _token!.isEmpty) {
      throw Exception('DISCOGS_TOKEN mancante nel file .env');
    }
    final all = <String, String>{...params, 'token': _token!};
    return Uri.parse(_baseUrl).replace(queryParameters: all);
  }

  void _checkResponse(http.Response res) {
    if (res.statusCode != 200) {
      throw Exception('Discogs ${res.statusCode}: ${res.reasonPhrase ?? ''}');
    }
  }

  Future<List<Vinile>> _mapResults(List<dynamic> results) async {
    // Future.wait per permettere query async al DB per ogni risultato
    return Future.wait(
      results.map<Future<Vinile>>((raw) async {
        final Map<String, dynamic> r = raw as Map<String, dynamic>;

        final fullTitle = r['title'] as String? ?? '';
        String artista = r['artist'] as String? ?? '';
        String titolo = fullTitle;

        if (artista.isEmpty && fullTitle.contains(' - ')) {
          final parts = fullTitle.split(' - ');
          artista = parts.first.trim();
          titolo = parts.sublist(1).join(' - ').trim();
        }

        final List<dynamic>? generiJson = r['genre'] as List<dynamic>?;
        final String? primoGenere = generiJson?.isNotEmpty == true
            ? generiJson!.first as String
            : null;
        final int? genereId = await DatabaseHelper.instance.controlloGenere(
          primoGenere,
        );

        return Vinile(
          titolo: titolo,
          artista: artista,
          anno: int.tryParse(r['year']?.toString() ?? ''),
          genere: genereId,
          etichettaDiscografica: (r['label'] as List?)?.first,
          condizione: Condizione.nuovo,
          immagine: (r['cover_image'] as String?)?.isNotEmpty == true
              ? r['cover_image']
              : 'assets/immagini/vinile.png',
          preferito: false,
        );
      }).toList(),
    );
  }

  Future<List<Vinile>> cercaPerGenere(String genere, {int limit = 10}) async {
    final uri = Uri.parse(
      'https://api.discogs.com/database/search?genre=$genere&type=master&per_page=$limit&token=$_token', // Usa 'master'
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('Errore: ${res.statusCode}');

    final results = (jsonDecode(res.body)['results'] as List?) ?? [];

    return Future.wait(
      results.map<Future<Vinile>>((r) async {
        final fullTitle = r['title'] ?? '';
        var artista = r['artist'] ?? '';
        var titolo = fullTitle;

        if (artista.isEmpty && fullTitle.contains(' - ')) {
          final parts = fullTitle.split(' - ');
          artista = parts.first.trim();
          titolo = parts.sublist(1).join(' - ').trim();
        }

        final List<dynamic>? generiJson = r['genre'] as List<dynamic>?;
        final String? primoGenere = generiJson?.isNotEmpty == true
            ? generiJson!.first as String
            : null;

        final int? genereId = primoGenere != null
            ? await DatabaseHelper.instance.controlloGenere(primoGenere)
            : null;

        return Vinile(
          titolo: titolo,
          artista: artista,
          anno: int.tryParse(r['year']?.toString() ?? ''),
          genere: genereId,
          etichettaDiscografica: (r['label'] as List?)?.first,
          condizione: Condizione.nuovo,
          immagine: r['cover_image'] as String?,
          preferito: false,
        );
      }).toList(),
    );
  }

  Future<List<Vinile>> iPiuCollezionati({int limit = 10}) async {
    final uri = _buildUri({
      'type': 'master', // Usa 'master' per evitare duplicati
      'sort': 'have', // ordinati per numero di persone che lo possiedono
      'per_page': '$limit',
    });

    final res = await http.get(uri);
    _checkResponse(res);
    final results = (jsonDecode(res.body)['results'] as List?) ?? [];

    return _mapResults(results);
  }

  Future<List<Vinile>> prossimeUscite({int limit = 10}) async {
    final uri = _buildUri({
      'type': 'master', // Usa 'master' per evitare duplicati
      'sort': 'year',
      'sort_order': 'desc',
      'per_page': '$limit',
    });

    final res = await http.get(uri);
    _checkResponse(res);
    final results = (jsonDecode(res.body)['results'] as List?) ?? [];

    return _mapResults(results);
  }
}