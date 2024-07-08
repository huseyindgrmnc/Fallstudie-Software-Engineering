// Import der benötigten Pakete und Klassen
import 'dart:convert'; // Paket für JSON-Verarbeitung
import 'package:fallstudiev2/landing_page.dart'; // Import der LandingPage
import 'package:fallstudiev2/settings_page.dart'; // Import der SettingsPage
import 'package:fallstudiev2/trophy_info.dart'; // Import der TrophyInfo Klasse
import 'package:flutter/material.dart'; // Flutter Material Design Komponenten
import 'package:flutter/services.dart'; // Zugriff auf Ressourcen wie JSON-Dateien

// StatefulWidget für die Spieleseite
class GamesPage extends StatefulWidget {
  final VoidCallback onToggleDarkMode; // Callback für Dunkelmodus-Umschaltung

  const GamesPage({super.key, required this.onToggleDarkMode}); // Konstruktor

  @override
  _GamesPageState createState() => _GamesPageState(); // Erstellt den zugehörigen State für GamesPage
}

// State-Klasse für GamesPage
class _GamesPageState extends State<GamesPage> {
  List<TrophyInfo> trophyList = []; // Liste aller Trophäen
  List<TrophyInfo> filteredTrophyList = []; // Gefilterte Trophäenliste
  bool _isLoading = true; // Ladeindikator
  String _errorMessage = ''; // Fehlermeldung bei Ladeproblemen
  final TextEditingController _searchController = TextEditingController(); // Controller für die Sucheingabe

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged); // Listener für Sucheingabe hinzufügen
    _loadTrophyData(); // Trophäendaten laden
  }

  // Funktion zum Laden der Trophäendaten aus der JSON-Datei
  void _loadTrophyData() async {
    try {
      String jsonData = await rootBundle.loadString('assets/trophy_titles.json'); // JSON-Datei laden
      Map<String, dynamic> data = jsonDecode(jsonData); // JSON parsen
      List<dynamic> trophyTitles = data['trophyTitles']; // Liste der Trophäentitel aus JSON

      // Filterung auf PS4 Trophäen
      trophyTitles = trophyTitles.where((trophy) => trophy['trophyTitlePlatform'] == 'PS4').toList();

      // Trophäenliste aktualisieren und Ladezustand zurücksetzen
      setState(() {
        trophyList = trophyTitles.map((json) => TrophyInfo.fromJson(json)).toList();
        filteredTrophyList = trophyList; // Initiale gefilterte Liste ist gleich der vollen Liste
        _isLoading = false; // Ladeindikator ausschalten
        _errorMessage = ''; // Fehlermeldung zurücksetzen
      });
    } catch (e) {
      print('Error loading trophy data: $e');
      setState(() {
        _isLoading = false; // Ladeindikator ausschalten
        _errorMessage = 'Error loading trophy data'; // Fehlermeldung setzen
      });
    }
  }

  // Funktion zum Aktualisieren der gefilterten Trophäenliste basierend auf der Sucheingabe
  void _onSearchChanged() {
    setState(() {
      filteredTrophyList = trophyList.where((trophy) =>
          trophy.title.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  // Dispose-Methode zum Aufräumen des Controllers
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged); // Listener entfernen
    _searchController.dispose(); // Controller freigeben
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size; // Bildschirmgröße ermitteln

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiele'), // Titel der AppBar
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Suchen',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator()) // Ladeindikator anzeigen
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage)) // Fehlermeldung anzeigen
                    : ListView.builder(
                        itemCount: filteredTrophyList.length,
                        itemBuilder: (context, index) {
                          var trophy = filteredTrophyList[index]; // Aktuelle Trophäe
                          return Column(
                            children: [
                              ExpansionTile(
                                leading: Image.network(trophy.iconUrl), // Trophäenbild anzeigen
                                title: Text(trophy.title), // Trophäenüberschrift
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenSize.width * 0.1,
                                        vertical: screenSize.height * 0.0001),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: screenSize.height * 0.02),
                                        Text('Fortschritt: ${trophy.progress}%', // Fortschrittsanzeige
                                            style: TextStyle(
                                                fontSize: screenSize.width * 0.035)),
                                        SizedBox(height: 10),
                                        LinearProgressIndicator(
                                          value: trophy.progress / 100, // Fortschrittsbalken
                                          backgroundColor: Colors.grey[300],
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            _buildTrophyWidget('pictures/bronze.jpg', '${trophy.earnedTrophies.bronze}/${trophy.definedTrophies.bronze}', screenSize), // Bronze Trophäen
                                            _buildTrophyWidget('pictures/silver.jpg', '${trophy.earnedTrophies.silver}/${trophy.definedTrophies.silver}', screenSize), // Silber Trophäen
                                            _buildTrophyWidget('pictures/gold.jpg', '${trophy.earnedTrophies.gold}/${trophy.definedTrophies.gold}', screenSize), // Gold Trophäen
                                            _buildTrophyWidget('pictures/platinum.jpg', '${trophy.earnedTrophies.platinum}/${trophy.definedTrophies.platinum}', screenSize), // Platin Trophäen
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20), // Abstand zwischen den Trophäen
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SettingsPage(onToggleDarkMode: widget.onToggleDarkMode)), // Navigation zur SettingsPage
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LandingPage(onToggleDarkMode: widget.onToggleDarkMode)), // Navigation zur LandingPage
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget zum Erstellen eines Trophäen-Widgets
  Widget _buildTrophyWidget(String imagePath, String text, Size screenSize) {
    return Expanded(
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 24,
            height: 24,
          ),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: screenSize.width * 0.035),
          ),
        ],
      ),
    );
  }
}
