// Import der benötigten Pakete und Klassen
import 'dart:convert'; // Paket für JSON-Verarbeitung
import 'dart:io'; // Zugriff auf Dateisystem für Profilbild
import 'package:fallstudiev2/games_page.dart'; // Import der GamesPage
import 'package:fallstudiev2/settings_page.dart'; // Import der SettingsPage
import 'package:flutter/material.dart'; // Flutter Material Design Komponenten
import 'package:flutter/services.dart'; // Zugriff auf Ressourcen wie JSON-Dateien
import 'package:shared_preferences/shared_preferences.dart'; // Zugriff auf geteilte Präferenzen

// StatefulWidget für die Landing Page
class LandingPage extends StatefulWidget {
  final VoidCallback onToggleDarkMode; // Callback für Dunkelmodus-Umschaltung

  const LandingPage({super.key, required this.onToggleDarkMode}); // Konstruktor

  @override
  _LandingPageState createState() => _LandingPageState(); // Erstellt den zugehörigen State für LandingPage
}

// State-Klasse für LandingPage
class _LandingPageState extends State<LandingPage> {
  int totalGames = 0; // Gesamtanzahl an Spielen
  int totalAchievements = 0; // Gesamtanzahl an errungenen Trophäen
  int maxAchievements = 0; // Maximale Anzahl an möglichen Trophäen
  bool _isLoading = true; // Ladeindikator
  String _errorMessage = ''; // Fehlermeldung bei Ladeproblemen
  String? _profileImagePath; // Pfad zum Profilbild

  @override
  void initState() {
    super.initState();
    _loadProfileImage(); // Profilbild laden
    _loadTrophyData(); // Trophäendaten laden
  }

  // Asynchrones Laden des Profilbildes, um die UI nicht zu blockieren
  void _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profileImagePath'); // Profilbild-Pfad aus den geteilten Präferenzen laden
    });
  }

  // Asynchrones Laden der Trophäendaten, um die UI nicht zu blockieren
  void _loadTrophyData() async {
    try {
      String jsonData = await rootBundle.loadString('assets/trophy_titles.json'); // JSON-Datei laden
      Map<String, dynamic> data = jsonDecode(jsonData); // JSON parsen
      List<dynamic> trophyTitles = data['trophyTitles']; // Liste der Trophäentitel aus JSON

      int games = trophyTitles.length; // Anzahl der Spiele ist die Anzahl der Trophäen
      int achievements = 0; // Initialisierung der Gesamtanzahl an Trophäen
      int maxAch = 0; // Initialisierung der maximal möglichen Trophäen

      // Iteration über alle Trophäen, um die Gesamtzahl und maximale Anzahl an Trophäen zu berechnen
      for (var trophy in trophyTitles) {
        var earnedTrophies = trophy['earnedTrophies'];
        var definedTrophies = trophy['definedTrophies'];

        achievements += (earnedTrophies['bronze'] as num).toInt() +
            (earnedTrophies['silver'] as num).toInt() +
            (earnedTrophies['gold'] as num).toInt() +
            (earnedTrophies['platinum'] as num).toInt();

        maxAch += (definedTrophies['bronze'] as num).toInt() +
            (definedTrophies['silver'] as num).toInt() +
            (definedTrophies['gold'] as num).toInt() +
            (definedTrophies['platinum'] as num).toInt();
      }

      // Zustand aktualisieren mit den berechneten Werten und Ladeindikator zurücksetzen
      setState(() {
        totalGames = games;
        totalAchievements = achievements;
        maxAchievements = maxAch;
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      print('Error loading trophy data: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading trophy data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size; // Bildschirmgröße ermitteln
    double progress = totalAchievements / maxAchievements; // Fortschritt in Prozent berechnen

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Ladeindikator anzeigen
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage)) // Fehlermeldung anzeigen
              : Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _profileImagePath != null
                            ? CircleAvatar(
                                radius: screenSize.width * 0.15,
                                backgroundImage: FileImage(File(_profileImagePath!)), // Profilbild anzeigen
                              )
                            : CircleAvatar(
                                radius: screenSize.width * 0.15,
                                backgroundColor: Colors.orange,
                                child: Icon(
                                  Icons.person,
                                  size: screenSize.width * 0.15,
                                  color: Colors.white,
                                ),
                              ),
                        SizedBox(height: screenSize.height * 0.02),
                        Text(
                          '$totalGames Spiele', // Anzahl der Spiele anzeigen
                          style: TextStyle(fontSize: screenSize.width * 0.06, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$totalAchievements / $maxAchievements Trophäen', // Anzahl der Trophäen anzeigen
                          style: TextStyle(fontSize: screenSize.width * 0.05, color: Colors.grey[700]),
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        CircularProgressIndicator(
                          value: progress, // Fortschrittsbalken anzeigen
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          strokeWidth: 8,
                          semanticsLabel: 'Trophäen Fortschritt',
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => GamesPage(onToggleDarkMode: widget.onToggleDarkMode)),
                            );
                          },
                          child: const Text('Spiele'), // Spiele-Button
                        ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () async {
                bool? profileImageChanged = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage(onToggleDarkMode: widget.onToggleDarkMode)),
                );
                if (profileImageChanged == true) {
                  _loadProfileImage(); // Profilbild neu laden, wenn es geändert wurde
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
