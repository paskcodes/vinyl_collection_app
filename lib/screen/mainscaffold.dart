import 'package:flutter/material.dart';
import 'package:vinyl_collection_app/screen/schermatacategorie.dart';
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
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();
  final GlobalKey<SchermataCategorieState> _categorieKey = GlobalKey<SchermataCategorieState>();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(key: _homeKey),
      const SearchScreen(),
      SchermataCollezione(key: _collezioneKey),
      SchermataCategorie(key: _categorieKey),
    ];
  }
void _vaiSchermataAggiunta() async{
    bool? aggiunto= await Navigator.pushNamed(context, '/aggiunta') as bool?;
    if(aggiunto==true){
      _homeKey.currentState?.caricaDati();
      _collezioneKey.currentState?.caricaVinili();
      _categorieKey.currentState?.aggiornaGeneri();
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
        heroTag: 'SchermataAggiunta',
        onPressed: _vaiSchermataAggiunta,
        tooltip: 'Aggiungi nuovo vinile',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFF1DB954),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index==0){
            _homeKey.currentState?.caricaDati();
          }
          if (index == 2) {  // 2 è l'indice della schermata Collezione
            _collezioneKey.currentState?.caricaVinili();
          }
          if (index == 3) {  // 2 è l'indice della schermata Collezione
            _categorieKey.currentState?.aggiornaGeneri();
          }
        },
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
          BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined),
              activeIcon: Icon(Icons.category),
              label:'Categorie',
          )
        ],
      ),
    );
  }
}
