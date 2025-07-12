import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vinyl_collection_app/utils/dimensioni_schermo.dart';
import '../../database/database_helper.dart';
import '../../vinile/vinile.dart';

class AnalisiViniliScreen extends StatefulWidget {
  const AnalisiViniliScreen({super.key});

  @override
  State<AnalisiViniliScreen> createState() => _AnalisiViniliScreenState();
}

class _AnalisiViniliScreenState extends State<AnalisiViniliScreen> {
  int totale = 0;
  Map<String, int> generi = {};
  List<Vinile> piuVecchi = [];
  Map<String, int> crescita = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _caricaAnalisi();
  }

  Future<void> _caricaAnalisi() async {
    final db = DatabaseHelper.instance;
    final collezione = await db.getCollezione();

    totale = collezione.length;

    for (var vinile in collezione) {
      final nomeGenere = await vinile.genereNome ?? 'Sconosciuto';
      generi[nomeGenere] = (generi[nomeGenere] ?? 0) + 1;
    }

    collezione.sort((a, b) => (a.anno ?? 9999).compareTo(b.anno ?? 9999));
    piuVecchi = collezione.take(3).toList();

    for (var vinile in collezione) {
      final anno = DateTime.tryParse(vinile.creatoIl)?.year.toString() ?? 'N/A';
      crescita[anno] = (crescita[anno] ?? 0) + 1;
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLandscape = context.isLandscape;
    final double padding = context.screenWidth * 0.04;
    final double spacing = context.screenHeight * 0.03;
    final double titleSize = context.screenWidth * 0.055;

    final headline = GoogleFonts.roboto(
      fontSize: titleSize,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analisi della Collezione',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(padding),
        child: ListView(
          children: [
            Text('Statistiche Generali', style: headline),
            SizedBox(height: spacing),
            _StatCard(
              icon: Icons.album_rounded,
              label: 'Totale Vinili',
              value: '$totale',
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: spacing),

            /// GENERE + CRESCITA (in LANDSCAPE uno accanto all’altro)
            SizedBox(height: spacing * 0.5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle('Distribuzione per genere', fontSize: titleSize * 0.85),
                SizedBox(height: spacing * 0.5),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  child: AspectRatio(
                    aspectRatio: context.isLandscape ? 2 : 1.6,
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: _PieChartWidget(generi: generi),
                    ),
                  ),
                ),
                SizedBox(height: spacing),
                _SectionTitle('Crescita della collezione', fontSize: titleSize * 0.85),
                SizedBox(height: spacing * 0.5),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  child: AspectRatio(
                    aspectRatio: context.isLandscape ? 2 : 1.6,
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: _BarChartWidget(crescita: crescita),
                    ),
                  ),
                ),
              ],
            ),



            SizedBox(height: spacing),
            _SectionTitle('Vinili più vecchi', fontSize: titleSize * 0.85),
            SizedBox(height: spacing * 0.5),
            isLandscape
                ? Row(
              children: piuVecchi
                  .map(
                    (v) => Expanded(
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history_edu_rounded,
                              size: 28),
                          SizedBox(height: 8),
                          Text('${v.titolo} - ${v.artista}',
                              textAlign: TextAlign.center),
                          Text('Anno: ${v.anno ?? 'Sconosciuto'}',
                              style: TextStyle(
                                  color: Colors.grey.shade700)),
                        ],
                      ),
                    ),
                  ),
                ),
              )
                  .toList(),
            )
                : Column(
              children: piuVecchi
                  .map(
                    (v) => ListTile(
                  leading:
                  const Icon(Icons.history_edu_rounded),
                  title: Text('${v.titolo} - ${v.artista}'),
                  subtitle:
                  Text('Anno: ${v.anno ?? 'Sconosciuto'}'),
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS ---

class _SectionTitle extends StatelessWidget {
  final String text;
  final double fontSize;

  const _SectionTitle(this.text, {required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.roboto(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = context.screenWidth;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: context.screenHeight * 0.025,
        ),
        child: Row(
          children: [
            Icon(icon, size: width * 0.1, color: color),
            SizedBox(width: width * 0.04),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.titleMedium),
                Text(
                  value,
                  style: GoogleFonts.roboto(
                    fontSize: width * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PieChartWidget extends StatelessWidget {
  final Map<String, int> generi;

  const _PieChartWidget({required this.generi});

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.teal,
      Colors.deepOrange,
      Colors.blue,
      Colors.purple,
      Colors.amber,
      Colors.green,
    ];

    final entries = generi.entries.toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);

    return PieChart(
      PieChartData(
        sections: List.generate(entries.length, (i) {
          final e = entries[i];
          final percent = (e.value / total) * 100;
          return PieChartSectionData(
            value: e.value.toDouble(),
            color: colors[i % colors.length],
            title: '${e.key}\n${percent.toStringAsFixed(1)}%',
            radius: context.isLandscape?context.screenWidth * 0.13 :context.screenWidth * 0.18,
            titleStyle: TextStyle(
              fontSize: context.screenWidth * 0.03,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            titlePositionPercentageOffset: 0.6,
          );
        }),
        sectionsSpace: 2,
        centerSpaceRadius: context.screenWidth * 0.08,
      ),
    );
  }
}

class _BarChartWidget extends StatelessWidget {
  final Map<String, int> crescita;

  const _BarChartWidget({required this.crescita});

  @override
  Widget build(BuildContext context) {
    final keys = crescita.keys.toList();
    return BarChart(
      BarChartData(
        barGroups: crescita.entries.map((e) {
          final i = keys.indexOf(e.key);
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: e.value.toDouble(),
                color: Theme.of(context).colorScheme.primary,
                width: context.screenWidth * 0.06,
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: context.isLandscape? context.screenHeight * 0.1 : context.screenHeight * 0.04,
              getTitlesWidget: (value, _) {
                final year = value.toInt() < keys.length
                    ? keys[value.toInt()]
                    : '';
                return Text(
                  year,
                  style: TextStyle(fontSize: context.screenWidth * 0.025),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}