import 'package:flutter/material.dart';
import '../utils/theme_toggle_action.dart';
import 'homepage.dart';
import 'ricerca.dart';
import 'schermatacategorie.dart';
import 'schermatacollezione.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late final PageController _pageController;
  int _currentIndex = 0;

  final _homeKey       = GlobalKey<HomeScreenState>();
  final _collezioneKey = GlobalKey<SchermataCollezioneState>();
  final _categorieKey  = GlobalKey<SchermataCategorieState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _pages = [
      HomeScreen(key: _homeKey),
      const SearchScreen(),
      SchermataCollezione(key: _collezioneKey),
      SchermataCategorie(key: _categorieKey),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // se devi richiamare ricariche dopo un’aggiunta
  void _vaiSchermataAggiunta() async {
    final aggiunto = await Navigator.pushNamed(context, '/aggiunta') as bool?;
    if (aggiunto == true) {
      _homeKey.currentState?.caricaDati();
      _collezioneKey.currentState?.caricaVinili();
      _categorieKey.currentState?.aggiornaGeneri();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  centerTitle: true,
  leading: _currentIndex == 3
      ? IconButton(
          icon: Icon(
            _categorieKey.currentState?.mostraTutte ?? false
                ? Icons.visibility_off
                : Icons.visibility,
          ),
          tooltip: _categorieKey.currentState?.mostraTutte ?? false
              ? 'Mostra solo categorie con vinili'
              : 'Mostra tutte le categorie',
          onPressed: () {
            _categorieKey.currentState?.toggleMostraTutte();
            setState(() {}); // forza rebuild per aggiornare icona
          },
        )
      : null,
  title: Text(
    ['Home', 'Cerca', 'Collezione', 'Categorie'][_currentIndex],
    style: const TextStyle(fontSize: 20),
  ),
  actions: const [ThemeToggleAction()],
),



      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: _pages,
      ),

      floatingActionButton: _currentIndex == 3
    ? FloatingActionButton(
        tooltip: 'Aggiungi nuova categoria',
        onPressed: _categorieKey.currentState?.vaiAggiuntaCategoria,
        child: const Icon(Icons.create_new_folder),
      )
    : Tooltip(
        message: 'Aggiungi un nuovo vinile',
        waitDuration: const Duration(milliseconds: 300),
        child: FloatingActionButton(
          heroTag: 'SchermataAggiunta',
          tooltip: 'Aggiungi nuovo vinile',
          onPressed: _vaiSchermataAggiunta,
          child: const Icon(Icons.add),
        ),
      ),


      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFF1DB954),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
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
            label: 'Categorie',
          ),
        ],
      ),
    );
  }
}
