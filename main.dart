import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trophy Display App',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: LandingPage(onToggleDarkMode: _toggleDarkMode),
    );
  }
}

class LandingPage extends StatefulWidget {
  final VoidCallback onToggleDarkMode;

  LandingPage({required this.onToggleDarkMode});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int totalGames = 0;
  int totalAchievements = 0;
  int maxAchievements = 0;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTrophyData();
  }

  void _loadTrophyData() async {
    try {
      String jsonData = await rootBundle.loadString('assets/trophy_titles.json');
      Map<String, dynamic> data = jsonDecode(jsonData);
      List<dynamic> trophyTitles = data['trophyTitles'];

      int games = trophyTitles.length;
      int achievements = 0;
      int maxAch = 0;

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
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
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
                          '$totalGames Games',
                          style: TextStyle(fontSize: screenSize.width * 0.06, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$totalAchievements / $maxAchievements Achievements',
                          style: TextStyle(fontSize: screenSize.width * 0.05, color: Colors.grey[700]),
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => GamesPage()),
                            );
                          },
                          child: Text('Games'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TrophyDetailsPage()),
                            );
                          },
                          child: Text('Achievements'),
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        IconButton(
                          icon: Icon(
                            Icons.settings,
                            size: screenSize.width * 0.08,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SettingsPage(onToggleDarkMode: widget.onToggleDarkMode)),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  final VoidCallback onToggleDarkMode;

  SettingsPage({required this.onToggleDarkMode});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image != null
                  ? CircleAvatar(
                      radius: screenSize.width * 0.15,
                      backgroundImage: FileImage(_image!),
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
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Profil Bild'),
              ),
              ElevatedButton(
                onPressed: widget.onToggleDarkMode,
                child: Text('Dark / Light'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Trophies {
  final int bronze;
  final int silver;
  final int gold;
  final int platinum;

  Trophies({
    required this.bronze,
    required this.silver,
    required this.gold,
    required this.platinum,
  });

  factory Trophies.fromJson(Map<String, dynamic> json) {
    return Trophies(
      bronze: json['bronze'],
      silver: json['silver'],
      gold: json['gold'],
      platinum: json['platinum'],
    );
  }
}

class TrophyInfo {
  final String title;
  final String iconUrl;
  final String platform;
  final Trophies definedTrophies;
  final Trophies earnedTrophies;
  final int progress;

  TrophyInfo({
    required this.title,
    required this.iconUrl,
    required this.platform,
    required this.definedTrophies,
    required this.earnedTrophies,
    required this.progress,
  });

  factory TrophyInfo.fromJson(Map<String, dynamic> json) {
    return TrophyInfo(
      title: json['trophyTitleName'],
      iconUrl: json['trophyTitleIconUrl'],
      platform: json['trophyTitlePlatform'],
      definedTrophies: Trophies.fromJson(json['definedTrophies']),
      earnedTrophies: Trophies.fromJson(json['earnedTrophies']),
      progress: json['progress'],
    );
  }
}

class TrophyDetailsPage extends StatefulWidget {
  @override
  _TrophyDetailsPageState createState() => _TrophyDetailsPageState();
}

class _TrophyDetailsPageState extends State<TrophyDetailsPage> {
  List<TrophyInfo> _trophies = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTrophyData();
  }

  void _loadTrophyData() async {
    try {
      String jsonData = await rootBundle.loadString('assets/trophy_titles.json');
      Map<String, dynamic> data = jsonDecode(jsonData);
      List<dynamic> trophyTitles = data['trophyTitles'];
      List<TrophyInfo> trophies = trophyTitles
          .map((json) => TrophyInfo.fromJson(json))
          .toList();

      setState(() {
        _trophies = trophies;
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
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Trophy Details'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _trophies.isNotEmpty
                  ? ListView.builder(
                      itemCount: _trophies.length,
                      itemBuilder: (context, index) {
                        TrophyInfo trophy = _trophies[index];
                        return Card(
                          child: ListTile(
                            leading: Image.network(trophy.iconUrl),
                            title: Text(trophy.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Platform: ${trophy.platform}'),
                                Text('Trophies: Bronze: ${trophy.definedTrophies.bronze}, Silver: ${trophy.definedTrophies.silver}, Gold: ${trophy.definedTrophies.gold}, Platinum: ${trophy.definedTrophies.platinum}'),
                                Text('Earned: Bronze: ${trophy.earnedTrophies.bronze}, Silver: ${trophy.earnedTrophies.silver}, Gold: ${trophy.earnedTrophies.gold}, Platinum: ${trophy.earnedTrophies.platinum}'),
                                Text('Progress: ${trophy.progress}%'),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(child: Text('No trophies found.')),
    );
  }
}

class GamesPage extends StatefulWidget {
  @override
  _GamesPageState createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  List<TrophyInfo> _trophies = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTrophyData();
  }

  void _loadTrophyData() async {
    try {
      String jsonData = await rootBundle.loadString('assets/trophy_titles.json');
      Map<String, dynamic> data = jsonDecode(jsonData);
      List<dynamic> trophyTitles = data['trophyTitles'];
      List<TrophyInfo> trophies = trophyTitles
          .map((json) => TrophyInfo.fromJson(json))
          .toList();

      setState(() {
        _trophies = trophies;
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
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Games'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _trophies.isNotEmpty
                  ? ListView.builder(
                      itemCount: _trophies.length,
                      itemBuilder: (context, index) {
                        TrophyInfo trophy = _trophies[index];
                        return Card(
                          child: ListTile(
                            leading: Image.network(trophy.iconUrl),
                            title: Text(trophy.title),
                          ),
                        );
                      },
                    )
                  : Center(child: Text('No games found.')),
    );
  }
}
