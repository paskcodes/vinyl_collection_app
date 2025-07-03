// lib/service/discogs_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../vinile/vinile.dart';
import '../vinile/condizione.dart';

class DiscogsService {
  static final _token  = dotenv.env['DISCOGS_TOKEN'];
  static final String baseUrl = 'https://api.discogs.com/database/search';


  Future<List<Vinile>> ricerca(String query) async {
    try {
      late Uri uri;
      if (_token != null && _token!.isNotEmpty) {
         uri = Uri.parse('$baseUrl?q=$query&type=release&token=$_token');
      } else {
        throw Exception('Chiavi Discogs mancanti (.env)');
      }

      final res = await http.get(uri);
      if (res.statusCode != 200) {
        throw Exception(
            'Discogs ${res.statusCode}: ${res.reasonPhrase ?? ''}');
      }

      final results = (jsonDecode(res.body)['results'] as List?) ?? [];
      return results.map<Vinile>((r) {
        final fullTitle = r['title'] ?? '';
        var artista = r['artist'] ?? '';
        var titolo  = fullTitle;

        if (artista.isEmpty && fullTitle.contains(' - ')) {
          final parts = fullTitle.split(' - ');
          artista = parts.first.trim();
          titolo  = parts.sublist(1).join(' - ').trim();
        }

        return Vinile(
          titolo: titolo,
          artista: artista,
          anno: int.tryParse(r['year']?.toString() ?? ''),
          etichettaDiscografica: (r['label'] as List?)?.first,
          condizione: Condizione.Nuovo,
          immagine: r['cover_image'] as String?,
          preferito: false,
        );
      }).toList();
    } catch (e, s) {
      debugPrint('DiscogsService error: $e\n$s');
      return [];
    }
  }

  // Restituisce i trending da Discogs.
  Future<List<Vinile>> fetchTrendingVinyls({int limit = 10}) async {
    try {
      late Uri uri;
      if (_token != null && _token!.isNotEmpty) {
        uri = Uri.parse(
          'https://api.discogs.com/database/search'
              '?type=release&sort=hot&per_page=$limit&token=$_token',
        );
      } else {
        throw Exception('Chiavi Discogs mancanti (.env)');
      }

      final res = await http.get(uri);
      if (res.statusCode != 200) {
        throw Exception(
            'Discogs ${res.statusCode}: ${res.reasonPhrase ?? ''}');
      }

      final results = (jsonDecode(res.body)['results'] as List?) ?? [];
      return results.map<Vinile>((r) {
        final fullTitle = r['title'] ?? '';
        var artista = r['artist'] ?? '';
        var titolo  = fullTitle;

        if (artista.isEmpty && fullTitle.contains(' - ')) {
          final parts = fullTitle.split(' - ');
          artista = parts.first.trim();
          titolo  = parts.sublist(1).join(' - ').trim();
        }

        return Vinile(
          titolo: titolo,
          artista: artista,
          anno: int.tryParse(r['year']?.toString() ?? ''),
          etichettaDiscografica: (r['label'] as List?)?.first,
          condizione: Condizione.Nuovo,
          immagine: r['cover_image'] as String?,
          preferito: false,
        );
      }).toList();
    } catch (e, s) {
      debugPrint('DiscogsService error: $e\n$s');
      return [];
    }
  }
}