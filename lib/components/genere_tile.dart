import 'package:vinyl_collection_app/utils/dimensioniSchermo.dart';
import 'package:flutter/material.dart';

class GenereTile extends StatelessWidget {
  final int genereId; //per recuperare i vinili
  final String nomeGenere;
  final int numeroVinili;
  final VoidCallback onTap; // Callback da eseguire quando la tile viene toccata

  const GenereTile({
    super.key,
    required this.genereId,
    required this.nomeGenere,
    required this.numeroVinili,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calcola la larghezza della card in base alla larghezza dello schermo.
    final double cardWidth = context.screenWidth * 0.4;

    // L'altezza dell'icona (se presente) può essere proporzionale alla larghezza della card.
    final double iconSize = cardWidth * 0.6; // Esempio: 60% della larghezza della card

    // Le dimensioni del font possono essere proporzionali al lato più corto dello schermo
    // per adattarsi meglio sia in verticale che in orizzontale.
    final double titleFontSize = context.shortestSide * 0.045; // Dimensione per il nome del genere
    final double countFontSize = context.shortestSide * 0.03; // Dimensione per il conteggio dei vinili

    return InkWell(
      onTap: onTap, // Esegue la callback passata al costruttore
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8), // Margini per separare le card
        elevation: 4, // Ombra per dare un effetto 3D
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Bordi arrotondati
        child: Container(
          width: cardWidth, // Larghezza del contenitore della card
          padding: const EdgeInsets.all(12), // Padding interno per il contenuto
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centra il contenuto verticalmente
            crossAxisAlignment: CrossAxisAlignment.center, // Centra il contenuto orizzontalmente
            children: [
              // Icona del genere (puoi cambiarla o renderla dinamica)
              Icon(
                Icons.music_note_rounded, // Icona generica per la musica
                size: iconSize, // Dimensione dell'icona responsive
                color: Theme.of(context).primaryColor, // Colore dell'icona dal tema
              ),
              const SizedBox(height: 8), // Spazio tra icona e nome del genere

              // Nome del genere
              Text(
                nomeGenere,
                textAlign: TextAlign.center, // Centra il testo
                maxLines: 2, // Permette al nome di andare su due righe se lungo
                overflow: TextOverflow.ellipsis, // Aggiunge "..." se il testo è troppo lungo
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: titleFontSize, // Dimensione del font responsive
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4), // Spazio tra nome e conteggio

              // Conteggio dei vinili
              Text(
                '$numeroVinili ${numeroVinili == 1 ? 'vinile' : 'vinili'}', // Gestione del plurale
                textAlign: TextAlign.center, // Centra il testo
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: countFontSize, // Dimensione del font responsive
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}