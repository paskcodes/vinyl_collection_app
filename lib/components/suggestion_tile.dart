import 'package:flutter/material.dart';
import '../vinile/vinile.dart';
import '../screen/dettagliovinile.dart';  // importa la pagina dettaglio

class SuggestionTile extends StatelessWidget {
  final Vinile vinile;
  final VoidCallback onTap;  // mantieni questo se ti serve, altrimenti puoi rimuoverlo

  const SuggestionTile({super.key, required this.vinile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DettaglioVinile(vinile: vinile),
            ),
          );
          // Se vuoi eseguire anche onTap passato da fuori (se usi questo callback)
          // onTap();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: vinile.immagine != null
                    ? Image.network(
                  vinile.immagine!,
                  fit: BoxFit.cover,
                )
                    : const Icon(Icons.album, size: 60),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              vinile.titolo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              vinile.artista,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
