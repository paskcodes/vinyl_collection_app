import 'package:flutter/material.dart';
import '../vinile/vinile.dart';

class VinylCard extends StatelessWidget {
  final Vinile vinile;
  const VinylCard({super.key, required this.vinile});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: vinile.immagine != null
              ? Image.network(
            vinile.immagine!,
            width: 50,
            fit: BoxFit.cover,
          )
              : const Icon(Icons.album, size: 40),
        ),
        title: Text(vinile.titolo),
        subtitle: Text(vinile.artista),
        trailing: Text(vinile.anno.toString()),
        onTap: () =>
            Navigator.pushNamed(context, '/detail', arguments: vinile),
      ),
    );
  }
}
