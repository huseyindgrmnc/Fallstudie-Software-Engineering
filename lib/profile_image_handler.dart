import 'package:image_picker/image_picker.dart'; // Paket für die Bildauswahl
import 'package:shared_preferences/shared_preferences.dart'; // Zugriff auf geteilte Präferenzen
import 'dart:io'; // Zugriff auf Dateisystem für Profilbild als Datei

class ProfileImageHandler {
  // Statische Methode, um das Profilbildpfad aus geteilten Präferenzen zu laden
  static Future<String?> loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Geteilte Präferenzen initialisieren
    return prefs.getString('profileImagePath'); // Profilbildpfad aus den Präferenzen abrufen
  }

  // Statische Methode, um das Profilbild als Datei aus geteilten Präferenzen zu laden
  static Future<File?> loadProfileImageFile() async {
    String? path = await loadProfileImage(); // Profilbildpfad laden
    if (path != null) {
      return File(path); // Dateiobjekt erstellen und zurückgeben, falls Pfad nicht null ist
    }
    return null; // Null zurückgeben, falls Pfad null ist
  }

  // Statische Methode, um ein Profilbild aus der Galerie auszuwählen
  static Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery); // Bildauswahl aus der Galerie
    if (pickedFile != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance(); // Geteilte Präferenzen initialisieren
      prefs.setString('profileImagePath', pickedFile.path); // Pfad des ausgewählten Bildes in Präferenzen speichern
    }
  }
}
