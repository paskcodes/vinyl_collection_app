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
    if (copertineVinili.length >= 4) {
      return SizedBox(
        width: dimensione,
        height: dimensione,
        child: GridView.count(
          crossAxisCount: 2,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: copertineVinili.take(4).map((copertina) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                copertina,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(color: Colors.grey),
              ),
            );
          }).toList(),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          copertineVinili.isNotEmpty
              ? copertineVinili.first
              : 'https://via.placeholder.com/300',
          width: dimensione,
          height: dimensione,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(color: Colors.grey),
        ),
      );
    }
  }
}
