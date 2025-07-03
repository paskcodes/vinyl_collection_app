// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/suggestion_tile.dart';
import '../database/databasehelper.dart';
import '../service/discogs_service.dart';
import '../vinile/vinile.dart';
import 'dettagliovinilesuggested.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseHelper.instance;
  final _discogs = DiscogsService();

  List<Vinile> _recent = [];
  List<Vinile> _suggested = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    caricaDati();
  }

  Future<void> caricaDati() async {
    final recent = await _db.getLastVinili(limit: 5);
    final suggested = await _discogs.fetchTrendingVinyls(limit: 10);
    setState(() {
      _recent = recent;
      _suggested = suggested;
      _isLoading = false;
    });
  }

  Future<void> _apriDettaglio(BuildContext ctx, Vinile v) async {
    final aggiorna = await Navigator.push<bool>(
      ctx,
      MaterialPageRoute(builder: (_) => DettaglioVinileSuggested(vinile: v)),
    );
    if (aggiorna == true) {
      await caricaDati();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = (screenWidth - (16 * 2) - 12) / 2.5;

    final headline = GoogleFonts.roboto(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: caricaDati,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Ultimi vinili aggiunti', style: headline),
            const SizedBox(height: 12),
            _HorizontalList(
              vinili: _recent,
              itemWidth: cardWidth,
              itemBuilder: (v) => SuggestionTile(
                vinile: v,
                onTap: () => _apriDettaglio(context, v),
              ),
            ),
            const SizedBox(height: 28),
            Text('Consigliati per te', style: headline),
            const SizedBox(height: 12),
            _HorizontalList(
              vinili: _suggested,
              itemWidth: cardWidth,
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

class _HorizontalList extends StatelessWidget {
  final List<Vinile> vinili;
  final Widget Function(Vinile) itemBuilder;
  final double itemWidth;

  const _HorizontalList({
    required this.vinili,
    required this.itemBuilder,
    this.itemWidth = 150,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (vinili.isEmpty) {
      return const Center(child: Text('Nessun vinile'));
    }
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: vinili.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          return SizedBox(
            width: itemWidth,
            child: itemBuilder(vinili[i]),
          );
        },
      ),
    );
  }
}
