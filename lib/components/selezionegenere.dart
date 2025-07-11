import 'package:flutter/material.dart';
import '../vinile/genere.dart';
import '../database/databasehelper.dart';

class DialogSelezioneGenere extends StatelessWidget {
  const DialogSelezioneGenere({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Genere>>(
      future: DatabaseHelper.instance.getGeneri(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final generi = snapshot.data!;

        return AlertDialog(
          title: const Text("Scegli un genere"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: generi.length,
              itemBuilder: (_, index) => ListTile(
                title: Text(generi[index].nome),
                onTap: () => Navigator.pop(context, generi[index].id),
              ),
            ),
          ),
        );
      },
    );
  }
}
