import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vinyl_collection_app/screen/dettagliovinilecollezione.dart';
import 'package:vinyl_collection_app/utils/dimensionischermo.dart';
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
  List<Vinile> _potrebberoPiacerti = [];


  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    caricaDati();
  }

  Future<void> caricaDati() async {
    final recent = await _db.getLastVinili(limit: 5);
    final suggested = await _discogs.fetchTrendingVinyls(limit: 10);
    final generePreferito = await _db.getGenerePiuComune();
    final consigliati = generePreferito != null
        ? await _discogs.cercaPerGenere(generePreferito, limit: 10)
        : <Vinile>[];

    setState(() {
      _recent = recent;
      _suggested = suggested;
      _potrebberoPiacerti = consigliati;
      _isLoading = false;
    });
  }


  Future<void> _apriDettaglioSuggested(BuildContext ctx, Vinile v) async {
    final aggiorna = await Navigator.push<bool>(
      ctx,
      MaterialPageRoute(builder: (_) => DettaglioVinileSuggested(vinile: v)),
    );
    if (aggiorna == true) {
      await caricaDati();
    }
  }

  Future<void> _apriDettaglioCollezione(Vinile v) async {
    final aggiorna = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DettaglioVinileCollezione(vinile: v)),
    );
    if (aggiorna == true||aggiorna==null) {
      logger.i("\n\n\n\nAggiorno!\n\n\n");
      await caricaDati();
    }else{
      logger.i("\n\n\n Non Aggiorno\n\n\n");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = (context.screenWidth - (16 * 2) - 12) / 2.5;

    // Calcolo dell'altezza della lista (stima)
    final double estimatedTextHeight = 50.0;
    final double listHeight = cardWidth + estimatedTextHeight + 20.0;

    final headline = GoogleFonts.roboto(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    );

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: caricaDati,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 12), // padding top dinamico
            Text('Ultimi Vinili Aggiunti', style: headline),
            const SizedBox(height: 6),
            _HorizontalList(
              vinili: _recent,
              itemWidth: cardWidth,
              listHeight: listHeight,
              itemBuilder: (vinile) => SuggestionTile(
                vinile: vinile,
                onTap: () => _apriDettaglioCollezione(vinile),
              ),
            ),
            const SizedBox(height: 8),
            Text('Ultimi Trend', style: headline),
            const SizedBox(height: 6),
            _HorizontalList(
              vinili: _suggested,
              itemWidth: cardWidth,
              listHeight: listHeight,
              itemBuilder: (v) => SuggestionTile(
                vinile: v,
                onTap: () => _apriDettaglioSuggested(context, v),
              ),
            ),
            const SizedBox(height: 8),
            Text('Potrebbero Piacerti', style: headline),
            const SizedBox(height: 6),
            _HorizontalList(
              vinili: _potrebberoPiacerti,
              itemWidth: cardWidth,
              listHeight: listHeight,
              itemBuilder: (v) => SuggestionTile(
                vinile: v,
                onTap: () => _apriDettaglioSuggested(context, v),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// La classe _HorizontalList rimane invariata rispetto all'ultima modifica
// in cui accetta listHeight come parametro.

class _HorizontalList extends StatelessWidget {
  final List<Vinile> vinili;
  final Widget Function(Vinile) itemBuilder;
  final double itemWidth;
  final double listHeight; // Aggiungi questo parametro per l'altezza

  const _HorizontalList({
    required this.vinili,
    required this.itemBuilder,
    this.itemWidth = 150,
    required this.listHeight,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (vinili.isEmpty) {
      content = const Center(child: Text('Nessun vinile'));
    } else {
      content = ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: vinili.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          return SizedBox(
            width: itemWidth,
            child: itemBuilder(vinili[i]),
          );
        },
      );
    }

    return SizedBox(
      height: listHeight, // Usa l'altezza calcolata e passata
      child: content,
    );
  }
}