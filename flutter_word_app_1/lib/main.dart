// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_word_app_1/screens/add_word_form..dart';
import 'screens/word_list_screen.dart';
//import 'screens/add_word_form.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Word App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,

        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(), 
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<WordListScreenState> _wordListKey = GlobalKey<WordListScreenState>();
  
  late List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _screens = [
      WordListScreen(key: _wordListKey),
      SingleChildScrollView(
        child: AddWordForm(
          onWordAdded: () {
            // Kelime eklendiğinde listeyi yenile ve ilk sekmeye geç
            _wordListKey.currentState?.loadWords();
            setState(() {
              _selectedScreen = 0;
            });
          },
        ),
      ),
    ];
  }
  
  int _selectedScreen = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kelimelerim"),
        backgroundColor: Colors.blue,
      ),
      body: _screens[_selectedScreen], 
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedScreen,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.list_alt), 
            label: "Kelimeler" 
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline), 
            label: "Ekle"
          ),
        ],
        onDestinationSelected: (value) {
          setState(() {
            _selectedScreen = value;
          });
        },
      ),
    );
  }
}
