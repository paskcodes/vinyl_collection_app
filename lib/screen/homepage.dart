import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/search'),
              child: const Text('Cerca su Discogs'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/collection'),
              child: const Text('La mia collezione'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/add'),
              child: const Text('aggiungi'),
            ),
          ],
        ),
      ),
    );
  }
}