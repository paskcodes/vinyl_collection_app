import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/screen/schermatamodifica.dart';
import 'package:vinyl_collection_app/utils/dimensioniSchermo.dart';
import '../vinile/vinile.dart';
import '../database/databasehelper.dart';

class DettaglioVinileCollezione extends StatefulWidget {
  final Vinile vinile;

  const DettaglioVinileCollezione({super.key, required this.vinile});

  @override
  State<DettaglioVinileCollezione> createState() =>
      _DettaglioVinileCollezioneState();
}

class _DettaglioVinileCollezioneState extends State<DettaglioVinileCollezione> {
  late Vinile _vinileCorrente;

  @override
  void initState() {
    super.initState();
    _vinileCorrente = widget.vinile;
  }

  Future<void> _refreshVinileData() async {
    if (_vinileCorrente.id != null) {
      final updated = await DatabaseHelper.instance.getVinile(
        _vinileCorrente.id!,
      );
      if (updated != null && mounted) {
        setState(() => _vinileCorrente = updated);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double spacing = context.screenHeight * 0.03;
    final double horizontalPadding = context.screenWidth * 0.05;

    return Scaffold(
      appBar: AppBar(title: Text(_vinileCorrente.titolo), centerTitle: true),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: spacing,
        ),
        children: [
          // Cover con effetto vetrina
          Center(
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: context.screenWidth * 0.8,
                height: context.screenWidth * 0.8,
                child: _vinileCorrente.coverWidget,
              ),
            ),
          ),
          SizedBox(height: spacing),

          _ModernInfoBox(
            icon: Icons.person,
            label: 'Artista',
            value: _vinileCorrente.artista,
          ),
          _ModernInfoBox(
            icon: Icons.calendar_today,
            label: 'Anno',
            value: _vinileCorrente.anno?.toString() ?? '–',
          ),
          _ModernInfoBox(
            icon: Icons.album,
            label: 'Etichetta',
            value: _vinileCorrente.etichettaDiscografica ?? '–',
          ),
          FutureBuilder<String?>(
            future: _vinileCorrente.genereNome,
            builder: (context, snap) {
              final genere = snap.data ?? 'Non specificato';
              return _ModernInfoBox(
                icon: Icons.category,
                label: 'Genere',
                value: genere,
              );
            },
          ),
          _ModernInfoBox(
            icon: Icons.library_music,
            label: 'Copie possedute',
            value: _vinileCorrente.copie?.toString() ?? '–',
          ),
          _ModernInfoBox(
            icon: Icons.build,
            label: 'Condizione',
            value: _vinileCorrente.condizione?.descrizione ?? '–',
          ),
          _ModernInfoBox(
            icon: Icons.star,
            label: 'Preferito',
            value: _vinileCorrente.preferito ? 'Sì' : 'No',
            iconColor: _vinileCorrente.preferito
                ? Colors.amber
                : theme.colorScheme.outline,
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: context.screenHeight * 0.015,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FilledButton.icon(
              onPressed: () async {
                final modified = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SchermataModifica(
                      vinile: _vinileCorrente,
                      suggested: false,
                    ),
                  ),
                );
                if (modified == true) {
                  await _refreshVinileData();
                  if (mounted) Navigator.of(context).pop(true);
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Modifica'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final conferma = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Conferma eliminazione'),
                    content: const Text(
                      'Sei sicuro di voler eliminare questo vinile?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Annulla'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Elimina'),
                      ),
                    ],
                  ),
                );

                if (conferma == true) {
                  await DatabaseHelper.instance.eliminaVinile(_vinileCorrente);
                  if (mounted) Navigator.of(context).pop(true);
                }
              },
              icon: const Icon(Icons.delete),
              label: const Text('Elimina'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernInfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const _ModernInfoBox({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(vertical: context.screenHeight * 0.01),
      padding: EdgeInsets.all(context.screenWidth * 0.035),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: iconColor ?? theme.colorScheme.primary),
          SizedBox(width: context.screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: context.screenHeight * 0.004),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}