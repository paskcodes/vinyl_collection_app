// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vinyl_collection_app/screen/dettagliovinilecollezione.dart';
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
      print("\n\n\n\nAggiorno!\n\n\n");
      await caricaDati();
    }else{
      print("\n\n\n Non Aggiorno\n\n\n");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Calcolo della larghezza delle card (come prima)
    final double cardWidth = (screenWidth - (16 * 2) - 12) / 2.5;

    // --- NUOVO CALCOLO DELL'ALTEZZA DELLA LISTA ---
    // L'altezza della lista è basata sull'altezza che una singola SuggestionTile occupa.
    // Supponiamo: larghezza card + altezza testo (es. 40-60 pixel) + padding extra.
    // Questa è un'altezza 'stimata' che dovrai affinare in base al contenuto esatto della tua SuggestionTile.
    final double estimatedTextHeight = 50.0; // Altezza stimata per titolo e artista sotto l'immagine
    final double listHeight = cardWidth + estimatedTextHeight + 20.0; // 20.0 per padding o margini aggiuntivi

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
              listHeight: listHeight, // Passa l'altezza calcolata
              itemBuilder: (vinile) => SuggestionTile(
                vinile: vinile,
                onTap: () => _apriDettaglioCollezione(vinile),
              ),
            ),
            const SizedBox(height: 28), // Mantenuto lo spazio tra le sezioni
            Text('Consigliati per te', style: headline),
            const SizedBox(height: 12),
            _HorizontalList(
              vinili: _suggested,
              itemWidth: cardWidth,
              listHeight: listHeight, // Passa l'altezza calcolata
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
    required this.listHeight, // Ora è obbligatorio
    super.key,
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
        separatorBuilder: (_, __) => const SizedBox(width: 12),
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