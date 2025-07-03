// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/vinyl_card.dart';
import '../components/suggestion_tile.dart';
import '../database/databasehelper.dart';
import '../service/discogs_service.dart';
import '../vinile/vinile.dart';
import 'dettagliovinilesuggested.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseHelper.instance;
  final _discogs = DiscogsService();

  late Future<List<Vinile>> _recent;
  late Future<List<Vinile>> _random;
  late Future<List<Vinile>> _suggested;

  @override
  void initState() {
    super.initState();
    _caricaDati();
  }

  void _caricaDati() {
    _recent    = _db.getLastVinili(limit: 5);
    _random    = _db.getRandomVinili(limit: 5);
    _suggested = _discogs.fetchTrendingVinyls(limit: 10);
  }

  void _apriDettaglio(BuildContext ctx, Vinile v) {
    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (_) => DettaglioVinileSuggested(vinile: v)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final headline = GoogleFonts.roboto(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async => setState(_caricaDati),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---- Ultimi aggiunti ----
            Text('Ultimi vinili aggiunti', style: headline),
            const SizedBox(height: 12),
            _HorizontalFuture(
              future: _recent,
              itemBuilder: (v) => VinylCard(
                vinile: v,
                onTap: () => _apriDettaglio(context, v),
              ),
            ),

            const SizedBox(height: 28),

            // ---- Trend Discogs ----
            Text('Consigliati per te', style: headline),
            const SizedBox(height: 12),
            _HorizontalFuture(
              future: _suggested,
              itemBuilder: (v) => SuggestionTile(
                vinile: v,
                onTap: () => _apriDettaglio(context, v),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lista orizzontale popolata da un `Future<List<Vinile>>`
class _HorizontalFuture extends StatelessWidget {
  final Future<List<Vinile>> future;
  final Widget Function(Vinile) itemBuilder;

  const _HorizontalFuture({required this.future, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: FutureBuilder<List<Vinile>>(
        future: future,
        builder: (context, snap) {
          // ⏳ loading
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'Errore: ${snap.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }
          // ✅ dati (anche se vuoti)
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('Nessun vinile'));
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => itemBuilder(list[i]),
          );
        },
      ),
    );
  }
}
