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
  List<Vinile> _preferiti = [];
  List<Vinile> _suggested = [];
  List<Vinile> _potrebberoPiacerti = [];
  List<Vinile> _piuCollezionati = [];
  List<Vinile> _ultimiInseriti = [];
  List<Vinile> _randomCollection = [];
  List<Vinile> _ultimeAggiunte = [];


  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    caricaDati();
  }

  Future<void> caricaDati() async {
    final recent = await _db.getLastVinili(limit: 5);
    final preferiti = await _db.getPreferiti();
    final suggested = await _discogs.cercaViniliTendenza(limit: 10);
    final generePreferito = await _db.getGenerePiuComune();
    final consigliati = generePreferito != null
        ? await _discogs.cercaPerGenere(generePreferito, limit: 10)
        : <Vinile>[];

    final collezione = await _db.getCollezione();
    collezione.shuffle();
    final random = collezione.take(10).toList();

    final piuCollezionati = await _discogs.iPiuCollezionati(limit: 10);
    final prossimeUscite = await _discogs.prossimeUscite(limit: 10);
    final ultimeAggiunte = await _discogs.ultimeReleaseAggiunte(limit: 10);

    // ✅ CONTROLLA SE IL WIDGET È ANCORA MONTATO
    if (!mounted) return;

    setState(() {
      _recent = recent;
      _preferiti = preferiti;
      _suggested = suggested;
      _potrebberoPiacerti = consigliati;
      _piuCollezionati = piuCollezionati;
      _ultimiInseriti = prossimeUscite;
      _randomCollection = random;
      _ultimeAggiunte = ultimeAggiunte;
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
    if ((aggiorna == true || aggiorna == null) && mounted) {
      logger.i("\n\n\n\nAggiorno!\n\n\n");
      await caricaDati();
    } else {
      logger.i("\n\n\n Non Aggiorno\n\n\n");
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double cardWidth = (context.screenWidth - 48) / 2.5;
    final double estimatedTextHeight = 50.0;
    final double listHeight = cardWidth + estimatedTextHeight + 20.0;

    final titleStyle = theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onSurface,
    );

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: caricaDati,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),

            _buildSection(
              title: 'Ultimi Vinili Aggiunti',
              vinili: _recent,
              cardWidth: cardWidth,
              listHeight: listHeight,
              onTap: _apriDettaglioCollezione,
            ),

            _buildSection(
              title: 'Ultimi Trend',
              vinili: _suggested,
              cardWidth: cardWidth,
              listHeight: listHeight,
              onTap: (v) => _apriDettaglioSuggested(context, v),
            ),

            _buildSection(
              title: 'I tuoi Preferiti',
              vinili: _preferiti,
              cardWidth: cardWidth,
              listHeight: listHeight,
              onTap: _apriDettaglioCollezione,
            ),

            _buildSection(
              title: 'Potrebbero Piacerti',
              vinili: _potrebberoPiacerti,
              cardWidth: cardWidth,
              listHeight: listHeight,
              onTap: (v) => _apriDettaglioSuggested(context, v),
            ),

            _buildSection(
              title: 'Scelte Casuali dalla tua Collezione',
              vinili: _randomCollection,
              cardWidth: cardWidth,
              listHeight: listHeight,
              onTap: _apriDettaglioCollezione,
            ),

            _buildSection(
              title: 'I Più Collezionati',
              vinili: _piuCollezionati,
              cardWidth: cardWidth,
              listHeight: listHeight,
              onTap: (v) => _apriDettaglioSuggested(context, v),
            ),

            _buildSection(
              title: 'Le Prossime Uscite',
              vinili: _ultimiInseriti,
              cardWidth: cardWidth,
              listHeight: listHeight,
              onTap: (v) => _apriDettaglioSuggested(context, v),
            ),

            _buildSection(
              title: 'Ultime Aggiunte su Discogs',
              vinili: _ultimeAggiunte,
              cardWidth: cardWidth,
              listHeight: listHeight,
              onTap: (v) => _apriDettaglioSuggested(context, v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Vinile> vinili,
    required double cardWidth,
    required double listHeight,
    required Function(Vinile) onTap,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              if (vinili.isNotEmpty)
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.colorScheme.primary),
            ],
          ),
        ),
        Material(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: _HorizontalList(
              vinili: vinili,
              itemWidth: cardWidth,
              listHeight: listHeight,
              itemBuilder: (v) => SuggestionTile(vinile: v, onTap: () => onTap(v)),
            ),
          ),
        ),
      ],
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