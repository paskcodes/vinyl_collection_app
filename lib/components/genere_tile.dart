import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/utils/dimensionischermo.dart';

class GenereTile extends StatelessWidget {
  final int genereId;
  final String nomeGenere;
  final int numeroVinili;
  final List<String> copertineVinili;
  final VoidCallback onTap;

  const GenereTile({
    super.key,
    required this.genereId,
    required this.nomeGenere,
    required this.numeroVinili,
    required this.onTap,
    required this.copertineVinili,
  });

  @override
  Widget build(BuildContext context) {
    final double cardWidth = context.screenWidth * 0.4;
    final double titleSize = context.shortestSide * 0.045;
    final double countSize = context.shortestSide * 0.03;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: scheme.surface,
        child: Container(
          width: cardWidth,
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildCopertina(context, cardWidth),
                const SizedBox(height: 8),
                Text(
                  nomeGenere,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: titleSize,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$numeroVinili ${numeroVinili == 1 ? 'vinile' : 'vinili'}',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: countSize,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCopertina(BuildContext context, double dimensione) {
    final copertine = copertineVinili.take(4).toList();

    Widget buildImage(String copertina) {
      if (copertina.startsWith('file://')) {
        return Image.file(
          File(copertina.substring(7)),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(color: Colors.grey),
        );
      } else {
        return Image.network(
          copertina,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(color: Colors.grey),
        );
      }
    }

    // Nessuna copertina
    if (copertine.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/immagini/vinilee.png',
          width: dimensione,
          height: dimensione,
          fit: BoxFit.cover,
        ),
      );
    }

    // Meno di 4 copertine → mostra solo la prima come immagine singola
    if (copertine.length < 4) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: dimensione,
          height: dimensione,
          child: buildImage(copertine.first),
        ),
      );
    }

    // 4 o più copertine → mostra GridView 2x2
    const int crossAxisCount = 2;
    const double spacing = 4;

    return SizedBox(
      width: dimensione,
      height: dimensione,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 1,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: buildImage(copertine[index]),
          );
        },
        shrinkWrap: true,
      ),
    );
  }
}