import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vinyl_collection_app/screen/schermataaggiungi.dart';
import '../screen/mainscaffold.dart'; // importa la nuova schermata radice

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vinyl Collector',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const MainScaffold(),  // <-- usa questa
      routes: {
        // le rotte secondarie per dettaglio, aggiunta, ecc.
        '/aggiunta':(context) => const SchermataAggiungi()
      },
    );
  }
}
