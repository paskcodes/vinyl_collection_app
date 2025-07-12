import 'dart:io';
import 'package:flutter/material.dart';
import '../vinile/vinile.dart';
import '../utils/dimensioni_schermo.dart';

class SuggeritoTile extends StatelessWidget {
  final Vinile vinile;
  final VoidCallback onTap;

  const SuggeritoTile({super.key, required this.vinile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double cardWidth = context.screenWidth * 0.3;
    final double imageHeight = cardWidth; // Per avere un'immagine quadrata

    final double titleFontSize =
        context.shortestSide * 0.04;
    final double artistFontSize =
        context.shortestSide * 0.03;

    return Container(
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
                width: imageHeight,
                height: imageHeight,
                child: vinile.immagine != null
                    ? (vinile.immagine!.startsWith('assets/')
                          ? Image.asset(vinile.immagine!, fit: BoxFit.cover)
                          : vinile.immagine!.startsWith('file://')
                          ? Image.file(
                              File(
                                vinile.immagine!.substring(7),
                              ), // rimuovo 'file://'
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              vinile.immagine!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Image.asset(
                                'assets/immagini/vinilee.png',
                                fit: BoxFit.cover,
                              ),
                            ))
                    : Image.asset(
                        'assets/immagini/vinilee.png',
                        fit: BoxFit.cover,
                      ),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: titleFontSize,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vinile.artista,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: artistFontSize,
                    ),
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