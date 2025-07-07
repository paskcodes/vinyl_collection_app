import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/utils/dimensionischermo.dart';

class GenereTile extends StatelessWidget {
  final int genereId;
  final String nomeGenere;
  final int numeroVinili;
  final VoidCallback onTap;

  const GenereTile({
    super.key,
    required this.genereId,
    required this.nomeGenere,
    required this.numeroVinili,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double cardWidth   = context.screenWidth * 0.4;
    final double iconSize    = cardWidth * 0.6;
    final double titleSize   = context.shortestSide * 0.045;
    final double countSize   = context.shortestSide * 0.03;

    // Tavolozza del tema corrente
    final theme      = Theme.of(context);
    final scheme     = theme.colorScheme;
    final textTheme  = theme.textTheme;

    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: scheme.surface,                       // sfondo adattivo
        child: Container(
          width: cardWidth,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_note_rounded,
                size: iconSize,
                color: scheme.primary,               // usa il primario del tema
              ),
              const SizedBox(height: 8),

              // Nome del genere
              Text(
                nomeGenere,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: titleSize,
                  color: scheme.onSurface,           // testo adattivo
                ),
              ),
              const SizedBox(height: 4),

              // Conteggio vinili
              Text(
                '$numeroVinili ${numeroVinili == 1 ? 'vinile' : 'vinili'}',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: countSize,
                  color: scheme.onSurfaceVariant,    // tono attenuato
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
