import 'dart:io'; // Zugriff auf Dateisystem für das Profilbild als Datei
import 'package:process_run/shell.dart'; // Zugriff auf Shell-Befehle
import 'package:flutter/material.dart'; // Flutter Material Design Widgets
import 'package:image_picker/image_picker.dart'; // Paket für die Bildauswahl
import 'package:shared_preferences/shared_preferences.dart'; // Zugriff auf geteilte Präferenzen

class SettingsPage extends StatefulWidget {
  final VoidCallback onToggleDarkMode; // Callback für den Dunkelmodus

  const SettingsPage({super.key, required this.onToggleDarkMode});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false; // Zustand für den Dunkelmodus
  File? _image; // Zustand für das Profilbild als Datei
  final _psnUsernameController = TextEditingController(); // Controller für PSN-Benutzernamen

  @override
  void initState() {
    super.initState();
    _loadProfileImage(); // Profilbild beim Initialisieren laden
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode; // Dunkelmodus umschalten
    });
  }

  // Laden des Profilbilds aus den geteilten Präferenzen
  void _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      String? imagePath = prefs.getString('profileImagePath');
      if (imagePath != null) {
        _image = File(imagePath); // Profilbild als Datei setzen, falls vorhanden
      }
    });
  }

  // Methode zum Auswählen eines Bildes aus der Galerie
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Ausgewähltes Bild als Datei setzen
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('profileImagePath', pickedFile.path); // Pfad in den Präferenzen speichern
      _notifyProfileImageChange(); // Änderung des Profilbilds benachrichtigen
    }
  }

  // Methode zum Abrufen eines Profilbilds von PSN
  Future<void> _fetchPsnImage() async {
    final username = _psnUsernameController.text.trim();
    if (username.isEmpty) {
      // Fehler anzeigen, wenn der Benutzername leer ist
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PSN Username cannot be empty")));
      return;
    }

    // PowerShell-Skript mit dem angegebenen Benutzernamen ausführen
    final shell = Shell();
    const scriptPath = "C:\\Users\\silviu.moldovan\\AndroidStudioProjects\\fallstudiev2\\lib\\Get-UserPicture.ps1";
    await shell.run('powershell.exe -File $scriptPath -username $username');

    // Nach Ausführung des Skripts sollte das Bild im Assets-Ordner gespeichert sein
    // Neues Profilbild laden
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _image = File('C:\\Users\\silviu.moldovan\\AndroidStudioProjects\\fallstudiev2\\assets\\$username-profile-picture.jpg');
      prefs.setString('profileImagePath', _image!.path); // Pfad in den Präferenzen speichern
    });
    _notifyProfileImageChange(); // Änderung des Profilbilds benachrichtigen
  }

  // Benachrichtigung über Änderungen des Profilbilds
  void _notifyProfileImageChange() {
    if (mounted) {
      Navigator.pop(context, true); // Navigation zurückspringen und Änderung signalisieren
    }
  }

  // Dialog zur Auswahl der Bildquelle (Galerie oder PSN)
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bildquelle wählen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Von Lokal'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(); // Methode zum Auswählen eines Bildes aus der Galerie aufrufen
              },
            ),
            ListTile(
              title: const Text('Von PSN'),
              onTap: () {
                Navigator.of(context).pop();
                _showPsnUsernameDialog(); // Methode zur Eingabe des PSN-Benutzernamens aufrufen
              },
            ),
          ],
        ),
      ),
    );
  }

  // Dialog zur Eingabe des PSN-Benutzernamens
  void _showPsnUsernameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PSN-Benutzername eingeben'),
        content: TextField(
          controller: _psnUsernameController,
          decoration: const InputDecoration(hintText: 'PSN-Benutzername'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _fetchPsnImage(); // Methode zum Abrufen des Profilbilds von PSN aufrufen
            },
            child: const Text('Bild holen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'), // Titel der AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6), // Icon für den Dunkelmodus
            onPressed: () {
              widget.onToggleDarkMode(); // Callback zum Umschalten des Dunkelmodus aufrufen
              _toggleDarkMode(); // Lokale Methode zum Umschalten des Dunkelmodus aufrufen
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Anzeige des Profilbilds oder eines Standard-Icons, falls kein Bild vorhanden ist
            _image != null
                ? CircleAvatar(
                    radius: 50,
                    backgroundImage: FileImage(_image!), // Profilbild als Hintergrundbild des CircleAvatar
                  )
                : const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.orange, // Hintergrundfarbe des CircleAvatar
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white, // Farbe des Icons im CircleAvatar
                    ),
                  ),
            const SizedBox(height: 20), // Abstand zwischen Profilbild und Button
            ElevatedButton(
              onPressed: _showImageSourceDialog, // Methode zur Auswahl der Bildquelle aufrufen
              child: const Text('Profilbild ändern'), // Text des Buttons
            ),
          ],
        ),
      ),
    );
  }
}
