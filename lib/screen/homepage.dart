import 'package:flutter/material.dart';

import '../components/vinyl_card.dart';
import '../database/databasehelper.dart';
import '../vinile/vinile.dart';
import '../components/suggestion_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('La mia Collezione')),
      body: FutureBuilder<_HomeData>(
        future: _caricaDatiHome(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle('Ultimi vinili aggiunti'),
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: data.recent.length,
                    itemBuilder: (context, i) =>
                        VinylCard(vinile: data.recent[i]),
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle('Suggerimenti casuali'),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data.random.length,
                    itemBuilder: (context, i) =>
                        SuggestionTile(vinile: data.random[i]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/addVinyl'),
        child: const Icon(Icons.add),
        tooltip: 'Aggiungi nuovo vinile',
      ),
    );
  }

  Future<_HomeData> _caricaDatiHome() async {
    final db = DatabaseHelper.instance;
    final recent = await db.getLastVinili(limit: 5);
    final random = await db.getRandomVinili(limit: 3);
    return _HomeData(recent: recent, random: random);
  }
}

class _HomeData {
  final List<Vinile> recent;
  final List<Vinile> random;
  _HomeData({required this.recent, required this.random});
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context)
        .textTheme
        .titleMedium!
        .copyWith(fontWeight: FontWeight.bold),
  );
}