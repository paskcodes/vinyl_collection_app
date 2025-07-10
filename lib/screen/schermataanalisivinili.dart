import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/databasehelper.dart';
import '../vinile/vinile.dart';

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
    final headline = GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analisi della Collezione'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Statistiche Generali', style: headline),
          const SizedBox(height: 16),
          _StatCard(
            icon: Icons.album_rounded,
            label: 'Totale Vinili',
            value: '$totale',
            color: theme.colorScheme.primary,
          ),

          const SizedBox(height: 24),
          _SectionTitle('Distribuzione per genere'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _PieChartWidget(generi: generi),
              ),
            ),
          ),

          const SizedBox(height: 24),
          _SectionTitle('Vinili più vecchi'),
          ...piuVecchi.map(
                (v) => ListTile(
              leading: const Icon(Icons.history_edu_rounded),
              title: Text('${v.titolo} - ${v.artista}'),
              subtitle: Text('Anno: ${v.anno ?? 'Sconosciuto'}'),
            ),
          ),

          const SizedBox(height: 24),
          _SectionTitle('Crescita della collezione'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _BarChartWidget(crescita: crescita),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS ---

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w600),
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.titleMedium),
                Text(value, style: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            )
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
      Colors.green
    ];

    final entries = generi.entries.toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);

    return PieChart(PieChartData(
      sections: List.generate(entries.length, (i) {
        final e = entries[i];
        final percent = (e.value / total) * 100;
        return PieChartSectionData(
          value: e.value.toDouble(),
          color: colors[i % colors.length],
          title: '${e.key}\n${percent.toStringAsFixed(1)}%',
          radius: 70,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          titlePositionPercentageOffset: 0.6,
        );
      }),
      sectionsSpace: 2,
      centerSpaceRadius: 30,
    ));
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
          return BarChartGroupData(x: i, barRods: [
            BarChartRodData(toY: e.value.toDouble(), color: Theme.of(context).colorScheme.primary)
          ]);
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, _) {
                final year = value.toInt() < keys.length ? keys[value.toInt()] : '';
                return Text(year, style: const TextStyle(fontSize: 10));
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
