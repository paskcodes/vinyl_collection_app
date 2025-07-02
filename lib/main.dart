import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screen/mainscaffold.dart';
import 'screen/schermataaggiungi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vinyl Collector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      home: const MainScaffold(),
      routes: {
        '/aggiunta': (context) => const SchermataAggiungi(),
      },
    );
  }
}
