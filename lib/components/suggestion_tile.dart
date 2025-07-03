import 'package:flutter/material.dart';
import '../vinile/vinile.dart';
import '../screen/dettagliovinilesuggested.dart';

class SuggestionTile extends StatelessWidget {
  final Vinile vinile;
  final VoidCallback onTap;

  const SuggestionTile({super.key, required this.vinile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120, // Larghezza fissa del Container, come specificato
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DettaglioVinileSuggested(vinile: vinile),
            ),
          );
          // Se la callback esterna serve, decommenta:
          // onTap();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // La Column deve occupare tutta l'altezza disponibile nel suo genitore,
          // che nel _HorizontalFuture è 220px.
          // mainAxisSize: MainAxisSize.max, // Già il default, ma per chiarezza

          children: [
            // Immagine: Altezza Fissa per la copertina
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox( // Avvolgi l'AspectRatio in un SizedBox se vuoi un controllo più diretto sull'altezza
                width: 120, // Prende tutta la larghezza del Container genitore
                height: 120, // <--- Regola questa altezza dell'immagine se necessario
                child: vinile.immagine != null
                    ? Image.network(
                  vinile.immagine!,
                  fit: BoxFit.cover,
                )
                    : const Icon(Icons.album, size: 60, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 6), // Spazio tra immagine e testo

            // I testi devono occupare lo spazio rimanente
            // Wrap the Text widgets in an Expanded widget
            Expanded(
              child: Column( // Column interna per i testi
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start, // Allinea i testi in alto all'interno dell'Expanded
                children: [
                  Text(
                    vinile.titolo,
                    maxLines: 2, // Aumentato a 2 righe per dare più spazio al titolo
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), // Potresti voler ridurre la dimensione del font
                  ),
                  const SizedBox(height: 2), // Piccolo spazio tra titolo e artista
                  Text(
                    vinile.artista,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 12), // Potresti voler ridurre la dimensione del font
                  ),
                  // Se hai altri testi (es. anno), aggiungili qui.
                  // Non dare Expanded ai singoli Text qui, la Column genitore Expanded si occupa dello spazio.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}