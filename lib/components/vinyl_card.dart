// D:/vinyl_collection_app/lib/components/vinyl_card.dart
import 'package:flutter/material.dart';
import '../vinile/vinile.dart';

// Importa la pagina di dettaglio se la usi
// import '../screen/dettagliovinilesuggested.dart';

class VinylCard extends StatelessWidget {
  final Vinile vinile;
  final VoidCallback? onTap;

  const VinylCard({super.key, required this.vinile, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Non è necessario un margin qui, dato che _HorizontalFuture usa separatorBuilder
      // margin: const EdgeInsets.symmetric(vertical: 6), // Rimuovi o commenta questo
      clipBehavior: Clip.antiAlias,
      // Per ritagliare bene i bordi dell'immagine se la card ha bordi arrotondati
      child: InkWell(
        onTap:
            onTap ??
            () => Navigator.pushNamed(context, '/detail', arguments: vinile),
        child: Padding(
          // Aggiungi padding interno per non far toccare i bordi
          padding: const EdgeInsets.all(8.0), // Regola questo padding
          child: Column(
            // Column principale per il layout verticale della card
            crossAxisAlignment: CrossAxisAlignment.start,
            // Allinea il contenuto a sinistra
            children: [
              // Immagine di copertina
              Center(
                // Centra l'immagine orizzontalmente
                child: SizedBox(
                  width: 80, // Larghezza desiderata per la copertina (regola!)
                  height: 80, // Altezza desiderata per la copertina (regola!)
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: vinile.coverWidget,
                  ),
                ),
              ),

              const SizedBox(height: 8),
              // Spazio tra l'immagine e il testo

              // Contenuto testuale: Titolo, Artista, Anno
              // Usa Expanded per permettere ai testi di occupare lo spazio rimanente
              Expanded(
                child: Column(
                  // Column interna per i testi
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  // Allinea i testi in alto
                  children: [
                    Text(
                      vinile.titolo,
                      maxLines: 2, // Permetti 2 righe per il titolo
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vinile.artista,
                      maxLines: 1, // Limita l'artista a 1 riga
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    // Puoi aggiungere l'anno qui se vuoi che sia sotto l'artista
                    if (vinile.anno != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        vinile.anno!.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}