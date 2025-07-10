import 'package:flutter/material.dart';
import '../vinile/vinile.dart';
import '../utils/dimensionischermo.dart';

class SuggestionTile extends StatelessWidget {
  final Vinile vinile;
  final VoidCallback onTap;

  const SuggestionTile({
    super.key,
    required this.vinile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Usa la larghezza passata o un valore calcolato
    // Puoi anche calcolarla qui in base a una percentuale dello schermo
    // Esempio: larghezza della card come 30% della larghezza dello schermo
    // final double responsiveCardWidth = context.screenWidth * 0.3; // Usa questa se vuoi che la larghezza sia calcolata qui
    // oppure semplicemente usa 'cardWidth' se lo calcoli dal genitore (come fai in HomeScreen)
    final double cardWidth=context.screenWidth * 0.3;
    // L'altezza dell'immagine dovrebbe essere proporzionale alla larghezza della card
    final double imageHeight = cardWidth; // Per avere un'immagine quadrata

    // Dimensione del font può essere proporzionale al lato più corto dello schermo
    final double titleFontSize = context.shortestSide * 0.04; // Esempio: 4% del lato più corto
    final double artistFontSize = context.shortestSide * 0.03; // Esempio: 3% del lato più corto


    return Container(
      // La larghezza del Container ora si adatta al cardWidth fornito o calcolato
      width: cardWidth,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: imageHeight, // Usa l'altezza calcolata in base alla larghezza della card
                height: imageHeight,
                child: vinile.immagine != null
                    ? (vinile.immagine!.startsWith('assets/')
                    ? Image.asset(
                  vinile.immagine!,
                  fit: BoxFit.cover,
                )
                    : Image.network(
                  vinile.immagine!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/immagini/vinilee.png',
                    fit: BoxFit.cover,
                  ),
                ))
                    : Image.asset(
                  'assets/immagini/vinilee.png',
                  fit: BoxFit.cover,
                ), // Dimensione icona proporzionale
              ),
            ),
            const SizedBox(height: 6),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    vinile.titolo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    // Usa la dimensione del font calcolata
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: titleFontSize),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vinile.artista,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    // Usa la dimensione del font calcolata
                    style: TextStyle(color: Colors.grey, fontSize: artistFontSize),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}