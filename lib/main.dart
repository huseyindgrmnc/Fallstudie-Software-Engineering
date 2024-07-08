// Import der benötigten Pakete
import 'package:fallstudiev2/landing_page.dart'; // Import der LandingPage
import 'package:flutter/material.dart'; // Flutter Material Design Komponenten

void main() {
  runApp(const MyApp()); // Start der Flutter-Anwendung mit MyApp als Wurzel-Widget
}

// StatefulWidget für die Hauptanwendung
class MyApp extends StatefulWidget {
  const MyApp({super.key}); // Konstruktor für MyApp, der einen optionalen Key annimmt

  @override
  _MyAppState createState() => _MyAppState(); // Erstellt den zugehörigen State für MyApp
}

// State-Klasse für MyApp
class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false; // Zustandsvariable für den Dunkelmodus

  // Funktion zum Umschalten des Dunkelmodus
  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode; // Umschalten des Zustands für den Dunkelmodus
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Deaktiviert das Debug-Banner
      title: 'Trophäen App', // Titel der Anwendung
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(), // Thema basierend auf Dunkelmodus
      home: LandingPage(onToggleDarkMode: _toggleDarkMode), // Startseite der Anwendung ist LandingPage
    );
  }
}
