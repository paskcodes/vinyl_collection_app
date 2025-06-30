import 'package:flutter/material.dart';
import 'homepage.dart';
import 'ricerca.dart';
import 'schermatacollezione.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final GlobalKey<SchermataCollezioneState> _collezioneKey = GlobalKey<SchermataCollezioneState>();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      const SearchScreen(),
      SchermataCollezione(key: _collezioneKey),
    ];
  }
void _vaiSchermataAggiunta() async{
    bool? aggiunto= await Navigator.pushNamed(context, '/aggiunta') as bool?;
    if(aggiunto==true){
      _collezioneKey.currentState?.aggiornaCollezione();
    }

}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _vaiSchermataAggiunta,
        tooltip: 'Aggiungi nuovo vinile',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFF1DB954),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Cerca',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music_outlined),
            activeIcon: Icon(Icons.library_music),
            label: 'Collezione',
          ),
        ],
      ),
    );
  }
}
