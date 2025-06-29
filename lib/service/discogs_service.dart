import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class DiscogsService {
  final String baseUrl = 'https://api.discogs.com/database/search';

  Future<List<Map<String, dynamic>>> searchVinyls(String query) async {
    final token = dotenv.env['DISCOGS_TOKEN'];

    if (token == null || token.isEmpty) {
      throw Exception('Token Discogs non trovato nel file .env');
    }

    final url = Uri.parse('$baseUrl?q=$query&type=release&token=$token');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final results = jsonData['results'] as List<dynamic>;

      return results.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Errore ${response.statusCode}: ${response.body}');
    }
  }
}