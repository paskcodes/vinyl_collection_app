import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/screen/schermateSecondarie/dettaglio_vinile_collezione.dart';
import 'package:vinyl_collection_app/utils/dimensioni_schermo.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../components/suggestion_tile.dart';
import '../../database/database_helper.dart';
import '../../service/discogs_service.dart';
import '../../vinile/vinile.dart';
import '../schermateSecondarie/dettaglio_vinile_suggerito.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

Future<bool> isOnline() async {
  final result = await Connectivity().checkConnectivity();
  return result.any((connectivity) => 
    connectivity == ConnectivityResult.mobile || 
    connectivity == ConnectivityResult.wifi
  );
}

class HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  final _db = DatabaseHelper.instance;
  final _discogs = DiscogsService();

  List<Vinile> _recenti = [];
  List<Vinile> _preferiti = [];
  List<Vinile> _suggeriti = [];
  List<Vinile> _potrebberoPiacerti = [];
  List<Vinile> _piuCollezionati = [];
  List<Vinile> _ultimiInseriti = [];
  List<Vinile> _randomCollection = [];

  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  bool _online = true;

  @override
  void initState() {
    super.initState();
    caricaDati();
  }

  Future<void> caricaDati() async {
    _online = await isOnline();
    if (_online) {
      await _caricaDatiDaApi();
    }
    await _caricaDatiLocali();
    setState(() {});
  }

  Future<void> _caricaDatiDaApi() async {
    final generePreferito = await _db.getGenerePiuComune();
    final consigliati = generePreferito != null
        ? await _discogs.cercaPerGenere(generePreferito, limit: 10)
        : <Vinile>[];

    final suggested = await _discogs.cercaViniliTendenza(limit: 10);
    final piuCollezionati = await _discogs.iPiuCollezionati(limit: 10);
    final prossimeUscite = await _discogs.prossimeUscite(limit: 10);

    if (!mounted) return;

    setState(() {
      _suggeriti = suggested;
      _potrebberoPiacerti = consigliati;
      _piuCollezionati = piuCollezionati;
      _ultimiInseriti = prossimeUscite;
    });
  }


  Future<void> _caricaDatiLocali() async {
    final recent = await _db.getLastVinili(limit: 5);
    final preferiti = await _db.getPreferiti();
    final collezione = await _db.getCollezione();
    collezione.shuffle();
    final random = collezione.take(10).toList();

    if (!mounted) return;

    setState(() {
      _recenti = recent;
      _preferiti = preferiti;
      _randomCollection = random;
      _isLoading = false;
    });
  }

  Future<void> _apriDettaglioSuggeriti(BuildContext ctx, Vinile v) async {
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
      await caricaDati();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final double cardWidth = (context.screenWidth - 48) / 2.5;
    final double estimatedTextHeight = 50.0;
    final double listHeight = cardWidth + estimatedTextHeight + 20.0;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: caricaDati,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 24,
            left: 16,
            right: 16,
            bottom: 24,
          ),
          children: [
            for (final section in [
              _SectionData(
                title: 'Ultimi Vinili Aggiunti',
                vinili: _recenti,
                onTap: _apriDettaglioCollezione,
              ),
              _SectionData(
                title: 'Ultimi Trend',
                vinili: _suggeriti,
                onTap: (v) => _apriDettaglioSuggeriti(context, v),
              ),
              _SectionData(
                title: 'I tuoi Preferiti',
                vinili: _preferiti,
                onTap: _apriDettaglioCollezione,
              ),
              _SectionData(
                title: 'Potrebbero Piacerti',
                vinili: _potrebberoPiacerti,
                onTap: (v) => _apriDettaglioSuggeriti(context, v),
              ),
              _SectionData(
                title: 'Scelte Casuali dalla tua Collezione',
                vinili: _randomCollection,
                onTap: _apriDettaglioCollezione,
              ),
              _SectionData(
                title: 'I Più Collezionati',
                vinili: _piuCollezionati,
                onTap: (v) => _apriDettaglioSuggeriti(context, v),
              ),
              _SectionData(
                title: 'Le Prossime Uscite',
                vinili: _ultimiInseriti,
                onTap: (v) => _apriDettaglioSuggeriti(context, v),
              ),
            ].where((section) => section.vinili.isNotEmpty))
              _buildSection(
                titolo: section.title,
                vinili: section.vinili,
                cardWidth: cardWidth,
                listHeight: listHeight,
                onTap: section.onTap,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String titolo,
    required List<Vinile> vinili,
    required double cardWidth,
    required double listHeight,
    required Function(Vinile) onTap,
  }) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            titolo,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
        SizedBox(
          height: listHeight,
          child: vinili.isEmpty
              ? Center(
                  child: Text(
                    'Nessun vinile',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(
                        (0.4 * 255).round(),
                      ),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: vinili.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final v = vinili[i];
                    return SizedBox(
                      width: cardWidth,
                      child: SuggeritoTile(vinile: v, onTap: () => onTap(v)),
                    );
                  },
                ),
        ),
        const SizedBox(height: 12), // Ridotta la distanza qui
      ],
    );
  }
}

class _SectionData {
  final String title;
  final List<Vinile> vinili;
  final Function(Vinile) onTap;

  _SectionData({
    required this.title,
    required this.vinili,
    required this.onTap,
  });
}