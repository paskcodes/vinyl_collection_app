import 'package:flutter/material.dart';
import '../vinile/vinile.dart';

class VinylCard extends StatelessWidget {
  final Vinile vinile;
  final VoidCallback? onTap;          // ← callback opzionale

  const VinylCard({
    super.key,
    required this.vinile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            width: 50,
            height: 50,
            child: vinile.coverWidget, // ← unico punto che gestisce URL/file/asset
          ),
        ),
        title: Text(vinile.titolo),
        subtitle: Text(vinile.artista),
        trailing: Text(vinile.anno?.toString() ?? ''), // niente “null”
        // Se onTap è passato, usa quello; altrimenti naviga alla rotta /detail
        onTap: onTap ??
                () => Navigator.pushNamed(
              context,
              '/detail',
              arguments: vinile,
            ),
      ),
    );
  }
}
