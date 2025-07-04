import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/screen/schermatamodifica.dart';
import '../vinile/vinile.dart';
import '../database/databasehelper.dart';

// 1. Trasformiamo DettaglioVinileCollezione in un StatefulWidget
class DettaglioVinileCollezione extends StatefulWidget {
  final Vinile vinile; // Il vinile iniziale passato al widget
  const DettaglioVinileCollezione({super.key, required this.vinile});

  @override
  State<DettaglioVinileCollezione> createState() => _DettaglioVinileCollezioneState();
}

class _DettaglioVinileCollezioneState extends State<DettaglioVinileCollezione> {
  late Vinile _vinileCorrente; // 2. Variabile di stato per tenere traccia del vinile corrente
  bool modificato=false;
  @override
  void initState() {
    super.initState();
    // Inizializziamo il vinile corrente con quello passato al widget
    _vinileCorrente = widget.vinile;
  }

  // Metodo per ricaricare i dati del vinile dal database
  Future<void> _refreshVinileData() async {
    // Supponiamo che il tuo DatabaseHelper abbia un metodo per ottenere un vinile per ID
    // Se non ce l'hai, dovrai implementarlo.
    // Per semplicità, qui useremo l'ID del vinile corrente per recuperarlo aggiornato.
    final updatedVinile = await DatabaseHelper.instance.getVinile(_vinileCorrente.id!);
    if (updatedVinile != null) {
      setState(() {
        _vinileCorrente = updatedVinile; // Aggiorna lo stato con i nuovi dati
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_vinileCorrente.titolo)), // Usa _vinileCorrente
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Copertina
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _vinileCorrente.coverWidget, // Usa _vinileCorrente
            ),
          ),
          const SizedBox(height: 20),

          _InfoRow('Artista', _vinileCorrente.artista), // Usa _vinileCorrente
          _InfoRow('Anno', _vinileCorrente.anno?.toString() ?? '–'), // Usa _vinileCorrente
          _InfoRow('Etichetta', _vinileCorrente.etichettaDiscografica ?? '–'), // Usa _vinileCorrente
          // Per il genere e la condizione, è meglio recuperare il nome completo se hai un ID
          // o se la tua classe Vinile ha già un modo per farlo.
          // Per ora, useremo il nome dell'enum per la condizione e il genere come stringa.
          FutureBuilder<String?>(
            future: _vinileCorrente.genereNome, // Chiamiamo il getter asincrono
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _InfoRow('Genere', 'Errore: ${snapshot.error}'); // Gestisci errori
              } else {
                // Se il dato è disponibile, usalo, altrimenti un fallback
                final String genere = snapshot.data ?? 'Non Specificato';
                return _InfoRow('Genere', genere); // Mostra il nome del genere
              }
            },
          ),
          _InfoRow('Quantità', _vinileCorrente.quantita?.toString() ?? '–'), // Usa _vinileCorrente
          _InfoRow('Condizione', _vinileCorrente.condizione!.descrizione), // Usa _vinileCorrente.descrizione
          _InfoRow('Preferito', _vinileCorrente.preferito ? 'Sì' : 'No'), // Usa _vinileCorrente
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'edit',
            onPressed: () async {
              // 3. Aspettiamo il risultato dalla SchermataModifica
              final bool? modified = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SchermataModifica(vinile: _vinileCorrente, suggested: false)),
              );
              print("Sono in dettagliovinilecollezione e il bool modified è"+modified.toString());
              // Se la modifica è avvenuta (la schermata di modifica restituisce true)
              if (modified == true) {
                await _refreshVinileData();
                modificato=true;// Ricarica i dati del vinile
              }
            },
            child: const Icon(Icons.edit),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'delete',
            onPressed: () async {
              final conferma = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Conferma eliminazione'),
                  content: const Text('Sei sicuro di voler eliminare questo vinile?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Annulla'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Elimina'),
                    ),
                  ],
                ),
              );

              if (conferma == true) {
                await DatabaseHelper.instance.eliminaVinile(_vinileCorrente);
                Navigator.of(context).pop(true); // Torna indietro dopo eliminazione
              }
            },
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ],
    ),
  );
}